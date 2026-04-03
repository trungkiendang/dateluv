import 'package:go_router/go_router.dart';
import 'package:date_luv/data/repositories/app_provider.dart';
import 'package:date_luv/data/models/diary_entry.dart';
import 'package:date_luv/data/models/milestone.dart';
import 'package:date_luv/features/onboarding/onboarding_screen.dart';
import 'package:date_luv/features/home/main_navigation.dart';
import 'package:date_luv/features/diary/diary_form_screen.dart';
import 'package:date_luv/features/milestones/milestone_form_screen.dart';
import 'package:date_luv/features/gallery/photo_viewer_screen.dart';
import 'package:date_luv/features/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_luv/features/auth/login_screen.dart';
import 'package:date_luv/features/pairing/pairing_screen.dart';

class AppRouter {
  static GoRouter createRouter(AppProvider provider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        bool isLoggedIn = false;
        try {
          isLoggedIn = FirebaseAuth.instance.currentUser != null;
        } catch (_) {}
        
        final isLoginRoute = state.matchedLocation == '/login';
        final isOnboardingRoute = state.matchedLocation == '/onboarding';
        final isPairingRoute = state.matchedLocation == '/pairing';
        final hasProfile = provider.hasProfile;

        // 1. Nếu chưa có hồ sơ và chưa đăng nhập: 
        // Chỉ cho phép ở Login hoặc Onboarding
        if (!hasProfile && !isLoggedIn) {
          if (!isLoginRoute && !isOnboardingRoute) {
            return '/login';
          }
          return null;
        }

        // 2. Nếu đã đăng nhập nhưng chưa có hồ sơ:
        // Ép vào Onboarding hoặc Pairing
        if (isLoggedIn && !hasProfile && !isOnboardingRoute && !isPairingRoute) {
          return '/onboarding';
        }
        
        // 3. Nếu đã có hồ sơ:
        // Tránh quay lại Login hoặc Onboarding
        if (hasProfile && (isLoginRoute || isOnboardingRoute)) {
          return '/';
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/pairing',
          builder: (context, state) => const PairingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const MainNavigation(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/diary/new',
          builder: (context, state) => const DiaryFormScreen(),
        ),
        GoRoute(
          path: '/diary/edit',
          builder: (context, state) {
            final entry = state.extra as DiaryEntry?;
            return DiaryFormScreen(entry: entry);
          },

        ),
        GoRoute(
          path: '/milestone/new',
          builder: (context, state) => const MilestoneFormScreen(),
        ),
        GoRoute(
          path: '/milestone/edit',
          builder: (context, state) {
            final milestone = state.extra as Milestone;
            return MilestoneFormScreen(existingMilestone: milestone);
          },
        ),
        GoRoute(
          path: '/photo-viewer',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return PhotoViewerScreen(
              imagePaths: extra['imagePaths'] as List<String>,
              initialIndex: extra['initialIndex'] as int? ?? 0,
            );
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }
}
