// ======================================================
// lib/worksheets/fact_check_repository.dart
// (можно вообще не использовать, если работаешь напрямую с Hive.box)
// ======================================================

import 'package:hive/hive.dart';
import 'fact_check.dart';

class FactCheckRepository {
  late Box<FactCheckEntry> box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(kFactCheckBoxName)) {
      box = await Hive.openBox<FactCheckEntry>(kFactCheckBoxName);
    } else {
      box = Hive.box<FactCheckEntry>(kFactCheckBoxName);
    }
  }

  List<FactCheckEntry> getAllSortedByDateDesc() {
    final list = box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> add(FactCheckEntry entry) async => box.add(entry);

  Future<void> delete(FactCheckEntry entry) async => entry.delete();
}