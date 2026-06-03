import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_image.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/diary_entry.dart';
import '../../data/repositories/app_provider.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/share_bottom_sheet.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedEmoji;

  List<DiaryEntry> _filterEntries(List<DiaryEntry> entries) {
    var filtered = entries;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) =>
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.content.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedEmoji != null) {
      filtered = filtered.where((e) => e.emoji == _selectedEmoji).toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final entries = _filterEntries(provider.diaryEntries);
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
                        '${l10n.diary} ❤️',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/diary/new'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: AppColors.primaryGradient),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Emoji filter
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _EmojiChip(
                        label: l10n.all,
                        isSelected: _selectedEmoji == null,
                        onTap: () => setState(() => _selectedEmoji = null),
                      ),
                      ...['❤️', '😍', '🥰', '😊', '🌹', '💕', '😘', '✨', '🎉', '🌙'].map((e) =>
                        _EmojiChip(
                          label: e,
                          isSelected: _selectedEmoji == e,
                          onTap: () => setState(() => _selectedEmoji = _selectedEmoji == e ? null : e),
                        )),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Entries list
                Expanded(
                  child: entries.isEmpty
                      ? _buildEmpty(provider.diaryEntries.isEmpty, l10n)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: entries.length,
                          itemBuilder: (_, i) => _DiaryCard(
                            entry: entries[i],
                            l10n: l10n,
                            onTap: () => context.push('/diary/edit', extra: entries[i]),
                            onDelete: () => _confirmDelete(context, provider, entries[i].id, l10n),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(bool isEmpty, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isEmpty ? '📖' : '🔍',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            isEmpty ? l10n.emptyDiary : l10n.noResults,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEmpty ? l10n.firstMemoryPrompt : l10n.searchAgainPrompt,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppProvider provider, String id, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text(l10n.deleteMilestone, style: const TextStyle(color: Colors.white)), // Reusing milestone delete title
        content: Text(l10n.confirmDeleteDiary, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteDiaryEntry(id);
    }
  }
}

class _EmojiChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmojiChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: label.length > 2 ? 13 : 18,
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DiaryCard({
    required this.entry,
    required this.l10n,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(entry.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          DateHelper.formatDateFriendly(entry.date, l10n),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      final provider = context.read<AppProvider>();
                      if (provider.hasProfile) {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => ShareBottomSheet(
                            profile: provider.coupleProfile!,
                            daysTogether: DateTime.now().difference(provider.coupleProfile!.startDate).inDays,
                            entry: entry,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.share_outlined, color: AppColors.textMuted, size: 18),
                    ),
                  ),
                ],
              ),
              if (entry.content.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  entry.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (entry.imagePaths.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.imagePaths.length,
                    itemBuilder: (_, i) => Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: appImage(entry.imagePaths[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
