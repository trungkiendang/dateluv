# Design Spec: Fastlane Automation for Date Luv

**Goal:** Build a "one-click" automation system to build, sign, and release the Date Luv app to Apple App Store and Google Play Store from a local Mac.

**Architecture:**
- **Fastlane Orchestration:** Centralized control via `fastlane` lanes.
- **iOS (Match + Gym + Deliver):** Git-based certificate management, automated IPA building, and App Store Connect synchronization.
- **Android (Gradle + Supply):** Automated AAB building and Play Store Console synchronization via Google Service Account.
- **Local Secrets:** Use `.env` files and local keystores (excluded from git).

## 1. Core Components

### 1.1 iOS Pipeline
- **Fastlane Match:** Will be used to store certificates and provisioning profiles in a private git repository. This ensures consistent signing across multiple machines or after OS reinstalls.
- **Fastlane Gym:** Handles the `xcodebuild` process to produce a distribution-ready `.ipa`.
- **Fastlane Deliver:** Syncs screenshots, app description, and categories with App Store Connect.

### 1.2 Android Pipeline
- **Signing Config:** Configure `android/key.properties` to link to the `.jks` keystore.
- **Fastlane Gradle:** Executes `bundleRelease` task.
- **Fastlane Supply:** Uses a Google Service Account JSON key to upload the App Bundle (`.aab`) and update Store metadata.

## 2. File Structure Changes
- Create `Gemfile` at root to manage Fastlane/Ruby dependencies.
- Create `ios/fastlane/` directory with `Appfile`, `Fastfile`, and `Matchfile`.
- Create `android/fastlane/` directory with `Appfile` and `Fastfile`.
- Update `.gitignore` to exclude `.env`, `*.jks`, and `google-services-json` keys.

## 3. Workflow Steps
1. **Init:** Install Fastlane and generate boilerplate files.
2. **iOS Signing:** Setup Match and migrate existing/new certs to the private repo.
3. **Android Signing:** Create/Configure release keystore and `key.properties`.
4. **API Setup:** Create App Store Connect API Key and Google Play Service Account.
5. **Lane Implementation:**
   - `ios beta`: Push to TestFlight.
   - `android internal`: Push to Play Store Internal Track.
   - `promote_to_production`: Move builds from beta/internal to public store.

## 4. Security Requirements
- **Match Passphrase:** Must be stored in a password manager, not in the codebase.
- **Service Account Keys:** Must be stored in a dedicated `secrets/` folder outside of git or provided via local `.env`.

## 5. Success Criteria
- Running `fastlane ios release` produces a signed IPA and uploads it to App Store Connect.
- Running `fastlane android release` produces a signed AAB and uploads it to Google Play Console.
- Metadata (descriptions, screenshots) can be updated via command line.
