import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/couple_profile.dart';
import '../../data/models/diary_entry.dart';
import '../../data/models/milestone.dart';
import 'storage_service.dart';

class SyncService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  StorageService get _storageService => StorageService();

  String? get currentUid {
    try {
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  /// Get couple ID associated with current user
  Future<String?> getCoupleId() async {
    final uid = currentUid;
    if (uid == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['coupleId'] as String?;
    } catch (e) {
      if (kDebugMode) print('SyncService getCoupleId error: $e');
      return null;
    }
  }

  /// Get current user's invite code
  Future<String?> getInviteCode() async {
    if (currentUid == null) return null;
    final doc = await _firestore.collection('users').doc(currentUid).get();
    return doc.data()?['inviteCode'] as String?;
  }

  /// Link couple using invite code
  Future<bool> linkWithPartner(String inviteCode) async {
    if (currentUid == null) return false;

    // Find partner with this code
    final qs = await _firestore
        .collection('users')
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .limit(1)
        .get();

    if (qs.docs.isEmpty) return false; // Code not found
    final partnerDoc = qs.docs.first;
    final partnerId = partnerDoc.id;

    if (partnerId == currentUid) return false; // Can't link with self

    // Create couple document
    final coupleRef = _firestore.collection('couples').doc();
    final batch = _firestore.batch();

    batch.set(coupleRef, {
      'members': [currentUid, partnerId],
      'createdAt': FieldValue.serverTimestamp(),
      'startDate': FieldValue.serverTimestamp(), // Default, can be changed later
    });

    // Update both users
    batch.update(_firestore.collection('users').doc(currentUid), {
      'partnerId': partnerId,
      'coupleId': coupleRef.id,
    });
    batch.update(_firestore.collection('users').doc(partnerId), {
      'partnerId': currentUid,
      'coupleId': coupleRef.id,
    });

    await batch.commit();
    return true;
  }

  /// Khởi tạo listener dữ liệu hồ sơ đôi
  Stream<CoupleProfile?> streamCoupleProfile(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return CoupleProfile(
        person1Name: data['person1Name'] ?? '',
        person2Name: data['person2Name'] ?? '',
        startDate: (data['startDate'] as Timestamp).toDate(),
        isDarkMode: data['isDarkMode'] ?? true,
        backgroundImagePath: data['backgroundImagePath'],
        // Lưu ý: person1PhotoPath và person2PhotoPath thường là local path,
        // trong phiên bản này chúng ta tập trung vào metadata trước.
      );
    });
  }

  /// Push couple profile lên Cloud
  Future<void> syncCoupleProfile(String coupleId, CoupleProfile profile) async {
    await _firestore.collection('couples').doc(coupleId).set({
      'person1Name': profile.person1Name,
      'person2Name': profile.person2Name,
      'startDate': Timestamp.fromDate(profile.startDate),
      'isDarkMode': profile.isDarkMode,
      'backgroundImagePath': profile.backgroundImagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Khởi tạo listener dữ liệu nhật ký
  Stream<List<DiaryEntry>> streamDiaryEntries(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('diary')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return DiaryEntry(
                id: doc.id,
                title: data['title'] ?? '',
                content: data['content'] ?? '',
                date: (data['date'] as Timestamp).toDate(),
                imagePaths: List<String>.from(data['imagePaths'] ?? []),
                emoji: data['emoji'] ?? '❤️',
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );
            }).toList());
  }

  /// Khởi tạo listener sự kiện
  Stream<List<Milestone>> streamMilestones(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('milestones')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Milestone(
                id: doc.id,
                title: data['title'] ?? '',
                date: (data['date'] as Timestamp).toDate(),
                description: data['description'],
                icon: data['icon'] ?? '🎉',
                isAutoGenerated: data['isAutoGenerated'] ?? false,
                reminderEnabled: data['reminderEnabled'] ?? false,
                reminderDaysBefore: data['reminderDaysBefore'] ?? 1,
              );
            }).toList());
  }

  /// Push 1 diary entry lên Cloud
  Future<void> syncDiaryEntry(String coupleId, DiaryEntry entry) async {
    // 1. Upload new photos to Firebase Storage
    List<String> remoteImagePaths = await _storageService.uploadPhotos(
      coupleId, 
      entry.imagePaths,
    );
    
    // 2. Save to Firestore with updated remote URLs
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('diary')
        .doc(entry.id)
        .set({
      'title': entry.title,
      'content': entry.content,
      'date': Timestamp.fromDate(entry.date),
      'imagePaths': remoteImagePaths, // New uploaded URLs
      'emoji': entry.emoji,
      'createdAt': Timestamp.fromDate(entry.createdAt),
      'syncedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Xóa 1 diary entry trên Cloud
  Future<void> deleteDiaryEntry(String coupleId, String entryId) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('diary')
        .doc(entryId)
        .delete();
  }

  /// Push 1 milestone lên Cloud
  Future<void> syncMilestone(String coupleId, Milestone milestone) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('milestones')
        .doc(milestone.id)
        .set({
      'title': milestone.title,
      'date': Timestamp.fromDate(milestone.date),
      'description': milestone.description,
      'icon': milestone.icon,
      'isAutoGenerated': milestone.isAutoGenerated,
      'reminderEnabled': milestone.reminderEnabled,
      'reminderDaysBefore': milestone.reminderDaysBefore,
      'syncedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Xóa 1 milestone trên Cloud
  Future<void> deleteMilestone(String coupleId, String milestoneId) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('milestones')
        .doc(milestoneId)
        .delete();
  }
}
