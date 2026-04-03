# Date Luv - Project Context

Date Luv is a Flutter-based mobile application designed for couples to track their relationship milestones, keep a shared diary, and visualize their time spent together. It is inspired by apps like "Been Together".

## 🚀 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Local Database:** [Hive](https://pub.dev/packages/hive) & `hive_flutter`
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
- **Backend/Sync:** [Firebase](https://firebase.google.com/) (Core, Auth, Firestore, Storage)
- **Animations:** [Lottie](https://pub.dev/packages/lottie)
- **UI Components:** Google Fonts, Flutter SVG, Photo View, Timeline Tile, Staggered Grid View.
- **Local Notifications:** `flutter_local_notifications` & `timezone`

## 📁 Project Structure

```
lib/
├── main.dart             # Application entry point & initialization
├── app.dart              # Root widget, theme & router configuration
├── core/
│   ├── constants/        # App-wide constants (Hive keys, strings)
│   ├── extensions/       # Dart/Flutter extensions
│   ├── router/           # GoRouter setup & route definitions
│   ├── services/         # Singletons (Firebase, Notifications, Sync)
│   ├── theme/            # Light/Dark theme & color schemes
│   └── utils/            # Helper functions
├── data/
│   ├── local/            # Local storage implementations (Hive)
│   ├── models/           # Hive-compatible data models (CoupleProfile, DiaryEntry, Milestone)
│   └── repositories/     # State management & data orchestration (AppProvider)
├── features/             # Feature-based modules
│   ├── auth/             # Login & Authentication
│   ├── diary/            # Shared memories & journal entries
│   ├── gallery/          # Visual memories (masonry grid)
│   ├── home/             # Real-time counter & main dashboard
│   ├── milestones/       # Relationship anniversaries & events
│   ├── onboarding/       # Initial setup & profile creation
│   ├── pairing/          # Connecting two partner accounts
│   └── settings/         # App preferences & security
└── shared/               # Shared UI components
    ├── animations/       # Custom animation widgets
    └── widgets/          # Reusable UI elements
```

## 🛠️ Building and Running

### Prerequisites
- Flutter SDK installed (check `pubspec.yaml` for version)
- Android Studio / VS Code with Flutter extension
- Firebase project configured (GoogleService-Info.plist / google-services.json)

### Commands
- **Install dependencies:** `flutter pub get`
- **Generate Hive adapters:** `dart run build_runner build --delete-conflicting-outputs`
- **Run in debug mode:** `flutter run`
- **Build Android:** `flutter build apk`
- **Build iOS:** `flutter build ios`
- **Run tests:** `flutter test`
- **Analyze code:** `flutter analyze`

## 📏 Development Conventions

- **State Management:** Use `Provider`. `AppProvider` in `lib/data/repositories/` handles the global state (profile, diary, milestones, theme).
- **Local Storage:** Use `Hive`. Register adapters in `main.dart` before opening boxes. Use `AppConstants` for box and key names.
- **Navigation:** Use `GoRouter`. Define routes in `lib/core/router/app_router.dart`.
- **Styling:** Follow the theme defined in `lib/core/theme/app_theme.dart`. Prefer using `Theme.of(context)` for colors and text styles.
- **Firebase:** `SyncService` handles real-time synchronization between local Hive and Firestore.
- **Lints:** Adhere to `package:flutter_lints/flutter.yaml`.

## ✨ Key Features

1. **Couple Dashboard:** Real-time counter of years, months, and days together.
2. **Anniversaries:** Automatic generation of 100, 200, 365... day milestones with push notifications.
3. **Shared Diary:** Capture moments with multiple photos, text, and emojis.
4. **Photo Gallery:** A masonry grid view of all captured memories.
5. **Security:** Local authentication (PIN/Biometrics) support.
6. **Cloud Sync:** Firebase integration for data backup and cross-device sharing between partners.
