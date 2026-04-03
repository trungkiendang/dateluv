import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../data/repositories/app_provider.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/share_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Timer? _timer;
  Map<String, int> _timeData = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _startTimer();
  }

  void _startTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final provider = context.read<AppProvider>();
    if (provider.hasProfile) {
      setState(() {
        _timeData = DateHelper.timeTogether(provider.coupleProfile!.startDate);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (!provider.hasProfile) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = provider.coupleProfile!;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            // Background
            _buildBackground(profile, isDark),

            // Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildCoupleSection(profile),
                            const SizedBox(height: 32),
                            _buildCounterSection(),
                            const SizedBox(height: 32),
                            _buildQuickActions(context),
                            const SizedBox(height: 32),
                            _buildUpcomingMilestone(context, provider),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackground(profile, bool isDark) {
    if (profile.backgroundImagePath != null) {
      return Positioned.fill(
        child: Stack(
          children: [
            Image.file(
              File(profile.backgroundImagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.darkBgGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: AppColors.primaryGradient,
            ).createShader(bounds),
            child: const Text(
              'Date Luv',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
          Row(
            children: [
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
                        daysTogether: provider.coupleProfile!.startDate.difference(DateTime.now()).inDays.abs(),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.share_outlined, color: Colors.white70, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.push('/settings'),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoupleSection(profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Person 1
        _buildPersonAvatar(
          name: profile.person1Name,
          photoPath: profile.person1PhotoPath,
          colors: const [Color(0xFFFF6B9D), Color(0xFFFF9EC8)],
        ),

        // Heart in middle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const HeartPulseWidget(size: 36),
              const SizedBox(height: 4),
              Text(
                '${_timeData['totalDays'] ?? 0} ngày',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Person 2
        _buildPersonAvatar(
          name: profile.person2Name,
          photoPath: profile.person2PhotoPath,
          colors: const [Color(0xFFC04FD6), Color(0xFFD975EA)],
        ),
      ],
    );
  }

  Widget _buildPersonAvatar({
    required String name,
    required String? photoPath,
    required List<Color> colors,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: photoPath != null
              ? ClipOval(
                  child: Image.file(File(photoPath), fit: BoxFit.cover),
                )
              : Icon(Icons.person, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCounterSection() {
    final years = _timeData['years'] ?? 0;
    final months = _timeData['months'] ?? 0;
    final days = _timeData['days'] ?? 0;
    final hours = _timeData['hours'] ?? 0;
    final minutes = _timeData['minutes'] ?? 0;
    final seconds = _timeData['seconds'] ?? 0;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Thời gian bên nhau',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CounterBlock(value: DateHelper.twoDigit(years), label: 'Năm'),
              _buildSeparator(),
              CounterBlock(value: DateHelper.twoDigit(months), label: 'Tháng'),
              _buildSeparator(),
              CounterBlock(value: DateHelper.twoDigit(days), label: 'Ngày'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CounterBlock(value: DateHelper.twoDigit(hours), label: 'Giờ'),
              _buildSeparator(),
              CounterBlock(value: DateHelper.twoDigit(minutes), label: 'Phút'),
              _buildSeparator(),
              CounterBlock(value: DateHelper.twoDigit(seconds), label: 'Giây'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Text(
      ':',
      style: TextStyle(
        color: AppColors.primary.withOpacity(0.6),
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_photo_alternate_outlined,
            label: 'Thêm kỷ niệm',
            onTap: () => context.push('/diary/new'),
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.celebration_outlined,
            label: 'Thêm ngày kỷ niệm',
            onTap: () => context.push('/milestone/new'),
            gradient: const [Color(0xFFC04FD6), Color(0xFF7B2FBE)],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingMilestone(BuildContext context, AppProvider provider) {
    final upcoming = provider.upcomingMilestones;
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final next = upcoming.first;
    final daysLeft = DateHelper.daysUntil(next.date);

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(next.icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sắp tới',
                  style: TextStyle(
                    color: AppColors.secondary.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  daysLeft == 0
                      ? 'Hôm nay! 🎉'
                      : daysLeft == 1
                          ? 'Ngày mai!'
                          : 'Còn $daysLeft ngày',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final List<Color> gradient;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
