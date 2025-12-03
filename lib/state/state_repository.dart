import 'package:hive_flutter/hive_flutter.dart';

import 'state_entry.dart';

/// Репозиторий для работы с записями состояний.
///
/// В боксе могут лежать как старые записи в виде Map String, dynamic>,
/// так и новые записи в виде StateEntry. Этот класс аккуратно приводит всё
/// к списку StateEntry, отсортированному по дате.
class StateRepository {
  final Box _box;

  StateRepository(this._box);

  /// Прямой доступ к боксу (для listenable() и т.п.).
  Box get box => _box;

  /// Возвращает все записи как List StateEntry>, отсортированный по дате (новые сверху).
  List<StateEntry> getAll() {
    final result = <StateEntry>[];

    for (final raw in _box.values) {
      if (raw is StateEntry) {
        // Новые записи, сохранённые как объекты.
        result.add(raw);
      } else if (raw is Map) {
        // Старые записи, сохранённые как Map. Пробуем привести ключи к String.
        try {
          final map = Map<String, dynamic>.from(raw);
          result.add(StateEntry.fromMap(map));
        } catch (_) {
          // Если структура неожиданная — просто пропускаем такую запись,
          // чтобы не падало всё приложение.
          continue;
        }
      }
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  /// Сохраняет новую запись.
  ///
  /// Для единообразия кладём в бокс Map String, dynamic>: это совместимо
  /// с уже существующими данными и с конструктором StateEntry.fromMap().
  Future<void> save(StateEntry entry) async {
    await _box.add(entry.toMap());
  }

  /// Находит ключ записи по её id (если она есть в боксе).
  dynamic _findKeyById(String id) {
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value is StateEntry) {
        if (value.id == id) return key;
      } else if (value is Map) {
        try {
          final map = Map<String, dynamic>.from(value);
          if (map['id'] == id) return key;
        } catch (_) {
          // пропускаем странные записи
        }
      }
    }
    return null;
  }

  /// Обновляет запись по её id. Если запись не найдена, ничего не делает
  /// (или добавляет новую, если так удобнее для потока данных).
  Future<void> update(StateEntry entry) async {
    final key = _findKeyById(entry.id);
    if (key == null) {
      // если почему-то записи нет — добавим как новую, чтобы не терять данные
      await save(entry);
      return;
    }
    await _box.put(key, entry.toMap());
  }

  /// Удаляет запись по её id. Если не найдена — ничего не делает.
  Future<void> deleteById(String id) async {
    final key = _findKeyById(id);
    if (key != null) {
      await _box.delete(key);
    }
  }

  /// Удаляет запись по ключу.
  Future<void> delete(dynamic key) async {
    await _box.delete(key);
  }
}