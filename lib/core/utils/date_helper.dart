import 'package:intl/intl.dart';
import 'package:date_luv/l10n/generated/app_localizations.dart';

class DateHelper {
  /// Tính thời gian đã bên nhau từ [startDate] đến bây giờ
  static Map<String, int> timeTogether(DateTime startDate) {
    final now = DateTime.now();
    final diff = now.difference(startDate);

    int years = now.year - startDate.year;
    int months = now.month - startDate.month;
    int days = now.day - startDate.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final totalSeconds = diff.inSeconds;
    final hours = (totalSeconds % (3600 * 24)) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final totalDays = diff.inDays;

    return {
      'years': years,
      'months': months,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'totalDays': totalDays,
    };
  }

  /// Format ngày: "02 tháng 04, 2026" (vi) or "April 02, 2026" (en)
  static String formatDate(DateTime date, String locale) {
    return DateFormat.yMMMMd(locale).format(date);
  }

  /// Format ngày ngắn: "02/04/2026"
  static String formatDateShort(DateTime date, String locale) {
    return DateFormat.yMd(locale).format(date);
  }

  /// Format ngày dạng thân thiện: "Hôm nay", "Hôm qua", hoặc ngày cụ thể
  static String formatDateFriendly(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = today.difference(target).inDays;

    if (diff == 0) return l10n.todayLabel;
    if (diff == 1) return l10n.yesterdayLabel;
    if (diff > 0 && diff < 7) return l10n.daysAgoLabel(diff);
    
    return formatDate(date, l10n.localeName);
  }

  /// Tính số ngày còn lại đến một ngày
  static int daysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return target.difference(today).inDays;
  }

  /// Format thời gian dạng 2 chữ số (01, 09, 23, ...)
  static String twoDigit(int n) => n.toString().padLeft(2, '0');

  static String formatMonthYear(DateTime date, String locale) {
    return DateFormat.yMMMM(locale).format(date);
  }
}
