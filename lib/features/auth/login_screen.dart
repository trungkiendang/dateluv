import 'package:flutter/material.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/common_widgets.dart';

import 'package:provider/provider.dart';
import '../../core/services/sync_service.dart';
import '../../data/repositories/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    final userCredential = await _authService.signInWithGoogle();
    
    if (mounted) {
      if (userCredential != null) {
        // Check if user already has a couple
        final coupleId = await _syncService.getCoupleId();
        if (coupleId != null) {
          context.read<AppProvider>().startSync(coupleId);
          context.go('/');
        } else {
          context.go('/pairing');
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập thất bại. Vui lòng thử lại.')),
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset('assets/icons/app_icon.png'),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    l10n.syncDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  if (_isLoading)
                    const CircularProgressIndicator(color: AppColors.primary)
                  else
                    GradientButton(
                      text: l10n.loginGoogle,
                      icon: Icons.login,
                      onPressed: _handleGoogleSignIn,
                    ),
                    
                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () => context.go('/onboarding'),
                    child: Text(
                      l10n.useOffline,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
