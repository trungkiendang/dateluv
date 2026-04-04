import 'dart:io';
import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/couple_profile.dart';
import '../../data/models/diary_entry.dart';

enum ShareTemplate { classic, sideBySide, poster, memory }

class ShareCardWidget extends StatelessWidget {
  final CoupleProfile profile;
  final ShareTemplate template;
  final int daysTogether;
  final DiaryEntry? entry;

  const ShareCardWidget({
    super.key,
    required this.profile,
    required this.template,
    required this.daysTogether,
    this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        height: 640,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          image: _getBackgroundImage(),
        ),
        child: _buildTemplate(l10n),
      ),
    );
  }

  DecorationImage? _getBackgroundImage() {
    if (profile.backgroundImagePath == null) return null;
    final file = File(profile.backgroundImagePath!);
    if (!file.existsSync()) return null;
    
    return DecorationImage(
      image: FileImage(file),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.6),
        BlendMode.darken,
      ),
    );
  }

  Widget _buildTemplate(AppLocalizations l10n) {
    switch (template) {
      case ShareTemplate.sideBySide:
        return _buildSideBySide(l10n);
      case ShareTemplate.poster:
        return _buildPoster(l10n);
      case ShareTemplate.memory:
        return _buildMemory(l10n);
      case ShareTemplate.classic:
        return _buildClassic(l10n);
    }
  }

  Widget _buildClassic(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${profile.person1Name} ❤️ ${profile.person2Name}',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 24, 
              color: Colors.white, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '$daysTogether',
            style: GoogleFonts.nunito(
              fontSize: 100, 
              color: AppColors.primary, 
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          Text(
            l10n.daysTogether.toUpperCase(),
            style: GoogleFonts.nunito(
              fontSize: 18, 
              color: Colors.white70, 
              letterSpacing: 4,
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySide(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 _avatar(profile.person1PhotoPath, size: 100),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   child: ShaderMask(
                     shaderCallback: (bounds) => const LinearGradient(
                       colors: AppColors.primaryGradient,
                     ).createShader(bounds),
                     child: const Icon(Icons.favorite, color: Colors.white, size: 40),
                   ),
                 ),
                 _avatar(profile.person2PhotoPath, size: 100),
               ],
             ),
             const SizedBox(height: 32),
             Text(
                '$daysTogether ${l10n.days}',
                style: GoogleFonts.nunito(
                  fontSize: 48, 
                  color: Colors.white, 
                  fontWeight: FontWeight.w900
                ),
             ),
             const SizedBox(height: 8),
             Text(
                '${profile.person1Name} & ${profile.person2Name}',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16, 
                  color: Colors.white70,
                  letterSpacing: 1
                ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(AppLocalizations l10n) {
     return Stack(
       children: [
         Positioned(
           bottom: 60,
           left: 30,
           right: 30,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 '$daysTogether',
                 style: GoogleFonts.nunito(
                   fontSize: 120, 
                   color: Colors.white, 
                   fontWeight: FontWeight.w900, 
                   height: 0.8
                 ),
               ),
               Text(
                 l10n.journeyBegins.split('\n').first.toUpperCase(),
                 style: GoogleFonts.nunito(
                   fontSize: 24, 
                   color: AppColors.primary, 
                   fontWeight: FontWeight.w800,
                   letterSpacing: 2
                 ),
               ),
               const SizedBox(height: 16),
               Container(
                 height: 3,
                 width: 80,
                 color: AppColors.primary,
               ),
               const SizedBox(height: 20),
               Text(
                 '${profile.person1Name} & ${profile.person2Name}',
                 style: GoogleFonts.nunito(
                   fontSize: 20, 
                   color: Colors.white.withValues(alpha: 0.9),
                   fontWeight: FontWeight.w600
                 ),
               ),
             ],
           ),
         ),
       ],
     );
  }

  Widget _buildMemory(AppLocalizations l10n) {
    if (entry == null) return _buildClassic(l10n);
    
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 40),
          if (entry!.imagePaths.isNotEmpty)
             ClipRRect(
               borderRadius: BorderRadius.circular(20),
               child: Image.file(
                 File(entry!.imagePaths.first), 
                 height: 300, 
                 width: double.infinity, 
                 fit: BoxFit.cover
               ),
             ),
          const SizedBox(height: 30),
          Text(entry!.emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(
            entry!.title, 
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 28, 
              fontWeight: FontWeight.w900, 
              color: Colors.white,
              height: 1.2
            )
          ),
          const SizedBox(height: 16),
          Text(
            entry!.content, 
            textAlign: TextAlign.center, 
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.7), 
              fontSize: 16,
              height: 1.5
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              DateHelper.formatDate(entry!.date, l10n.localeName), 
              style: const TextStyle(
                color: AppColors.primary, 
                fontWeight: FontWeight.w800,
                letterSpacing: 1
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String? path, {double size = 80}) {
    DecorationImage? image;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        image = DecorationImage(image: FileImage(file), fit: BoxFit.cover);
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
          )
        ],
        image: image,
        color: AppColors.darkCard,
      ),
      child: image == null 
        ? Icon(Icons.person, size: size * 0.5, color: Colors.white24) 
        : null,
    );
  }
}
