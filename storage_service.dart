import 'package:hive/hive.dart';
import '../models/translation_history.dart';

class StorageService {
  static const String _boxName = 'translation_history';
  late Box<TranslationHistory> _historyBox;

  Future<void> initialize() async {
    Hive.registerAdapter(TranslationHistoryAdapter());
    _historyBox = await Hive.openBox<TranslationHistory>(_boxName);
  }

  Future<void> addHistory(TranslationHistory history) async {
    await _historyBox.add(history);
  }

  List<TranslationHistory> getAllHistory() {
    final items = _historyBox.values.toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  List<TranslationHistory> getFavorites() {
    return _historyBox.values.where((h) => h.isFavorite).toList();
  }

  Future<void> toggleFavorite(int index) async {
    final item = _historyBox.getAt(index);
    if (item != null) {
      item.isFavorite = !item.isFavorite;
      await _historyBox.putAt(index, item);
    }
  }

  Future<void> deleteHistory(int index) async {
    await _historyBox.deleteAt(index);
  }

  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  int get historyCount => _historyBox.length;
}
