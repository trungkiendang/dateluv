# Memories Photo & Share Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a modern minimalist share card generator and integrate system image picking for Google Photos/Gallery access.

**Architecture:** Use the `screenshot` package to capture a hidden `ShareCardWidget` containing the couple's data. Provide 3 minimalist templates. Use `share_plus` for system-level sharing.

**Tech Stack:** Flutter, `screenshot`, `share_plus`, `path_provider`, `image_picker`.

---

### Task 1: Dependencies & Infrastructure

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/services/screenshot_service.dart`

- [ ] **Step 1: Add `screenshot` dependency**
Modify `pubspec.yaml` to include the `screenshot` package.
```yaml
dependencies:
  # ... existing
  screenshot: ^3.0.0
```
Run: `flutter pub get`

- [ ] **Step 2: Create `ScreenshotService`**
Implement a singleton to handle capturing widgets.
```dart
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
```

- [ ] **Step 3: Commit**
```bash
git add pubspec.yaml lib/core/services/screenshot_service.dart
git commit -m "feat: add screenshot dependency and service"
```

---

### Task 2: Share Card Templates

**Files:**
- Create: `lib/shared/widgets/share_card_widget.dart`

- [ ] **Step 1: Implement `ShareCardWidget` with 3 templates**
Create the UI for the shareable card.
```dart
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
      default:
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
```

- [ ] **Step 2: Commit**
```bash
git add lib/shared/widgets/share_card_widget.dart
git commit -m "feat: add ShareCardWidget with 3 templates"
```

---

### Task 3: Share Integration & BottomSheet

**Files:**
- Create: `lib/shared/widgets/share_bottom_sheet.dart`
- Modify: `lib/features/home/home_screen.dart`

- [ ] **Step 1: Create `ShareBottomSheet`**
Implement the UI to select templates and trigger sharing.
```dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/screenshot_service.dart';
import './share_card_widget.dart';
import '../../data/models/couple_profile.dart';

class ShareBottomSheet extends StatefulWidget {
  final CoupleProfile profile;
  final int daysTogether;

  const ShareBottomSheet({super.key, required this.profile, required this.daysTogether});

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  ShareTemplate _selectedTemplate = ShareTemplate.classic;
  bool _isSharing = false;

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      final card = ShareCardWidget(
        profile: widget.profile,
        template: _selectedTemplate,
        daysTogether: widget.daysTogether,
      );
      
      final file = await ScreenshotService().captureAndSave(card);
      await Share.shareXFiles([XFile(file.path)], text: 'Kỷ niệm tình yêu của chúng mình ❤️');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A0A14),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Chọn mẫu thiệp', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ShareTemplate.values.map((t) => GestureDetector(
              onTap: () => setState(() => _selectedTemplate = t),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: _selectedTemplate == t ? Colors.pink : Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(t.name.toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSharing ? null : _share,
            child: Text(_isSharing ? 'Đang tạo...' : 'Chia sẻ ngay'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add Share button to `HomeScreen`**
Update `HomeScreen` to include the share trigger.
```dart
// Inside HomeScreen build or appBar
IconButton(
  icon: const Icon(Icons.share_outlined),
  onPressed: () {
    final provider = context.read<AppProvider>();
    if (provider.hasProfile) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ShareBottomSheet(
          profile: provider.coupleProfile!,
          daysTogether: DateTime.now().difference(provider.coupleProfile!.startDate).inDays,
        ),
      );
    }
  },
)
```

- [ ] **Step 3: Commit**
```bash
git add lib/shared/widgets/share_bottom_sheet.dart lib/features/home/home_screen.dart
git commit -m "feat: integrate share functionality into home screen"
```
