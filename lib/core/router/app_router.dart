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
        
        final path = state.matchedLocation;
        final isLoginRoute = path == '/login';
        final isOnboardingRoute = path == '/onboarding';
        final isPairingRoute = path == '/pairing';
        final hasProfile = provider.hasProfile;

        // 1. Nếu chưa đăng nhập:
        if (!isLoggedIn) {
          // /pairing yêu cầu login → đá về /login
          if (isPairingRoute) return '/login';
          // Chưa có profile → bắt buộc vào /login hoặc /onboarding
          if (!hasProfile && !isLoginRoute && !isOnboardingRoute) {
            return '/login';
          }
          // Đã có profile (offline) hoặc đang ở login/onboarding → giữ nguyên
          return null;
        }

        // 2. Nếu ĐÃ đăng nhập:
        // - Nếu chưa có profile: Bắt buộc vào /onboarding hoặc /pairing
        if (!hasProfile) {
          if (!isOnboardingRoute && !isPairingRoute) {
            return '/onboarding';
          }
          return null;
        }
        
        // - Nếu đã có profile: Tránh quay lại /login hoặc /onboarding (đã xong rồi)
        if (isLoginRoute || isOnboardingRoute) {
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
