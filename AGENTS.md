# DateLuv — Agent Instructions

## Quick commands

| Action | Command |
|---|---|
| Install deps | `flutter pub get` |
| Generate Hive adapters | `dart run build_runner build --delete-conflicting-outputs` |
| Generate l10n | `flutter gen-l10n` |
| Analyze | `flutter analyze` |
| Test | `flutter test` |
| Build Android | `flutter build apk` |
| Build iOS | `flutter build ios` |
| Build Web | `flutter build web --base-href /dateluv/` |
| Build Web (wasm) | `flutter build web --wasm --base-href /dateluv/` |

## Architecture

- **State:** `Provider` via `AppProvider` (`lib/data/repositories/app_provider.dart`)
- **Local DB:** Hive — 4 boxes: `couple_box`, `diary_box`, `milestones_box`, `settings_box` (keys in `AppConstants`)
- **Models:** `CoupleProfile(typeId=0)`, `DiaryEntry(typeId=1)`, `Milestone(typeId=2)` — all Hive-annotated with `.g.dart` generated files
- **Navigation:** GoRouter routes defined in `lib/core/router/app_router.dart`
- **Entrypoints:** `lib/main.dart` → `lib/app.dart` → `MaterialApp.router`

## Web / GitHub Pages

- **Build:** `flutter build web --base-href /<repo>/` (e.g. `/dateluv/`).
- **Routing:** `web/404.html` redirects all paths to `/` for SPA support.
- **Firebase web:** config in `lib/core/services/firebase_service.dart:16-24`. Update `appId` with the real web app ID from Firebase Console.
- **CI/CD:** `.github/workflows/deploy-web.yml` auto-deploys on push to `main`.
- **Tính năng không hoạt động trên web:** Google Sign-In, local_auth (biometrics), push notifications.

## Non-obvious constraints

- **Firebase init order matters:** Firebase.initializeApp() must complete **alone first** before Hive/notifications init in parallel (`main.dart:32-49`). iOS config is hardcoded in `FirebaseService` (not via plist).
- **Portrait-only:** locked in `main.dart:52-55`.
- **Dark mode default** (`isDarkMode = true`).
- **Sync is non-destructive:** cloud streams add/update local Hive entries but never delete local-only data.
- **Auto milestones:** 50, 100, 200, 365, 500, 730, 1000, 1500, 2000 days.
- **Google Sign-In:** iOS client ID configured in `AuthService`. Android uses `google-services.json`.

## Localization

- ARB files in `lib/l10n/` — `app_vi.arb` is the template base.
- Run `flutter gen-l10n` after editing ARB files.
- `l10n.yaml` no longer uses `synthetic-package` (deprecated).

## Testing

- Only a single placeholder in `test/widget_test.dart`. Add real tests there.

## Existing docs

- `GEMINI.md` — project context summary (partially overlaps README).
- `implementation_plan.md` — outdated Vietnamese design doc (not authoritative).
