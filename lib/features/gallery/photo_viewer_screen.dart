import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';

class PhotoViewerScreen extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _sharePhoto() async {
    final path = widget.imagePaths[_currentIndex];
    final box = context.findRenderObject() as RenderBox?;
    final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    if (path.startsWith('http')) {
      await Share.share(
        path, 
        subject: 'Date Luv - Kỷ niệm đẹp của chúng tôi 💕',
        sharePositionOrigin: rect,
      );
    } else {
      await Share.shareXFiles(
        [XFile(path)], 
        text: 'Date Luv - Kỷ niệm đẹp của chúng tôi 💕',
        sharePositionOrigin: rect,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo gallery
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.imagePaths.length,
            builder: (context, i) {
              final isNetwork = widget.imagePaths[i].startsWith('http');
              return PhotoViewGalleryPageOptions(
                imageProvider: isNetwork 
                    ? CachedNetworkImageProvider(widget.imagePaths[i]) as ImageProvider
                    : FileImage(File(widget.imagePaths[i])) as ImageProvider,
                heroAttributes: PhotoViewHeroAttributes(tag: 'photo_$i'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              );
            },
            onPageChanged: (i) => setState(() => _currentIndex = i),
            loadingBuilder: (_, __) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_currentIndex + 1} / ${widget.imagePaths.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _sharePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
