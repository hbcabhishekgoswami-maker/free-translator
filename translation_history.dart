import 'package:hive/hive.dart';

part 'translation_history.g.dart';

@HiveType(typeId: 0)
class TranslationHistory extends HiveObject {
  @HiveField(0)
  final String originalText;

  @HiveField(1)
  final String translatedText;

  @HiveField(2)
  final String sourceLang;

  @HiveField(3)
  final String targetLang;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String type;

  @HiveField(6)
  bool isFavorite;

  TranslationHistory({
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
    required this.type,
    this.isFavorite = false,
  });
}
