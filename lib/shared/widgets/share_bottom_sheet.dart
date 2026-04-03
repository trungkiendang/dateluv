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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chia sẻ: $e')),
        );
      }
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isSharing ? null : _share,
              child: Text(_isSharing ? 'Đang tạo...' : 'Chia sẻ ngay'),
            ),
          ),
        ],
      ),
    );
  }
}
