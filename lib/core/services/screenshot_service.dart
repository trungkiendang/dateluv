import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';

class ScreenshotService {
  static final ScreenshotService _instance = ScreenshotService._internal();
  factory ScreenshotService() => _instance;
  ScreenshotService._internal();

  final ScreenshotController screenshotController = ScreenshotController();

  Future<XFile> captureAndSave(Widget widget, {Locale? locale, bool isDarkMode = true}) async {
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

    final Uint8List? imageBytes = await screenshotController.captureFromWidget(
      wrappedWidget,
      delay: const Duration(seconds: 1),
      pixelRatio: 3.0,
    );

    if (imageBytes == null) throw Exception('Không thể tạo ảnh chụp màn hình');

    final fileName = 'share_memory_${DateTime.now().millisecondsSinceEpoch}.png';

    if (kIsWeb) {
      return XFile.fromData(imageBytes, name: fileName, mimeType: 'image/png');
    }

    final directory = await getTemporaryDirectory();
    final imageFile = io.File('${directory.path}/$fileName');
    await imageFile.writeAsBytes(imageBytes);
    return XFile(imageFile.path);
  }
}
