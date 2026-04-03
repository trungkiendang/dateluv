import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/app_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final photos = provider.allPhotoPaths;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: isDark
              ? const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.darkBgGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                )
              : null,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        '${l10n.gallery} 📸',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Photos grid
                Expanded(
                  child: photos.isEmpty
                      ? _buildEmpty(l10n)
                      : MasonryGridView.count(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            return _PhotoCard(
                              path: photos[index],
                              index: index,
                              onTap: () {
                                // Full screen view logic could be added here
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🖼️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            l10n.emptyDiary,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.firstMemoryPrompt,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/diary/new'),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(l10n.addMemory, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String path;
  final int index;
  final VoidCallback onTap;

  const _PhotoCard({required this.path, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'gallery_photo_$index',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
