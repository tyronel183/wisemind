import 'package:flutter/material.dart';

/// Разделы DBT
enum DbtModule {
  mindfulness,                // Осознанность
  distressTolerance,          // Устойчивость к стрессу
  emotionRegulation,          // Регуляция эмоций
  interpersonalEffectiveness, // Межличностная эффективность
}

extension DbtModuleX on DbtModule {
  String get title {
    switch (this) {
      case DbtModule.mindfulness:
        return 'Осознанность';
      case DbtModule.distressTolerance:
        return 'Устойчивость к стрессу';
      case DbtModule.emotionRegulation:
        return 'Регуляция эмоций';
      case DbtModule.interpersonalEffectiveness:
        return 'Межличностная эффективность';
    }
  }

  String get subtitle {
    switch (this) {
      case DbtModule.mindfulness:
        return 'Навыки «что» и «как» быть в моменте';
      case DbtModule.distressTolerance:
        return 'Как переживать кризисы без саморазноса';
      case DbtModule.emotionRegulation:
        return 'Как понимать и менять свои эмоции';
      case DbtModule.interpersonalEffectiveness:
        return 'Как просить, отказывать и сохранять отношения';
    }
  }

  IconData get icon {
    switch (this) {
      case DbtModule.mindfulness:
        return Icons.self_improvement;
      case DbtModule.distressTolerance:
        return Icons.shield_moon;
      case DbtModule.emotionRegulation:
        return Icons.water_drop;
      case DbtModule.interpersonalEffectiveness:
        return Icons.groups;
    }
  }

  /// Конвертация строки → модуль
  static DbtModule fromString(String value) {
    final v = value.trim().toLowerCase();

    switch (v) {
      // Осознанность
      case 'осознанность':
      case 'mindfulness':
        return DbtModule.mindfulness;

      // Устойчивость к стрессу
      case 'устойчивость к стрессу':
      case 'distress tolerance':
      case 'distress_tolerance':
      case 'distress-tolerance':
        return DbtModule.distressTolerance;

      // Регуляция эмоций
      case 'регуляция эмоций':
      case 'emotion regulation':
      case 'emotion_regulation':
      case 'emotion-regulation':
        return DbtModule.emotionRegulation;

      // Межличностная эффективность
      case 'межличностная эффективность':
      case 'interpersonal effectiveness':
      case 'interpersonal_effectiveness':
      case 'interpersonal-effectiveness':
        return DbtModule.interpersonalEffectiveness;

      default:
        throw Exception('Unknown DBT module: $value');
    }
  }
}

/// Метаданные навыка DBT (общие для всех языков)
class DbtSkillMeta {
  /// ID навыка (внутренний ключ)
  final String id;

  /// Модуль DBT
  final DbtModule module;

  /// Подраздел внутри модуля (например, "Общие", "Навыки «Что»")
  final String? section;

  /// Порядок внутри модуля/секции
  final int order;

  /// Картинка
  final String? imageAsset;

  /// Эмодзи для отображения навыка
  final String? emoji;

  /// Есть ли у навыка рабочий лист
  final bool hasWorksheet;

  /// Является ли навык премиальным (попадает за paywall)
  final bool isPremium;

  const DbtSkillMeta({
    required this.id,
    required this.module,
    required this.order,
    this.section,
    this.imageAsset,
    this.emoji,
    this.hasWorksheet = false,
    this.isPremium = false,
  });

  /// JSON → объект (для файла skills_base.json)
  factory DbtSkillMeta.fromJson(Map<String, dynamic> json) {
    return DbtSkillMeta(
      id: json['id']?.toString() ?? '',
      module: DbtModuleX.fromString(json['module'] ?? ''),
      section: json['section'],
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      imageAsset: json['imageAsset'],
      emoji: json['emoji'] as String?,
      hasWorksheet:
          json['hasWorksheet'] == true || json['hasWorksheet'] == 'true',
      isPremium: json['isPremium'] == true || json['isPremium'] == 'true',
    );
  }

  /// объект → JSON (для возможной сериализации обратно)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // для хранения в JSON удобнее использовать слаг/ключ,
      // но сейчас используем строковое имя модуля как раньше
      'module': module.toString(),
      'section': section,
      'order': order,
      'imageAsset': imageAsset,
      'emoji': emoji,
      'hasWorksheet': hasWorksheet,
      'isPremium': isPremium,
    };
  }
}

/// Текстовая часть навыка DBT (зависит от языка)
class DbtSkillTexts {
  /// ID навыка (должен совпадать с meta.id)
  final String id;

  /// Название навыка
  final String name;

  /// Краткое описание
  final String shortDescription;

  /// Что это за навык (короткий блок)
  final String? textWhat;

  /// Зачем нужен навык (короткий блок)
  final String? textWhy;

  /// Как практиковать (короткий блок)
  final String? textPractice;

  /// Полная информация о навыке (HTML)
  final String? fullInfo;

  /// Подробная практика (HTML)
  final String? fullPractice;

  const DbtSkillTexts({
    required this.id,
    required this.name,
    required this.shortDescription,
    this.textWhat,
    this.textWhy,
    this.textPractice,
    this.fullInfo,
    this.fullPractice,
  });

  /// JSON → объект (для файлов skills_ru.json / skills_en.json)
  factory DbtSkillTexts.fromJson(Map<String, dynamic> json) {
    return DbtSkillTexts(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      textWhat: json['textWhat'],
      textWhy: json['textWhy'],
      textPractice: json['textPractice'],
      fullInfo: json['fullInfo'],
      fullPractice: json['fullPractice'],
    );
  }

  /// объект → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortDescription': shortDescription,
      'textWhat': textWhat,
      'textWhy': textWhy,
      'textPractice': textPractice,
      'fullInfo': fullInfo,
      'fullPractice': fullPractice,
    };
  }
}

/// Собранный навык DBT = метаданные + тексты для конкретного языка
class DbtSkill {
  final DbtSkillMeta meta;
  final DbtSkillTexts texts;

  const DbtSkill({
    required this.meta,
    required this.texts,
  });

  /// Удобный конструктор из двух JSON-объектов
  factory DbtSkill.fromMetaAndTexts(
    Map<String, dynamic> metaJson,
    Map<String, dynamic> textsJson,
  ) {
    final meta = DbtSkillMeta.fromJson(metaJson);
    final texts = DbtSkillTexts.fromJson(textsJson);

    if (meta.id != texts.id) {
      throw Exception(
        'DbtSkill id mismatch: meta.id=${meta.id}, texts.id=${texts.id}',
      );
    }

    return DbtSkill(meta: meta, texts: texts);
  }

  /// ---------- Геттеры для обратной совместимости ----------
  String get id => meta.id;
  DbtModule get module => meta.module;
  String? get section => meta.section;
  int get order => meta.order;
  String? get imageAsset => meta.imageAsset;
  String? get emoji => meta.emoji;
  bool get hasWorksheet => meta.hasWorksheet;
  bool get isPremium => meta.isPremium;

  String get name => texts.name;
  String get shortDescription => texts.shortDescription;
  String? get textWhat => texts.textWhat;
  String? get textWhy => texts.textWhy;
  String? get textPractice => texts.textPractice;
  String? get fullInfo => texts.fullInfo;
  String? get fullPractice => texts.fullPractice;
}