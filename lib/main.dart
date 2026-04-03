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

  print('APP_LOG: Starting main()...');

  // Hệ thống thanh trạng thái trong suốt
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  print('APP_LOG: Initializing Notifications...');
  // Initialize notifications
  await NotificationService().init();

  print('APP_LOG: Initializing Firebase...');
  // Initialize Firebase
  await FirebaseService.init();

  print('APP_LOG: Setting Orientations...');
  // Khóa hướng màn hình (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  print('APP_LOG: Initializing Hive...');
  // Khởi tạo Hive
  await Hive.initFlutter();

  // Đăng ký adapters
  Hive.registerAdapter(CoupleProfileAdapter());
  Hive.registerAdapter(DiaryEntryAdapter());
  Hive.registerAdapter(MilestoneAdapter());

  print('APP_LOG: Opening Hive boxes...');
  // Mở các boxes
  await Hive.openBox<CoupleProfile>(AppConstants.hiveBoxCouple);
  await Hive.openBox<DiaryEntry>(AppConstants.hiveBoxDiary);
  await Hive.openBox<Milestone>(AppConstants.hiveBoxMilestones);
  await Hive.openBox(AppConstants.hiveBoxSettings);

  print('APP_LOG: Initializing AppProvider...');
  // Tạo provider và init
  final appProvider = AppProvider();
  await appProvider.init();

  print('APP_LOG: Running App...');
  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const DateLuvApp(),
    ),
  );

  print('APP_LOG: Removing Splash Screen...');
  FlutterNativeSplash.remove();
}
