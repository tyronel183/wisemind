import 'package:hive/hive.dart';

part 'pros_cons.g.dart';

/// Имя бокса для рабочих листов "За и против"
const String kProsConsBoxName = 'pros_cons_entries';

@HiveType(typeId: 2)
class ProsConsEntry extends HiveObject {
  @HiveField(0)
  String email;

  @HiveField(1)
  DateTime date;

  /// Проблемное поведение, которое оцениваем
  @HiveField(2)
  String problematicBehavior;

  /// "За" — поддаться импульсу
  @HiveField(3)
  String prosActImpulsively;

  /// "За" — противостоять импульсу
  @HiveField(4)
  String prosResistImpulse;

  /// "Против" — поддаться импульсу
  @HiveField(5)
  String consActImpulsively;

  /// "Против" — противостоять импульсу
  @HiveField(6)
  String consResistImpulse;

  ProsConsEntry({
    required this.email,
    required this.date,
    required this.problematicBehavior,
    required this.prosActImpulsively,
    required this.prosResistImpulse,
    required this.consActImpulsively,
    required this.consResistImpulse,
  });
}