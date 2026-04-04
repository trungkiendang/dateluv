import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/milestone.dart';
import '../../data/repositories/app_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final upcoming = provider.upcomingMilestones;
        final passed = provider.passedMilestones;
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
                        '${l10n.milestones} ✨',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/milestone/new'),
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

                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textMuted,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      tabs: [
                        Tab(text: l10n.upcoming),
                        Tab(text: l10n.passed),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMilestoneList(upcoming, true, provider, l10n),
                      _buildMilestoneList(passed, false, provider, l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMilestoneList(List<Milestone> milestones, bool isUpcoming, AppProvider provider, AppLocalizations l10n) {
    if (milestones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isUpcoming ? '📅' : '⏳', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? l10n.noUpcoming : l10n.noPassed,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final isLast = index == milestones.length - 1;

        // Get localized title for auto-generated milestones
        String displayTitle = milestone.title;
        if (milestone.isAutoGenerated) {
          final daysMatch = RegExp(r'auto_(\d+)').firstMatch(milestone.id);
          if (daysMatch != null) {
            final days = int.parse(daysMatch.group(1)!);
            if (days >= 365) {
              displayTitle = l10n.milestoneYearsTogether(days ~/ 365);
            } else {
              displayTitle = l10n.milestoneDaysTogether(days);
            }
          }
        }

        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: index == 0,
          isLast: isLast,
          indicatorStyle: IndicatorStyle(
            width: 40,
            height: 40,
            indicator: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(milestone.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
          ),
          beforeLineStyle: const LineStyle(color: AppColors.darkBorder, thickness: 2),
          endChild: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 20, top: 10),
            child: GestureDetector(
              onTap: () {
                if (!milestone.isAutoGenerated) {
                  context.push('/milestone/edit', extra: milestone);
                }
              },
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (milestone.isAutoGenerated)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                            ),
                            child: Text(l10n.autoGenerated, style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
                          ),
                        if (!milestone.isAutoGenerated)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 18),
                            onPressed: () => _confirmDelete(context, provider, milestone.id, l10n),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateHelper.formatDate(milestone.date, l10n.localeName),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    _buildCountdown(milestone.date, isUpcoming, l10n),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountdown(DateTime date, bool isUpcoming, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = isUpcoming ? date.difference(now).inDays : now.difference(date).inDays;

    String text = '';
    if (isUpcoming) {
      if (difference == 0) text = l10n.today;
      else if (difference == 1) text = l10n.tomorrow;
      else text = l10n.daysLeft(difference);
    } else {
      text = l10n.daysAgo(difference);
    }

    return Row(
      children: [
        Icon(
          isUpcoming ? Icons.timer_outlined : Icons.check_circle_outline,
          size: 14,
          color: isUpcoming ? AppColors.primary : Colors.greenAccent,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isUpcoming ? AppColors.primary : Colors.greenAccent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppProvider provider, String id, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text(l10n.deleteMilestone, style: const TextStyle(color: Colors.white)),
        content: Text(l10n.confirmDeleteMilestone, style: const TextStyle(color: Colors.white70)),
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
      await provider.deleteMilestone(id);
    }
  }
}
