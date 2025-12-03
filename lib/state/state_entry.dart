import 'package:hive/hive.dart';

part 'state_entry.g.dart';

@HiveType(typeId: 0)
class StateEntry {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String? mood; // Как вы сегодня?
  @HiveField(3)
  final String? grateful; // За что я себя сегодня благодарю?
  @HiveField(4)
  final String? importantGoal; // Что сделано для достижения цели?

  // Сон
  @HiveField(5)
  final int rest; // Как отдохнули (0–5)
  @HiveField(6)
  final double sleepHours; // Сколько спали (1–12 с шагом 0.5)
  @HiveField(7)
  final String wakeUpTime; // Во сколько проснулись
  @HiveField(8)
  final int nightWakeUps; // Сколько было ночных пробуждений (0–5)

  // Дискомфорт
  @HiveField(9)
  final int physicalDiscomfort; // 0–5
  @HiveField(10)
  final int emotionalDistress; // 0–5

  // Эмоциональное состояние
  @HiveField(11)
  final int dissociation; // 0–5
  @HiveField(12)
  final int ruminations; // 0–5
  @HiveField(13)
  final int selfBlame; // 0–5
  @HiveField(14)
  final int suicidalThoughts; // 0–5

  // Проблемное поведение
  @HiveField(15)
  final int? urges; // 0–5
  @HiveField(16)
  final String? action; // Что сделали

  // Забота о себе
  @HiveField(17)
  final int physicalActivity; // 0–5
  @HiveField(18)
  final int pleasure; // 0–5
  @HiveField(19)
  final String water; // литры или "Больше 4 л"
  @HiveField(20)
  final int food; // 0–5

  // Навыки
  @HiveField(21)
  final List<String> skillsUsed;

  StateEntry({
    required this.id,
    required this.date,
    this.mood,
    this.grateful,
    this.importantGoal,
    required this.rest,
    required this.sleepHours,
    required this.wakeUpTime,
    required this.nightWakeUps,
    required this.physicalDiscomfort,
    required this.emotionalDistress,
    required this.dissociation,
    required this.ruminations,
    required this.selfBlame,
    required this.suicidalThoughts,
    this.urges,
    this.action,
    required this.physicalActivity,
    required this.pleasure,
    required this.water,
    required this.food,
    required this.skillsUsed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'mood': mood,
      'grateful': grateful,
      'importantGoal': importantGoal,
      'rest': rest,
      'sleepHours': sleepHours,
      'wakeUpTime': wakeUpTime,
      'nightWakeUps': nightWakeUps,
      'physicalDiscomfort': physicalDiscomfort,
      'emotionalDistress': emotionalDistress,
      'dissociation': dissociation,
      'ruminations': ruminations,
      'selfBlame': selfBlame,
      'suicidalThoughts': suicidalThoughts,
      'urges': urges,
      'action': action,
      'physicalActivity': physicalActivity,
      'pleasure': pleasure,
      'water': water,
      'food': food,
      'skillsUsed': skillsUsed,
    };
  }

  factory StateEntry.fromMap(Map<String, dynamic> map) {
    return StateEntry(
      id: map['id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(
        (map['date'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
      mood: map['mood'] as String?,
      grateful: map['grateful'] as String?,
      importantGoal: map['importantGoal'] as String?,
      rest: (map['rest'] as int?) ?? 0,
      sleepHours: (map['sleepHours'] as num?)?.toDouble() ?? 8.0,
      wakeUpTime: map['wakeUpTime'] as String? ?? '07:00',
      nightWakeUps: (map['nightWakeUps'] as int?) ?? 0,
      physicalDiscomfort: (map['physicalDiscomfort'] as int?) ?? 0,
      emotionalDistress: (map['emotionalDistress'] as int?) ?? 0,
      dissociation: (map['dissociation'] as int?) ?? 0,
      ruminations: (map['ruminations'] as int?) ?? 0,
      selfBlame: (map['selfBlame'] as int?) ?? 0,
      suicidalThoughts: (map['suicidalThoughts'] as int?) ?? 0,
      urges: map['urges'] as int?,
      action: map['action'] as String?,
      physicalActivity: (map['physicalActivity'] as int?) ?? 0,
      pleasure: (map['pleasure'] as int?) ?? 0,
      water: map['water'] as String? ?? '2',
      food: (map['food'] as int?) ?? 0,
      skillsUsed: ((map['skillsUsed'] as List?)?.cast<String>()) ?? <String>[],
    );
  }
}