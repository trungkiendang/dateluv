import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/couple_profile.dart';
import '../../data/repositories/app_provider.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/app_image.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  final _person1Controller = TextEditingController();
  final _person2Controller = TextEditingController();
  String? _person1Photo;
  String? _person2Photo;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _person1Controller.dispose();
    _person2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(bool isPerson1) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        if (isPerson1) {
          _person1Photo = image.path;
        } else {
          _person2Photo = image.path;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    final l10n = AppLocalizations.of(context)!;
    if (_person1Controller.text.isEmpty || _person2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterNames)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final profile = CoupleProfile(
      person1Name: _person1Controller.text.trim(),
      person2Name: _person2Controller.text.trim(),
      person1PhotoPath: _person1Photo,
      person2PhotoPath: _person2Photo,
      startDate: _startDate,
      isDarkMode: true,
    );

    await context.read<AppProvider>().saveCoupleProfile(profile);

    if (mounted) {
      context.go('/');
    }
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
              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: List.generate(3, (i) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= _currentPage ? AppColors.primary : AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _buildWelcomePage(l10n),
                    _buildProfilePage(l10n),
                    _buildDatePage(l10n),
                  ],
                ),
              ),

              // Bottom navigation
              Padding(
                padding: const EdgeInsets.all(24),
                child: _currentPage < 2
                    ? GradientButton(
                        text: l10n.next,
                        onPressed: () {
                          if (_currentPage == 1 &&
                              (_person1Controller.text.isEmpty ||
                                  _person2Controller.text.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.pleaseEnterName)),
                            );
                            return;
                          }
                          _nextPage();
                        },
                        icon: Icons.arrow_forward_rounded,
                      )
                    : GradientButton(
                        text: _isLoading ? '...' : l10n.start,
                        onPressed: _isLoading ? null : _finish,
                        icon: Icons.favorite,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const HeartPulseWidget(size: 100),
          const SizedBox(height: 32),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: AppColors.primaryGradient,
            ).createShader(bounds),
            child: Text(
              l10n.appTitle,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.journeyBegins,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(Icons.timer_outlined, l10n.realtimeCounter),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.photo_album_outlined, l10n.saveMemories),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.celebration_outlined, l10n.anniversaryReminders),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.white70)),
      ],
    );
  }

  Widget _buildProfilePage(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.coupleInfo,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.introAboutCouple,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 32),

          // Person 1
          _buildPersonInput(
            controller: _person1Controller,
            photoPath: _person1Photo,
            label: l10n.person1,
            onPickPhoto: () => _pickPhoto(true),
            gradientColors: [const Color(0xFFFF6B9D), const Color(0xFFFF9EC8)],
          ),

          const SizedBox(height: 16),
          const HeartPulseWidget(size: 40),
          const SizedBox(height: 16),

          // Person 2
          _buildPersonInput(
            controller: _person2Controller,
            photoPath: _person2Photo,
            label: l10n.person2,
            onPickPhoto: () => _pickPhoto(false),
            gradientColors: [const Color(0xFFC04FD6), const Color(0xFFD975EA)],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonInput({
    required TextEditingController controller,
    required String? photoPath,
    required String label,
    required VoidCallback onPickPhoto,
    required List<Color> gradientColors,
  }) {
    return GlassCard(
      child: Column(
        children: [
          // Avatar picker
          GestureDetector(
            onTap: onPickPhoto,
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: photoPath != null
                      ? ClipOval(
                          child: appImage(photoPath, fit: BoxFit.cover, width: 80, height: 80),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 44),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePage(AppLocalizations l10n) {
    final diff = DateTime.now().difference(_startDate).inDays;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            l10n.whenStarted,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startDate,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 48),

          // Heart animation
          const HeartPulseWidget(size: 80),
          const SizedBox(height: 32),

          // Date display
          GlassCard(
            child: Column(
              children: [
                Text(
                  DateHelper.formatDateShort(_startDate, l10n.localeName),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$diff ${l10n.daysTogether} 💕',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  text: l10n.selectDate,
                  onPressed: _selectDate,
                  icon: Icons.calendar_today_outlined,
                  height: 48,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.canChangeLater,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
