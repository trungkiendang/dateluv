import 'package:hive/hive.dart';

part 'couple_profile.g.dart';

@HiveType(typeId: 0)
class CoupleProfile extends HiveObject {
  @HiveField(0)
  String person1Name;

  @HiveField(1)
  String person2Name;

  @HiveField(2)
  String? person1PhotoPath;

  @HiveField(3)
  String? person2PhotoPath;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  String? backgroundImagePath;

  @HiveField(6)
  bool isDarkMode;

  CoupleProfile({
    required this.person1Name,
    required this.person2Name,
    this.person1PhotoPath,
    this.person2PhotoPath,
    required this.startDate,
    this.backgroundImagePath,
    this.isDarkMode = true,
  });
}
