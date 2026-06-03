import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  GoogleSignIn get googleSignIn {
    if (_googleSignIn == null) {
      if (kIsWeb) {
        _googleSignIn = GoogleSignIn(
          clientId: const String.fromEnvironment('WEB_OAUTH_CLIENT_ID',
            defaultValue: ''),
        );
      } else {
        _googleSignIn = GoogleSignIn(
          clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? '60683918105-erapd2ob9mkc9h8qohj22ns5f92s9qa7.apps.googleusercontent.com'
            : null,
        );
      }
    }
    return _googleSignIn!;
  }

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Dùng Firebase Auth popup trên web
        final provider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(provider);
      } else {
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }
      
      try {
        await _saveUserToFirestore(userCredential.user).timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw Exception('Firestore timeout'),
        );
      } catch (e) {
        if (kDebugMode) print('APP_LOG: Firestore metadata update skipped/failed: $e');
      }
      
      return userCredential;
    } catch (e) {
      if (kDebugMode) print('Google sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb && _googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
    await _auth.signOut();
  }

  Future<String?> getUserInviteCode(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['inviteCode'] as String?;
    } catch (e) {
      if (kDebugMode) print('getUserInviteCode error: $e');
      return null;
    }
  }

  Future<bool> pairWithPartner(String partnerCode) async {
    final user = currentUser;
    if (user == null) return false;

    try {
      // Find partner by invite code
      final query = await _firestore
          .collection('users')
          .where('inviteCode', isEqualTo: partnerCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;

      final partnerDoc = query.docs.first;
      final partnerId = partnerDoc.id;

      if (partnerId == user.uid) return false;

      // Create a unique coupleId
      final coupleId = '${user.uid}_$partnerId';

      // Update both users
      final batch = _firestore.batch();
      batch.update(_firestore.collection('users').doc(user.uid), {
        'partnerId': partnerId,
        'coupleId': coupleId,
      });
      batch.update(_firestore.collection('users').doc(partnerId), {
        'partnerId': user.uid,
        'coupleId': coupleId,
      });

      // Initialize couple document
      batch.set(_firestore.collection('couples').doc(coupleId), {
        'uids': [user.uid, partnerId],
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      if (kDebugMode) print('pairWithPartner error: $e');
      return false;
    }
  }

  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;
    
    final userRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await userRef.get();
    
    // Generate a unique 6-character invite code if doesn't exist
    String? existingCode;
    if (snapshot.exists) {
      existingCode = snapshot.data()?['inviteCode'] as String?;
    }

    if (existingCode == null || existingCode.isEmpty) {
      final inviteCode = _generateRandomCode(6);
      
      await userRef.set({
        'uid': user.uid,
        'displayName': user.displayName ?? 'Người dùng',
        'email': user.email,
        'photoUrl': user.photoURL,
        'inviteCode': inviteCode,
        'partnerId': snapshot.data()?['partnerId'],
        'coupleId': snapshot.data()?['coupleId'],
        'createdAt': snapshot.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // Just update basic info if doc exists and has code
      await userRef.update({
        'displayName': user.displayName ?? 'Người dùng',
        'photoUrl': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }
}
