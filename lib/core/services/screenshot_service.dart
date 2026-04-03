import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ScreenshotService {
  static final ScreenshotService _instance = ScreenshotService._internal();
  factory ScreenshotService() => _instance;
  ScreenshotService._internal();

  final ScreenshotController screenshotController = ScreenshotController();

  Future<File> captureAndSave(Widget widget) async {
    final Uint8List? imageBytes = await screenshotController.captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 100),
      pixelRatio: 3.0,
    );

    if (imageBytes == null) throw Exception('Failed to capture screenshot');

    final directory = await getTemporaryDirectory();
    final String fileName = 'share_memory_${DateTime.now().millisecondsSinceEpoch}.png';
    final File imageFile = File('${directory.path}/$fileName');
    await imageFile.writeAsBytes(imageBytes);
    return imageFile;
  }
}
