import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/screenshot_service.dart';
import '../../core/theme/app_theme.dart';
import './share_card_widget.dart';
import '../../data/models/couple_profile.dart';
import '../../data/models/diary_entry.dart';

class ShareBottomSheet extends StatefulWidget {
  final CoupleProfile profile;
  final int daysTogether;
  final DiaryEntry? entry;

  const ShareBottomSheet({
    super.key, 
    required this.profile, 
    required this.daysTogether,
    this.entry,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  late ShareTemplate _selectedTemplate;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _selectedTemplate = widget.entry != null ? ShareTemplate.memory : ShareTemplate.classic;
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSharing = true);
    try {
      final card = ShareCardWidget(
        profile: widget.profile,
        template: _selectedTemplate,
        daysTogether: widget.daysTogether,
        entry: widget.entry,
      );
      
      final file = await ScreenshotService().captureAndSave(card);
      
      String shareText = l10n.shareMessage(widget.daysTogether);
      if (widget.entry != null && _selectedTemplate == ShareTemplate.memory) {
        shareText = '${widget.entry!.title} ❤️ #DateLuv';
      }

      await Share.shareXFiles(
        [XFile(file.path)], 
        text: shareText
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.shareError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templates = widget.entry != null 
        ? ShareTemplate.values 
        : ShareTemplate.values.where((t) => t != ShareTemplate.memory).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            l10n.shareMemories,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.shareDescription,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          Row(
            children: templates.map((t) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTemplate = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _selectedTemplate == t ? const LinearGradient(colors: AppColors.primaryGradient) : null,
                    color: _selectedTemplate == t ? null : AppColors.darkCard,
                    border: Border.all(
                      color: _selectedTemplate == t ? Colors.white30 : AppColors.darkBorder,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _selectedTemplate == t ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        t == ShareTemplate.classic ? Icons.dashboard_outlined :
                        t == ShareTemplate.sideBySide ? Icons.view_column_outlined : 
                        t == ShareTemplate.poster ? Icons.portrait_outlined : Icons.auto_awesome_outlined,
                        color: _selectedTemplate == t ? Colors.white : AppColors.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTemplateName(t),
                        style: TextStyle(
                          color: _selectedTemplate == t ? Colors.white : AppColors.textMuted,
                          fontWeight: _selectedTemplate == t ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: _isSharing ? null : _share,
              child: _isSharing 
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.ios_share, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.createAndShare, style: const TextStyle(letterSpacing: 0.5)),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTemplateName(ShareTemplate t) {
    switch (t) {
      case ShareTemplate.classic: return 'Cổ điển';
      case ShareTemplate.sideBySide: return 'Đôi lứa';
      case ShareTemplate.poster: return 'Poster';
      case ShareTemplate.memory: return 'Kỷ niệm';
    }
  }
}
