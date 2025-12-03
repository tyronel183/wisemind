import 'package:hive/hive.dart';
import 'chain_analysis.dart';

class ChainAnalysisRepository {
  static const String boxName = 'chain_analysis_entries_box';

  late final Box<ChainAnalysisEntry> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ChainAnalysisEntry>(boxName);
  }

  /// Добавить новую запись
  Future<void> addEntry(ChainAnalysisEntry entry) async {
    await _box.add(entry);
  }

  /// Получить все записи (новые сверху)
  List<ChainAnalysisEntry> getAllEntries() {
    final entries = _box.values.toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Обновить запись
  Future<void> updateEntry(ChainAnalysisEntry entry) async {
    await entry.save();
  }

  /// Удалить запись
  Future<void> deleteEntry(ChainAnalysisEntry entry) async {
    await entry.delete();
  }
}
