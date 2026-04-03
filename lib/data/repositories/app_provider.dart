import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/couple_profile.dart';
import '../models/diary_entry.dart';
import '../models/milestone.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/sync_service.dart';
import 'dart:async';

class AppProvider extends ChangeNotifier {
  static const _uuid = Uuid();

  // Couple profile
  CoupleProfile? _coupleProfile;
  CoupleProfile? get coupleProfile => _coupleProfile;
  bool get hasProfile => _coupleProfile != null;

  // Diary entries
  List<DiaryEntry> _diaryEntries = [];
  List<DiaryEntry> get diaryEntries => List.unmodifiable(_diaryEntries);

  // Milestones
  List<Milestone> _milestones = [];
  List<Milestone> get milestones => List.unmodifiable(_milestones);

  // Sync
  final SyncService _syncService = SyncService();
  String? _currentCoupleId;
  StreamSubscription? _diarySub;
  StreamSubscription? _milestoneSub;

  // Theme
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  // Language
  Locale _locale = const Locale('vi');
  Locale get locale => _locale;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Load couple profile
    final coupleBox = Hive.box<CoupleProfile>(AppConstants.hiveBoxCouple);
    _coupleProfile = coupleBox.get(AppConstants.keyCouple);

    // Load diary entries
    final diaryBox = Hive.box<DiaryEntry>(AppConstants.hiveBoxDiary);
    _diaryEntries = diaryBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Load milestones
    final milestonesBox = Hive.box<Milestone>(AppConstants.hiveBoxMilestones);
    _milestones = milestonesBox.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Load settings
    final settingsBox = Hive.box(AppConstants.hiveBoxSettings);
    _isDarkMode = settingsBox.get(AppConstants.keyDarkMode, defaultValue: true);
    final langCode = settingsBox.get(AppConstants.keyLocale, defaultValue: 'vi');
    _locale = Locale(langCode);

    _isLoading = false;
    notifyListeners();
  }

  // ========================= COUPLE PROFILE =========================

  Future<void> saveCoupleProfile(CoupleProfile profile) async {
    final coupleBox = Hive.box<CoupleProfile>(AppConstants.hiveBoxCouple);
    await coupleBox.put(AppConstants.keyCouple, profile);
    _coupleProfile = profile;

    // Generate auto milestones
    await _generateAutoMilestones(profile.startDate);
    notifyListeners();
  }

  Future<void> updateCoupleProfile({
    String? person1Name,
    String? person2Name,
    String? person1PhotoPath,
    String? person2PhotoPath,
    DateTime? startDate,
    String? backgroundImagePath,
  }) async {
    if (_coupleProfile == null) return;
    final updated = CoupleProfile(
      person1Name: person1Name ?? _coupleProfile!.person1Name,
      person2Name: person2Name ?? _coupleProfile!.person2Name,
      person1PhotoPath: person1PhotoPath ?? _coupleProfile!.person1PhotoPath,
      person2PhotoPath: person2PhotoPath ?? _coupleProfile!.person2PhotoPath,
      startDate: startDate ?? _coupleProfile!.startDate,
      backgroundImagePath: backgroundImagePath ?? _coupleProfile!.backgroundImagePath,
      isDarkMode: _coupleProfile!.isDarkMode,
    );
    await saveCoupleProfile(updated);
  }

  // ========================= DIARY =========================

  Future<void> addDiaryEntry(DiaryEntry entry) async {
    final diaryBox = Hive.box<DiaryEntry>(AppConstants.hiveBoxDiary);
    await diaryBox.put(entry.id, entry);
    
    if (_currentCoupleId != null) {
      _syncService.syncDiaryEntry(_currentCoupleId!, entry);
    }

    _diaryEntries = diaryBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    final diaryBox = Hive.box<DiaryEntry>(AppConstants.hiveBoxDiary);
    await diaryBox.put(entry.id, entry);
    
    if (_currentCoupleId != null) {
      _syncService.syncDiaryEntry(_currentCoupleId!, entry);
    }

    _diaryEntries = diaryBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteDiaryEntry(String id) async {
    final diaryBox = Hive.box<DiaryEntry>(AppConstants.hiveBoxDiary);
    await diaryBox.delete(id);
    
    if (_currentCoupleId != null) {
      _syncService.deleteDiaryEntry(_currentCoupleId!, id);
    }

    _diaryEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  DiaryEntry createEmptyEntry() {
    return DiaryEntry(
      id: _uuid.v4(),
      title: '',
      content: '',
      date: DateTime.now(),
      imagePaths: [],
      emoji: '❤️',
      createdAt: DateTime.now(),
    );
  }

  List<String> get allPhotoPaths {
    return _diaryEntries.expand((e) => e.imagePaths).toList();
  }

  // ========================= MILESTONES =========================

  Future<void> _generateAutoMilestones(DateTime startDate) async {
    final milestonesBox = Hive.box<Milestone>(AppConstants.hiveBoxMilestones);

    // Remove old auto-generated milestones
    final autoKeys = milestonesBox.values
        .where((m) => m.isAutoGenerated)
        .map((m) => m.id)
        .toList();
    for (final key in autoKeys) {
      await NotificationService().cancelReminder(key);
      await milestonesBox.delete(key);
    }

    // Generate new ones
    for (final days in AppConstants.autoMilestones) {
      final milestoneDate = startDate.add(Duration(days: days));
      final title = days >= 365
          ? '${days ~/ 365} năm bên nhau 🎊'
          : '$days ngày bên nhau 🎉';
      final milestone = Milestone(
        id: 'auto_$days',
        title: title,
        date: milestoneDate,
        isAutoGenerated: true,
        icon: days >= 365 ? '🎊' : '🎉',
        reminderEnabled: true,
        reminderDaysBefore: 3,
      );
      await milestonesBox.put(milestone.id, milestone);
      await NotificationService().scheduleAnniversaryReminder(milestone);
    }

    _milestones = milestonesBox.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> addMilestone(Milestone milestone) async {
    final milestonesBox = Hive.box<Milestone>(AppConstants.hiveBoxMilestones);
    await milestonesBox.put(milestone.id, milestone);
    await NotificationService().scheduleAnniversaryReminder(milestone);
    
    if (_currentCoupleId != null) {
      _syncService.syncMilestone(_currentCoupleId!, milestone);
    }

    _milestones = milestonesBox.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    notifyListeners();
  }

  Future<void> deleteMilestone(String id) async {
    final milestonesBox = Hive.box<Milestone>(AppConstants.hiveBoxMilestones);
    await milestonesBox.delete(id);
    await NotificationService().cancelReminder(id);
    
    if (_currentCoupleId != null) {
      _syncService.deleteMilestone(_currentCoupleId!, id);
    }

    _milestones.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Milestone createEmptyMilestone() {
    return Milestone(
      id: _uuid.v4(),
      title: '',
      date: DateTime.now(),
      icon: '🎉',
    );
  }

  /// Milestones sắp tới (trong tương lai)
  List<Milestone> get upcomingMilestones {
    final now = DateTime.now();
    return _milestones.where((m) => m.date.isAfter(now)).toList();
  }

  /// Milestones đã qua
  List<Milestone> get passedMilestones {
    final now = DateTime.now();
    return _milestones.where((m) => m.date.isBefore(now)).toList().reversed.toList();
  }

  // ========================= SETTINGS =========================

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final settingsBox = Hive.box(AppConstants.hiveBoxSettings);
    await settingsBox.put(AppConstants.keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final settingsBox = Hive.box(AppConstants.hiveBoxSettings);
    await settingsBox.put(AppConstants.keyDarkMode, value);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final settingsBox = Hive.box(AppConstants.hiveBoxSettings);
    await settingsBox.put(AppConstants.keyLocale, locale.languageCode);
    notifyListeners();
  }

  // ========================= SYNC LOGIC =========================

  void startSync(String coupleId) {
    _currentCoupleId = coupleId;

    _diarySub?.cancel();
    _diarySub = _syncService.streamDiaryEntries(coupleId).listen((entries) async {
      final diaryBox = Hive.box<DiaryEntry>(AppConstants.hiveBoxDiary);
      await diaryBox.clear();
      for (var entry in entries) {
        await diaryBox.put(entry.id, entry);
      }
      _diaryEntries = diaryBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    });

    _milestoneSub?.cancel();
    _milestoneSub = _syncService.streamMilestones(coupleId).listen((milestones) async {
      final milestonesBox = Hive.box<Milestone>(AppConstants.hiveBoxMilestones);
      await milestonesBox.clear();
      for (var milestone in milestones) {
        await milestonesBox.put(milestone.id, milestone);
        await NotificationService().scheduleAnniversaryReminder(milestone);
      }
      _milestones = milestonesBox.values.toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _diarySub?.cancel();
    _milestoneSub?.cancel();
    super.dispose();
  }
}
