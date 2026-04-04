# Cloud Sync & Diary Sharing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Cloud Sync reliability by automating startup sync and syncing couple profiles, and implement individual diary entry sharing.

**Architecture:** Extend `SyncService` to handle `CoupleProfile` metadata. Update `AppProvider` to trigger sync on initialization using a non-destructive merge strategy. Enhance `ShareCardWidget` with a `memory` template and integrate it into `DiaryScreen`.

**Tech Stack:** Flutter, Firebase (Firestore, Auth), Hive, `screenshot`, `share_plus`.

---

### Task 1: Sync Service Enhancements

**Files:**
- Modify: `lib/core/services/sync_service.dart`

- [ ] **Step 1: Add `syncCoupleProfile` and `streamCoupleProfile`**
Add methods to `SyncService` to handle profile synchronization.

```dart
  /// Push couple profile lên Cloud
  Future<void> syncCoupleProfile(String coupleId, CoupleProfile profile) async {
    await _firestore.collection('couples').doc(coupleId).set({
      'person1Name': profile.person1Name,
      'person2Name': profile.person2Name,
      'startDate': Timestamp.fromDate(profile.startDate),
      'isDarkMode': profile.isDarkMode,
      'backgroundImagePath': profile.backgroundImagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Listen to couple profile changes
  Stream<CoupleProfile?> streamCoupleProfile(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null;
      return CoupleProfile(
        person1Name: data['person1Name'] ?? '',
        person2Name: data['person2Name'] ?? '',
        startDate: (data['startDate'] as Timestamp).toDate(),
        isDarkMode: data['isDarkMode'] ?? true,
        backgroundImagePath: data['backgroundImagePath'],
      );
    });
  }
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/services/sync_service.dart
git commit -m "feat(sync): add couple profile sync methods"
```

---

### Task 2: AppProvider Integration & Auto-Sync

**Files:**
- Modify: `lib/data/repositories/app_provider.dart`

- [ ] **Step 1: Update `init()` to auto-start sync**
Detect existing login and trigger sync automatically.

```dart
    // Inside init() after loading Hive boxes
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final coupleId = await _syncService.getCoupleId();
      if (coupleId != null) {
        startSync(coupleId);
      }
    }
```

- [ ] **Step 2: Update `startSync` with non-destructive merge and Profile sync**
Replace `clear()` with `putAll` or individual `put` to merge data. Add profile listener.

```dart
  StreamSubscription? _profileSub;

  void startSync(String coupleId) {
    _currentCoupleId = coupleId;

    // Profile Sync
    _profileSub?.cancel();
    _profileSub = _syncService.streamCoupleProfile(coupleId).listen((profile) async {
      if (profile != null) {
        final coupleBox = Hive.box<CoupleProfile>(AppConstants.hiveBoxCouple);
        // Only update if metadata changed (simple check)
        if (_coupleProfile == null || _coupleProfile!.startDate != profile.startDate) {
           await coupleBox.put(AppConstants.keyCouple, profile);
           _coupleProfile = profile;
           notifyListeners();
        }
      }
    });

    // Diary Sync (Non-destructive)
    _diarySub?.cancel();
    _diarySub = _syncService.streamDiaryEntries(coupleId).listen((entries) async {
      final diaryBox = Hive.box<DiaryEntry>(AppConstants.hiveBoxDiary);
      for (var entry in entries) {
        await diaryBox.put(entry.id, entry);
      }
      _diaryEntries = diaryBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    });

    // Milestone Sync (Non-destructive)
    _milestoneSub?.cancel();
    _milestoneSub = _syncService.streamMilestones(coupleId).listen((milestones) async {
      final milestonesBox = Hive.box<Milestone>(AppConstants.hiveBoxMilestones);
      for (var milestone in milestones) {
        await milestonesBox.put(milestone.id, milestone);
      }
      _milestones = milestonesBox.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    });
  }
```

- [ ] **Step 3: Update `saveCoupleProfile` to trigger sync**
Ensure local changes are pushed to Cloud.

```dart
  Future<void> saveCoupleProfile(CoupleProfile profile) async {
    // ... existing local save ...
    if (_currentCoupleId != null) {
      _syncService.syncCoupleProfile(_currentCoupleId!, profile);
    }
    // ... rest of method ...
  }
```

- [ ] **Step 4: Commit**

```bash
git add lib/data/repositories/app_provider.dart
git commit -m "feat(sync): implement auto-sync and profile sync in AppProvider"
```

---

### Task 3: Diary Sharing UI & Templates

**Files:**
- Modify: `lib/shared/widgets/share_card_widget.dart`
- Modify: `lib/shared/widgets/share_bottom_sheet.dart`
- Modify: `lib/features/diary/diary_screen.dart`

- [ ] **Step 1: Add `memory` template to `ShareCardWidget`**
Update `ShareTemplate` enum and `build` method to support individual diary entries.

```dart
enum ShareTemplate { classic, sideBySide, poster, memory }

class ShareCardWidget extends StatelessWidget {
  final CoupleProfile profile;
  final ShareTemplate template;
  final int daysTogether;
  final DiaryEntry? entry; // Added

  // ... updated constructor ...

  // Inside _buildTemplate
  case ShareTemplate.memory:
    return _buildMemory(l10n);

  Widget _buildMemory(AppLocalizations l10n) {
    if (entry == null) return _buildClassic(l10n);
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 40),
          if (entry!.imagePaths.isNotEmpty)
             ClipRRect(
               borderRadius: BorderRadius.circular(20),
               child: Image.file(File(entry!.imagePaths.first), height: 300, width: double.infinity, fit: BoxFit.cover),
             ),
          const SizedBox(height: 30),
          Text(entry!.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(entry!.title, style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 10),
          Text(entry!.content, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
          const Spacer(),
          Text(DateHelper.formatDate(entry!.date, l10n.localeName), style: const TextStyle(color: AppColors.primary)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Update `ShareBottomSheet` to accept `DiaryEntry`**
Modify constructor and update `_share` logic to default to `memory` if entry is present.

- [ ] **Step 3: Add Share button to `_DiaryCard`**
In `lib/features/diary/diary_screen.dart`, add the share trigger.

```dart
// Inside _DiaryCard children Row
IconButton(
  icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.textMuted),
  onPressed: () {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(
        profile: context.read<AppProvider>().coupleProfile!,
        daysTogether: DateTime.now().difference(context.read<AppProvider>().coupleProfile!.startDate).inDays,
        entry: entry,
      ),
    );
  },
),
```

- [ ] **Step 4: Commit**

```bash
git add lib/shared/widgets/share_card_widget.dart lib/shared/widgets/share_bottom_sheet.dart lib/features/diary/diary_screen.dart
git commit -m "feat(diary): add memory sharing functionality"
```

---

### Task 4: Validation

- [ ] **Step 1: Verify code compilation**
Run: `flutter analyze`
Expected: No errors in modified files.

- [ ] **Step 2: Final Commit & Cleanup**
```bash
git status
```
