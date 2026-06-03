import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;

Widget appImage(String? path, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
  double borderRadius = 0,
  Color? placeholderColor,
}) {
  if (path == null || path.isEmpty) {
    return _placeholder(width, height, placeholderColor);
  }
  if (kIsWeb || path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(width, height, placeholderColor),
        loadingBuilder: (_, child, progress) => progress == null ? child : _placeholder(width, height, placeholderColor),
      ),
    );
  }
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: Image.file(
      io.File(path),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(width, height, placeholderColor),
    ),
  );
}

DecorationImage? appDecorationImage(String? path, {ColorFilter? colorFilter, BoxFit fit = BoxFit.cover}) {
  if (path == null || path.isEmpty) return null;
  if (kIsWeb || path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
    return DecorationImage(
      image: NetworkImage(path),
      fit: fit,
      colorFilter: colorFilter,
    );
  }
  final file = io.File(path);
  return DecorationImage(
    image: FileImage(file),
    fit: fit,
    colorFilter: colorFilter,
  );
}

Widget _placeholder(double? width, double? height, Color? color) {
  return Container(
    width: width,
    height: height,
    color: color ?? Colors.grey.withValues(alpha: 0.2),
    child: const Icon(Icons.image, color: Colors.white24),
  );
}
