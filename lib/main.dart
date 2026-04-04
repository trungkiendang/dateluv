import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'data/models/couple_profile.dart';
import 'data/models/diary_entry.dart';
import 'data/models/milestone.dart';
import 'data/repositories/app_provider.dart';
import 'core/constants/app_constants.dart';
import 'app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    print('APP_LOG: Starting initialization...');

    // Hệ thống thanh trạng thái trong suốt
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 1. Initialize Firebase FIRST and alone
    print('APP_LOG: Initializing Firebase...');
    await FirebaseService.init();

    // 2. Initialize other services in parallel
    print('APP_LOG: Initializing other services...');
    await Future.wait([
      _safeInit('Notifications', () => NotificationService().init()),
      _safeInit('Hive', () async {
        await Hive.initFlutter();
        Hive.registerAdapter(CoupleProfileAdapter());
        Hive.registerAdapter(DiaryEntryAdapter());
        Hive.registerAdapter(MilestoneAdapter());
        
        await Hive.openBox<CoupleProfile>(AppConstants.hiveBoxCouple);
        await Hive.openBox<DiaryEntry>(AppConstants.hiveBoxDiary);
        await Hive.openBox<Milestone>(AppConstants.hiveBoxMilestones);
        await Hive.openBox(AppConstants.hiveBoxSettings);
      }),
    ]);

    // Khóa hướng màn hình
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    print('APP_LOG: Initializing AppProvider...');
    final appProvider = AppProvider();
    await appProvider.init().timeout(
      const Duration(seconds: 10),
      onTimeout: () => print('APP_LOG: AppProvider init timed out, continuing...'),
    );

    print('APP_LOG: Running App...');
    runApp(
      ChangeNotifierProvider.value(
        value: appProvider,
        child: const DateLuvApp(),
      ),
    );
  } catch (e, stack) {
    print('APP_LOG: CRITICAL ERROR DURING INIT: $e');
    print(stack);
    
    // Fallback: Run app even if init failed partially
    runApp(
      ChangeNotifierProvider(
        create: (_) => AppProvider()..init(),
        child: const DateLuvApp(),
      ),
    );
  } finally {
    print('APP_LOG: Removing Splash Screen...');
    FlutterNativeSplash.remove();
  }
}

Future<void> _safeInit(String name, Future<void> Function() initFunc) async {
  try {
    print('APP_LOG: Initializing $name...');
    await initFunc();
  } catch (e) {
    print('APP_LOG: Error initializing $name: $e');
  }
}
