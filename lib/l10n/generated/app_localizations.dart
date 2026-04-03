import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Date Luv'**
  String get appTitle;

  /// No description provided for @loginGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập với Google'**
  String get loginGoogle;

  /// No description provided for @useOffline.
  ///
  /// In vi, this message translates to:
  /// **'Dùng offline (Không đồng bộ)'**
  String get useOffline;

  /// No description provided for @syncDescription.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ dữ liệu tình yêu của bạn trên nhiều thiết bị và không bao giờ đánh mất kỷ niệm.'**
  String get syncDescription;

  /// No description provided for @journeyBegins.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình tình yêu của bạn\nbắt đầu từ đây 💕'**
  String get journeyBegins;

  /// No description provided for @realtimeCounter.
  ///
  /// In vi, this message translates to:
  /// **'Bộ đếm tình yêu real-time'**
  String get realtimeCounter;

  /// No description provided for @saveMemories.
  ///
  /// In vi, this message translates to:
  /// **'Lưu giữ kỷ niệm đáng nhớ'**
  String get saveMemories;

  /// No description provided for @anniversaryReminders.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở ngày kỷ niệm'**
  String get anniversaryReminders;

  /// No description provided for @next.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo'**
  String get next;

  /// No description provided for @start.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu ❤️'**
  String get start;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài Đặt'**
  String get settings;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu...'**
  String get saving;

  /// No description provided for @coupleInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cặp đôi'**
  String get coupleInfo;

  /// No description provided for @stats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get stats;

  /// No description provided for @appearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get about;

  /// No description provided for @version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get version;

  /// No description provided for @author.
  ///
  /// In vi, this message translates to:
  /// **'Tác giả'**
  String get author;

  /// No description provided for @diary.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký'**
  String get diary;

  /// No description provided for @milestones.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm'**
  String get milestones;

  /// No description provided for @gallery.
  ///
  /// In vi, this message translates to:
  /// **'Album'**
  String get gallery;

  /// No description provided for @daysTogether.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bên nhau'**
  String get daysTogether;

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @shareMemories.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ kỷ niệm'**
  String get shareMemories;

  /// No description provided for @shareDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một mẫu thiệp để chia sẻ hành trình của bạn'**
  String get shareDescription;

  /// No description provided for @createAndShare.
  ///
  /// In vi, this message translates to:
  /// **'Tạo và Chia sẻ'**
  String get createAndShare;

  /// No description provided for @shareError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi chia sẻ: {error}'**
  String shareError(String error);

  /// No description provided for @pleaseEnterNames.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên của cả hai người!'**
  String get pleaseEnterNames;

  /// No description provided for @pleaseEnterName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên!'**
  String get pleaseEnterName;

  /// No description provided for @addMemory.
  ///
  /// In vi, this message translates to:
  /// **'Thêm kỷ niệm'**
  String get addMemory;

  /// No description provided for @enterMilestoneName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên ngày kỷ niệm!'**
  String get enterMilestoneName;

  /// No description provided for @icon.
  ///
  /// In vi, this message translates to:
  /// **'Biểu tượng'**
  String get icon;

  /// No description provided for @date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get date;

  /// No description provided for @reminder.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở'**
  String get reminder;

  /// No description provided for @remindBefore.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc trước:'**
  String get remindBefore;

  /// No description provided for @enterTitle.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tiêu đề!'**
  String get enterTitle;

  /// No description provided for @autoGenerated.
  ///
  /// In vi, this message translates to:
  /// **'Tự động'**
  String get autoGenerated;

  /// No description provided for @deleteMilestone.
  ///
  /// In vi, this message translates to:
  /// **'Xóa kỷ niệm'**
  String get deleteMilestone;

  /// No description provided for @confirmDeleteMilestone.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ngày kỷ niệm này?'**
  String get confirmDeleteMilestone;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @loginFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thất bại. Vui lòng thử lại.'**
  String get loginFailed;

  /// No description provided for @confirmDeleteDiary.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa kỷ niệm này?'**
  String get confirmDeleteDiary;

  /// No description provided for @changesSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu thay đổi!'**
  String get changesSaved;

  /// No description provided for @selectBackground.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh nền'**
  String get selectBackground;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ / Language'**
  String get language;

  /// No description provided for @enterValidCode.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mã 6 ký tự hợp lệ.'**
  String get enterValidCode;

  /// No description provided for @cannotConnectSelf.
  ///
  /// In vi, this message translates to:
  /// **'Đây là mã của bạn, không thể kết nối với chính mình!'**
  String get cannotConnectSelf;

  /// No description provided for @invalidCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã không hợp lệ hoặc không tìm thấy người dùng.'**
  String get invalidCode;

  /// No description provided for @codeCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép mã!'**
  String get codeCopied;

  /// No description provided for @or.
  ///
  /// In vi, this message translates to:
  /// **'HOẶC'**
  String get or;

  /// No description provided for @on.
  ///
  /// In vi, this message translates to:
  /// **'Đang bật'**
  String get on;

  /// No description provided for @off.
  ///
  /// In vi, this message translates to:
  /// **'Đang tắt'**
  String get off;

  /// No description provided for @days.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get days;

  /// No description provided for @years.
  ///
  /// In vi, this message translates to:
  /// **'Năm'**
  String get years;

  /// No description provided for @months.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get months;

  /// No description provided for @hours.
  ///
  /// In vi, this message translates to:
  /// **'Giờ'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In vi, this message translates to:
  /// **'Phút'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In vi, this message translates to:
  /// **'Giây'**
  String get seconds;

  /// No description provided for @person1.
  ///
  /// In vi, this message translates to:
  /// **'Người thứ nhất'**
  String get person1;

  /// No description provided for @person2.
  ///
  /// In vi, this message translates to:
  /// **'Người thứ hai'**
  String get person2;

  /// No description provided for @startDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu'**
  String get startDate;

  /// No description provided for @totalMemories.
  ///
  /// In vi, this message translates to:
  /// **'Số kỷ niệm'**
  String get totalMemories;

  /// No description provided for @totalPhotos.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số ảnh'**
  String get totalPhotos;

  /// No description provided for @madeWithLove.
  ///
  /// In vi, this message translates to:
  /// **'Làm với yêu thương'**
  String get madeWithLove;

  /// No description provided for @searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm kỷ niệm...'**
  String get searchHint;

  /// No description provided for @emptyDiary.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có kỷ niệm nào'**
  String get emptyDiary;

  /// No description provided for @noResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy'**
  String get noResults;

  /// No description provided for @firstMemoryPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Hãy ghi lại khoảnh khắc đặc biệt đầu tiên!'**
  String get firstMemoryPrompt;

  /// No description provided for @searchAgainPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Thử tìm kiếm với từ khóa khác'**
  String get searchAgainPrompt;

  /// No description provided for @choosePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh'**
  String get choosePhoto;

  /// No description provided for @selectDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get selectDate;

  /// No description provided for @introAboutCouple.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu về hai bạn'**
  String get introAboutCouple;

  /// No description provided for @introDescription.
  ///
  /// In vi, this message translates to:
  /// **'Hãy cho chúng tôi biết về cặp đôi của bạn'**
  String get introDescription;

  /// No description provided for @whenStarted.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu yêu nhau'**
  String get whenStarted;

  /// No description provided for @whenStartedLong.
  ///
  /// In vi, this message translates to:
  /// **'Khi nào hai bạn chính thức bên nhau?'**
  String get whenStartedLong;

  /// No description provided for @canChangeLater.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể thay đổi ngày này sau trong phần cài đặt'**
  String get canChangeLater;

  /// No description provided for @timeTogether.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian bên nhau'**
  String get timeTogether;

  /// No description provided for @upcoming.
  ///
  /// In vi, this message translates to:
  /// **'Sắp tới'**
  String get upcoming;

  /// No description provided for @passed.
  ///
  /// In vi, this message translates to:
  /// **'Đã qua'**
  String get passed;

  /// No description provided for @noUpcoming.
  ///
  /// In vi, this message translates to:
  /// **'Không có ngày kỷ niệm sắp tới'**
  String get noUpcoming;

  /// No description provided for @noPassed.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ngày kỷ niệm nào qua'**
  String get noPassed;

  /// No description provided for @daysLeft.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} ngày nữa'**
  String daysLeft(int count);

  /// No description provided for @daysAgo.
  ///
  /// In vi, this message translates to:
  /// **'Đã qua {count} ngày'**
  String daysAgo(int count);

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay! 🎉'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In vi, this message translates to:
  /// **'Ngày mai!'**
  String get tomorrow;

  /// No description provided for @addMilestone.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ngày kỷ niệm'**
  String get addMilestone;

  /// No description provided for @editMilestone.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa kỷ niệm'**
  String get editMilestone;

  /// No description provided for @milestoneName.
  ///
  /// In vi, this message translates to:
  /// **'Tên ngày kỷ niệm'**
  String get milestoneName;

  /// No description provided for @notes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú (tùy chọn)'**
  String get notes;

  /// No description provided for @connectCouple.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối đôi lứa'**
  String get connectCouple;

  /// No description provided for @pairingDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ mã của bạn với đối phương hoặc nhập mã của họ để bắt đầu đồng bộ kỷ niệm.'**
  String get pairingDescription;

  /// No description provided for @yourCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã của bạn'**
  String get yourCode;

  /// No description provided for @enterPartnerCode.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã đối phương'**
  String get enterPartnerCode;

  /// No description provided for @connectNow.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối ngay'**
  String get connectNow;

  /// No description provided for @skipAndOffline.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua và dùng Offline'**
  String get skipAndOffline;

  /// No description provided for @daysCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày'**
  String daysCount(int count);

  /// No description provided for @chooseEmotion.
  ///
  /// In vi, this message translates to:
  /// **'Chọn cảm xúc'**
  String get chooseEmotion;

  /// No description provided for @diaryHint.
  ///
  /// In vi, this message translates to:
  /// **'Cảm xúc của bạn hôm nay...'**
  String get diaryHint;

  /// No description provided for @homeBackground.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh nền màn hình chính'**
  String get homeBackground;

  /// No description provided for @memoryCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} bài'**
  String memoryCount(int count);

  /// No description provided for @photoCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} ảnh'**
  String photoCount(int count);

  /// No description provided for @milestoneDaysTogether.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày bên nhau 🎉'**
  String milestoneDaysTogether(int count);

  /// No description provided for @milestoneYearsTogether.
  ///
  /// In vi, this message translates to:
  /// **'{count} năm bên nhau 🎊'**
  String milestoneYearsTogether(int count);

  /// No description provided for @shareMessage.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình yêu thương của chúng mình: {count} ngày bên nhau! ❤️ #DateLuv'**
  String shareMessage(int count);

  /// No description provided for @todayLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get yesterdayLabel;

  /// No description provided for @daysAgoLabel.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày trước'**
  String daysAgoLabel(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
