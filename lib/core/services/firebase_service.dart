import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<void> init() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
        await Firebase.initializeApp(
          options: defaultTargetPlatform == TargetPlatform.iOS
              ? const FirebaseOptions(
                  apiKey: 'AIzaSyAbDA0F3of6VBTVbF2TpMBpR_Wkorp2LVE',
                  appId: '1:60683918105:ios:42013ad9d3aff08b788388',
                  messagingSenderId: '60683918105',
                  projectId: 'dateluv-372d0',
                  storageBucket: 'dateluv-372d0.firebasestorage.app',
                  iosBundleId: 'com.kun.dateLuv',
                )
              : null, // Android will use google-services.json which is usually correctly linked
        );
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase init error: $e');
      }
    }
  }
}
