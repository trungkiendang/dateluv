import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final AuthService _authService = AuthService();
  final _codeController = TextEditingController();
  String? _myInviteCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMyCode();
  }

  Future<void> _loadMyCode() async {
    final user = _authService.currentUser;
    if (user != null) {
      final code = await _authService.getUserInviteCode(user.uid);
      setState(() => _myInviteCode = code);
    }
  }

  Future<void> _handlePairing() async {
    final l10n = AppLocalizations.of(context)!;
    final partnerCode = _codeController.text.trim().toUpperCase();
    
    if (partnerCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterValidCode)),
      );
      return;
    }

    if (partnerCode == _myInviteCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotConnectSelf)),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await _authService.pairWithPartner(partnerCode);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go('/onboarding');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidCode)),
        );
      }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const HeartPulseWidget(size: 80),
                const SizedBox(height: 32),
                Text(
                  l10n.connectCouple,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.pairingDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
                ),
                const SizedBox(height: 48),

                // My Code Section
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        l10n.yourCode,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      if (_myInviteCode == null)
                        const CircularProgressIndicator(color: AppColors.primary)
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _myInviteCode!,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 8,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white54, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _myInviteCode!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.codeCopied)),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.darkBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(l10n.or, style: const TextStyle(color: AppColors.textMuted)),
                    ),
                    const Expanded(child: Divider(color: AppColors.darkBorder)),
                  ],
                ),
                const SizedBox(height: 32),

                // Partner Code Input
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        l10n.enterPartnerCode,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _codeController,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: '000000',
                          hintStyle: TextStyle(color: Colors.white10),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        text: _isLoading ? '...' : l10n.connectNow,
                        onPressed: _isLoading ? null : _handlePairing,
                        icon: Icons.link,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => context.go('/onboarding'),
                  child: Text(l10n.skipAndOffline, style: const TextStyle(color: Colors.white38)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
