import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/couple_profile.dart';

enum ShareTemplate { classic, sideBySide, poster }

class ShareCardWidget extends StatelessWidget {
  final CoupleProfile profile;
  final ShareTemplate template;
  final int daysTogether;

  const ShareCardWidget({
    super.key,
    required this.profile,
    required this.template,
    required this.daysTogether,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        image: profile.backgroundImagePath != null
            ? DecorationImage(
                image: FileImage(File(profile.backgroundImagePath!)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: _buildTemplate(),
    );
  }

  Widget _buildTemplate() {
    switch (template) {
      case ShareTemplate.sideBySide:
        return _buildSideBySide();
      case ShareTemplate.poster:
        return _buildPoster();
      case ShareTemplate.classic:
        return _buildClassic();
    }
  }

  Widget _buildClassic() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${profile.person1Name} ❤️ ${profile.person2Name}',
          style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 100),
        Text(
          '$daysTogether',
          style: const TextStyle(fontSize: 200, color: AppColors.primary, fontWeight: FontWeight.w900),
        ),
        const Text(
          'NGÀY BÊN NHAU',
          style: TextStyle(fontSize: 40, color: Colors.white70, letterSpacing: 10),
        ),
      ],
    );
  }

  Widget _buildSideBySide() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 _avatar(profile.person1PhotoPath),
                 const Padding(
                   padding: EdgeInsets.symmetric(horizontal: 40),
                   child: Icon(Icons.favorite, color: AppColors.primary, size: 80),
                 ),
                 _avatar(profile.person2PhotoPath),
               ],
             ),
             const SizedBox(height: 60),
             Text(
                '$daysTogether Days',
                style: const TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.w800),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster() {
     return Stack(
       children: [
         Positioned(
           bottom: 100,
           left: 100,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 '$daysTogether',
                 style: const TextStyle(fontSize: 300, color: Colors.white, fontWeight: FontWeight.w900, height: 0.8),
               ),
               const Text(
                 'DAYS OF LOVE',
                 style: TextStyle(fontSize: 60, color: AppColors.primary, fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 40),
               Text(
                 '${profile.person1Name} & ${profile.person2Name}',
                 style: const TextStyle(fontSize: 40, color: Colors.white70),
               ),
             ],
           ),
         ),
       ],
     );
  }

  Widget _avatar(String? path) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 8),
        image: path != null
            ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover)
            : null,
      ),
    );
  }
}
