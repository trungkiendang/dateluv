import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<void> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        if (kDebugMode) print('APP_LOG: Firebase already initialized');
        return;
      }

      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAbDA0F3of6VBTVbF2TpMBpR_Wkorp2LVE',
            appId: '1:60683918105:web:c47a6055c315c470788388',
            messagingSenderId: '60683918105',
            projectId: 'dateluv-372d0',
            storageBucket: 'dateluv-372d0.firebasestorage.app',
            authDomain: 'dateluv-372d0.firebaseapp.com',
          ),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAbDA0F3of6VBTVbF2TpMBpR_Wkorp2LVE',
            appId: '1:60683918105:ios:42013ad9d3aff08b788388',
            messagingSenderId: '60683918105',
            projectId: 'dateluv-372d0',
            storageBucket: 'dateluv-372d0.firebasestorage.app',
            iosBundleId: 'com.kun.dateLuv',
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      
      // Optimize Firestore settings
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      if (kDebugMode) print('APP_LOG: Firebase initialized successfully');
    } catch (e) {
      if (kDebugMode) {
        print('Firebase init error: $e');
      }
      if (!kIsWeb) {
        rethrow;
      }
    }
  }
}
