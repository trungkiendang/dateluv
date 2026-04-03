# Design Spec: Memories Photo & Share Feature

This specification outlines the implementation of the System Image Picker integration and the "Memories Share Card" feature, allowing users to select photos from their device (including synced Google Photos) and create beautiful, shareable cards of their relationship milestones.

## 1. Feature Overview

### 🎨 Modern Minimalist Share Card
A dedicated feature to generate a high-quality image of the couple's relationship status for social media sharing (Instagram/Facebook Stories).
- **Style:** Modern Minimalist, leveraging the app's existing dark-themed aesthetic.
- **Content:** Couple photos, names, days together, current date, and a subtle app logo.
- **Customization:** 3-4 predefined templates with the ability to use the current home screen background as the default.

### 🖼️ System Image Picker Integration
Seamless integration with the native device photo gallery to support selection of local and cloud-synced (Google Photos/iCloud) images.

---

## 2. Technical Architecture

### Core Components
- **`ScreenshotService`:** A singleton utility to convert Flutter widgets into high-resolution PNG images using the `screenshot` package.
- **`ShareCardWidget`:** A stateless widget that renders the selected template with dynamic couple data.
- **`ShareService`:** Orchestrates the screenshot capture and triggers the system share dialog via `share_plus`.

### Data Flow
1. User triggers "Share" from Home or Diary screen.
2. A **Share Bottom Sheet** opens, allowing the user to select a template.
3. Upon selection, the `ShareCardWidget` is rendered off-screen (or in a preview).
4. `ScreenshotService` captures the widget to a temporary file.
5. `ShareService` passes the file to the OS sharing system.

---

## 3. UI Design & Templates

### Template 1: "The Classic" (Default)
- **Background:** Current app background image with a subtle dark overlay.
- **Typography:** Large, elegant serif font for the number of days.
- **Layout:** Centered couple names at the top, days in the middle, date at the bottom.

### Template 2: "Side by Side"
- **Background:** Split screen or two circular avatars.
- **Typography:** Modern sans-serif (Nunito).
- **Layout:** Names next to avatars, "Days Together" in a clean pill-shaped badge.

### Template 3: "Minimalist Poster"
- **Background:** Solid gradient or blurred background.
- **Typography:** Bold, artistic placement of numbers.
- **Layout:** Large focus on the "Number of Days" with a "Since [Date]" caption.

---

## 4. Implementation Plan

### Phase 1: Dependencies & Infrastructure
- [ ] Add `screenshot` package to `pubspec.yaml`.
- [ ] Implement `ScreenshotService` in `lib/core/services/`.
- [ ] Create `ShareCardWidget` with multiple layout variants.

### Phase 2: Share Preview & Logic
- [ ] Implement `ShareBottomSheet` to allow template selection and preview.
- [ ] Integrate `ShareService` to handle the file export and sharing.

### Phase 3: Integration
- [ ] Add "Share" button to `HomeScreen` (top right or near the counter).
- [ ] Add "Share" button to each `DiaryCard` in the `DiaryScreen`.
- [ ] Ensure `ImagePicker` settings are optimized for high-quality selection across all forms.

---

## 5. Security & Performance
- **Permissions:** Ensure `NSPhotoLibraryAddUsageDescription` is in `Info.plist` for saving shared images.
- **Performance:** Generate the shareable image in a background process if possible, or show a loading indicator during capture.
- **Storage:** Use `getTemporaryDirectory` for screenshot files to ensure they are cleaned up by the OS.

---

## 6. Success Criteria
- [ ] User can select photos from their device gallery.
- [ ] Share card is generated correctly with the couple's real-time data.
- [ ] Share dialog opens successfully on both iOS and Android.
- [ ] Image quality is sufficient for Instagram/Facebook stories.
