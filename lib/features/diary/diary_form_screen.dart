import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/diary_entry.dart';
import '../../data/repositories/app_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class DiaryFormScreen extends StatefulWidget {
  final DiaryEntry? entry;
  const DiaryFormScreen({super.key, this.entry});

  @override
  State<DiaryFormScreen> createState() => _DiaryFormScreenState();
}

class _DiaryFormScreenState extends State<DiaryFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedEmoji = '❤️';
  List<String> _imagePaths = [];
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _isEdit = true;
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _selectedDate = widget.entry!.date;
      _selectedEmoji = widget.entry!.emoji;
      _imagePaths = List.from(widget.entry!.imagePaths);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(maxWidth: 1000, imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(images.map((e) => e.path));
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterTitle)),
      );
      return;
    }

    final provider = context.read<AppProvider>();
    final entry = DiaryEntry(
      id: _isEdit ? widget.entry!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: _selectedDate,
      imagePaths: _imagePaths,
      emoji: _selectedEmoji,
      createdAt: _isEdit ? widget.entry!.createdAt : DateTime.now(),
    );

    if (_isEdit) {
      await provider.updateDiaryEntry(entry);
    } else {
      await provider.addDiaryEntry(entry);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.darkBgGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        _isEdit ? l10n.diary : l10n.addMemory,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: _save,
                      child: Text(
                        l10n.save,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji & Date row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showEmojiPicker(l10n),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.darkCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.darkBorder),
                              ),
                              child: Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.darkCard,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.darkBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateHelper.formatDate(_selectedDate, l10n.localeName),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Title
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        decoration: InputDecoration(
                          hintText: l10n.enterTitle,
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Content
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                        decoration: InputDecoration(
                          hintText: l10n.diaryHint,
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.15)),
                          border: InputBorder.none,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Images
                      if (_imagePaths.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagePaths.length + 1,
                            itemBuilder: (context, index) {
                              if (index == _imagePaths.length) {
                                return _buildAddImageBtn();
                              }
                              return Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.darkBorder),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(File(_imagePaths[index]), fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _imagePaths.removeAt(index)),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            decoration: BoxDecoration(
                              color: AppColors.darkCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.darkBorder, style: BorderStyle.solid),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary.withValues(alpha: 0.5), size: 48),
                                const SizedBox(height: 12),
                                Text(l10n.choosePhoto, style: const TextStyle(color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageBtn() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted),
      ),
    );
  }

  void _showEmojiPicker(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.chooseEmotion, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: ['❤️', '😍', '🥰', '😊', '🌹', '💕', '😘', '✨', '🎉', '🌙', '⭐', '🌈', '💫', '🎊', '🌸', '🦋']
                  .map((e) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedEmoji = e);
                          Navigator.pop(context);
                        },
                        child: Text(e, style: const TextStyle(fontSize: 32)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
