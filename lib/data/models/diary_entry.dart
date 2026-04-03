import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

@HiveType(typeId: 1)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  List<String> imagePaths;

  @HiveField(5)
  String emoji;

  @HiveField(6)
  DateTime createdAt;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.imagePaths,
    required this.emoji,
    required this.createdAt,
  });
}
