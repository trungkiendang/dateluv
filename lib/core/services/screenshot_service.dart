import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../theme/app_theme.dart';

class ScreenshotService {
  static final ScreenshotService _instance = ScreenshotService._internal();
  factory ScreenshotService() => _instance;
  ScreenshotService._internal();

  final ScreenshotController screenshotController = ScreenshotController();

  Future<File> captureAndSave(Widget widget, {Locale? locale, bool isDarkMode = true}) async {
    // Wrap widget with complete context using standard logical sizes (360x640)
    final wrappedWidget = MediaQuery(
      data: const MediaQueryData(
        size: Size(360, 640),
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        devicePixelRatio: 3.0, 
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
        locale: locale ?? const Locale('vi'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi'),
          Locale('en'),
        ],
        home: Scaffold(
          backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
          body: widget,
        ),
      ),
    );

    // Using captureFromWidget with a generous delay to ensure Google Fonts and background images are loaded
    final Uint8List? imageBytes = await screenshotController.captureFromWidget(
      wrappedWidget,
      delay: const Duration(seconds: 1), // 1 second to ensure high-quality rendering
      pixelRatio: 3.0, // Enough for high quality without being overly huge
    );

    if (imageBytes == null) throw Exception('Không thể tạo ảnh chụp màn hình');

    final directory = await getTemporaryDirectory();
    final String fileName = 'share_memory_${DateTime.now().millisecondsSinceEpoch}.png';
    final File imageFile = File('${directory.path}/$fileName');
    await imageFile.writeAsBytes(imageBytes);
    return imageFile;
  }
}

