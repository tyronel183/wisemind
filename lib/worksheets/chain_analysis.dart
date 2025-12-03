import 'package:hive/hive.dart';

part 'chain_analysis.g.dart';

@HiveType(typeId: 1)
class ChainAnalysisEntry extends HiveObject {
  // ------------------------
  // ПОЛЯ ИЗ chain_analysis_entries
  // ------------------------

  @HiveField(0)
  String email;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String problematicBehavior;

  @HiveField(3)
  String promptingEvent;

  @HiveField(4)
  String environment;

  @HiveField(5)
  String chainLinks;

  @HiveField(6)
  String adaptiveBehaviour;

  @HiveField(7)
  String consequencesForOthers;

  @HiveField(8)
  String consequencesForMe;

  @HiveField(9)
  String damage;

  @HiveField(10)
  String decreaseVulnerability;

  @HiveField(11)
  String preventEvent;

  @HiveField(12)
  String fixPlan;

  @HiveField(13)
  String worksheetName;

  ChainAnalysisEntry({
    required this.email,
    required this.date,
    required this.problematicBehavior,
    required this.promptingEvent,
    required this.environment,
    required this.chainLinks,
    required this.adaptiveBehaviour,
    required this.consequencesForOthers,
    required this.consequencesForMe,
    required this.damage,
    required this.decreaseVulnerability,
    required this.preventEvent,
    required this.fixPlan,
    required this.worksheetName,
  });
}
