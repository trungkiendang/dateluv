import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_helper.dart';
import '../../data/repositories/app_provider.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../shared/widgets/app_image.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _p1Controller = TextEditingController();
  final _p2Controller = TextEditingController();
  String? _p1Photo;
  String? _p2Photo;
  String? _bgPhoto;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final profile = provider.coupleProfile;
    if (profile != null) {
      _p1Controller.text = profile.person1Name;
      _p2Controller.text = profile.person2Name;
      _p1Photo = profile.person1PhotoPath;
      _p2Photo = profile.person2PhotoPath;
      _bgPhoto = profile.backgroundImagePath;
    }
  }

  @override
  void dispose() {
    _p1Controller.dispose();
    _p2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(String type) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (img != null) {
      setState(() {
        _hasChanges = true;
        switch (type) {
          case 'p1': _p1Photo = img.path; break;
          case 'p2': _p2Photo = img.path; break;
          case 'bg': _bgPhoto = img.path; break;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<AppProvider>();
    await provider.updateCoupleProfile(
      person1Name: _p1Controller.text.trim(),
      person2Name: _p2Controller.text.trim(),
      person1PhotoPath: _p1Photo,
      person2PhotoPath: _p2Photo,
      backgroundImagePath: _bgPhoto,
    );
    setState(() => _hasChanges = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.changesSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final profile = provider.coupleProfile;

        if (profile == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

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
                  // App bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            l10n.settings,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (_hasChanges)
                          TextButton(
                            onPressed: _saveProfile,
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
                          // Background image
                          _SectionHeader(title: l10n.homeBackground),
                          GestureDetector(
                            onTap: () => _pickPhoto('bg'),
                            child: GlassCard(
                              padding: const EdgeInsets.all(0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 160,
                                      width: double.infinity,
                                      child: _bgPhoto != null
                                          ? appImage(_bgPhoto, fit: BoxFit.cover, height: 160, width: double.infinity)
                                          : Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(colors: AppColors.primaryGradient),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(Icons.wallpaper, color: Colors.white, size: 40),
                                                    const SizedBox(height: 8),
                                                    Text(l10n.selectBackground, style: const TextStyle(color: Colors.white70)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                      right: 12,
                                      bottom: 12,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                      ),
                                    ),
                                    if (_bgPhoto != null)
                                      Positioned(
                                        right: 44,
                                        bottom: 12,
                                        child: GestureDetector(
                                          onTap: () => setState(() { _bgPhoto = null; _hasChanges = true; }),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.delete, color: Colors.white, size: 18),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Profile editing
                          _SectionHeader(title: l10n.coupleInfo),
                          _buildPersonRow(
                            name: _p1Controller,
                            photoPath: _p1Photo,
                            label: l10n.person1,
                            onPickPhoto: () => _pickPhoto('p1'),
                            onChanged: () => setState(() => _hasChanges = true),
                            colors: const [Color(0xFFFF6B9D), Color(0xFFFF9EC8)],
                          ),
                          const SizedBox(height: 12),
                          _buildPersonRow(
                            name: _p2Controller,
                            photoPath: _p2Photo,
                            label: l10n.person2,
                            onPickPhoto: () => _pickPhoto('p2'),
                            onChanged: () => setState(() => _hasChanges = true),
                            colors: const [Color(0xFFC04FD6), Color(0xFFD975EA)],
                          ),
                          const SizedBox(height: 24),

                          // Stats
                          _SectionHeader(title: l10n.stats),
                          GlassCard(
                            child: Column(
                              children: [
                                _StatRow(
                                  icon: Icons.calendar_today_outlined,
                                  label: l10n.startDate,
                                  value: DateHelper.formatDate(profile.startDate, l10n.localeName),
                                  color: AppColors.primary,
                                ),
                                const Divider(color: AppColors.darkBorder, height: 24),
                                _StatRow(
                                  icon: Icons.favorite_outlined,
                                  label: l10n.daysTogether,
                                  value: '${DateTime.now().difference(profile.startDate).inDays} ${l10n.days.toLowerCase()}',
                                  color: AppColors.primary,
                                ),
                                const Divider(color: AppColors.darkBorder, height: 24),
                                _StatRow(
                                  icon: Icons.book_outlined,
                                  label: l10n.totalMemories,
                                  value: l10n.memoryCount(provider.diaryEntries.length),
                                  color: AppColors.secondary,
                                ),
                                const Divider(color: AppColors.darkBorder, height: 24),
                                _StatRow(
                                  icon: Icons.photo_library_outlined,
                                  label: l10n.totalPhotos,
                                  value: l10n.photoCount(provider.allPhotoPaths.length),
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Appearance
                          _SectionHeader(title: l10n.appearance),
                          GlassCard(
                            child: Row(
                              children: [
                                Icon(
                                  provider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.darkMode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                      Text(
                                        provider.isDarkMode ? l10n.on : l10n.off,
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: provider.isDarkMode,
                                  onChanged: (_) => provider.toggleDarkMode(),
                                  activeThumbColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Language
                          _SectionHeader(title: l10n.language),
                          GlassCard(
                            child: Row(
                              children: [
                                const Icon(Icons.language, color: AppColors.primary),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Text('Ngôn ngữ / Language', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                                DropdownButton<String>(
                                  value: provider.locale.languageCode,
                                  dropdownColor: AppColors.darkCard,
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt', style: TextStyle(color: Colors.white))),
                                    DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.white))),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      provider.setLocale(Locale(val));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Cloud Sync
                          _SectionHeader(title: l10n.cloudSync),
                          _buildSyncSection(provider, l10n),
                          const SizedBox(height: 24),

                          // About
                          _SectionHeader(title: l10n.about),
                          GlassCard(
                            child: Column(
                              children: [
                                _InfoRow(icon: Icons.info_outline, label: l10n.version, value: '1.0.0'),
                                const Divider(color: AppColors.darkBorder, height: 24),
                                _InfoRow(icon: Icons.person_outline, label: l10n.author, value: 'kiendt'),
                                const Divider(color: AppColors.darkBorder, height: 24),
                                _InfoRow(icon: Icons.favorite, label: l10n.madeWithLove, value: '💕'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSyncSection(AppProvider provider, AppLocalizations l10n) {
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {}
    final isSyncing = provider.isSyncEnabled;

    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isSyncing ? Icons.cloud_done : Icons.cloud_off,
                color: isSyncing ? Colors.greenAccent : AppColors.textMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSyncing ? l10n.syncEnabled : l10n.syncDisabled,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    if (user != null)
                      Text(
                        l10n.loggedInAs(user.email ?? ''),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (user != null)
                TextButton(
                  onPressed: () => provider.signOut(),
                  child: Text(l10n.logout, style: const TextStyle(color: Colors.redAccent)),
                )
            ],
          ),
          if (user == null) ...[
            const SizedBox(height: 16),
            GradientButton(
              onPressed: () => context.go('/login'),
              height: 44,
              text: l10n.loginGoogle,
              icon: Icons.login,
            ),
          ],
          if (user != null && !isSyncing) ...[
            const Divider(color: AppColors.darkBorder, height: 24),
            Row(
              children: [
                const Icon(Icons.link_off, color: Colors.orangeAccent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notConnected,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Kết nối với đối phương để bắt đầu đồng bộ',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/pairing'),
                  child: Text(l10n.connectNow),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonRow({
    required TextEditingController name,
    required String? photoPath,
    required String label,
    required VoidCallback onPickPhoto,
    required VoidCallback onChanged,
    required List<Color> colors,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPickPhoto,
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: colors),
                  ),
                  child: photoPath != null
                      ? ClipOval(child: appImage(photoPath, fit: BoxFit.cover, height: 60, width: 60))
                      : const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: name,
              onChanged: (_) => onChanged(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        Text(value, style: const TextStyle(color: AppColors.textMuted)),
      ],
    );
  }
}
