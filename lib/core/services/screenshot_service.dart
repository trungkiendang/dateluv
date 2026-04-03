import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../theme/app_theme.dart';

class ScreenshotService {
  static final ScreenshotService _instance = ScreenshotService._internal();
  factory ScreenshotService() => _instance;
  ScreenshotService._internal();

  final ScreenshotController screenshotController = ScreenshotController();

  Future<File> captureAndSave(Widget widget) async {
    // Wrap widget with complete context using standard logical sizes (360x640)
    final wrappedWidget = MediaQuery(
      data: const MediaQueryData(
        size: Size(360, 640),
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
        viewInsets: EdgeInsets.zero,
        devicePixelRatio: 4.0, // Result will be 1440x2560
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: AppColors.darkSurface,
          body: widget,
        ),
      ),
    );

    // Using captureFromWidget with a generous delay to ensure Google Fonts and background images are loaded
    final Uint8List? imageBytes = await screenshotController.captureFromWidget(
      wrappedWidget,
      delay: const Duration(seconds: 1), // 1 second to ensure high-quality rendering
      pixelRatio: 4.0,
      context: null, // Avoid using the current context which might not be ready
    );

    if (imageBytes == null) throw Exception('Không thể tạo ảnh chụp màn hình');

    final directory = await getTemporaryDirectory();
    final String fileName = 'share_memory_${DateTime.now().millisecondsSinceEpoch}.png';
    final File imageFile = File('${directory.path}/$fileName');
    await imageFile.writeAsBytes(imageBytes);
    return imageFile;
  }
}

