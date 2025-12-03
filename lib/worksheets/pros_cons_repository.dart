import 'package:hive/hive.dart';

import 'pros_cons.dart';

class ProsConsRepository {
  Future<void> init() async {
    await Hive.openBox<ProsConsEntry>(kProsConsBoxName);
  }

  Box<ProsConsEntry> get box =>
      Hive.box<ProsConsEntry>(kProsConsBoxName);

  List<ProsConsEntry> getAll() => box.values.toList();
}