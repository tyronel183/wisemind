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

/// Модель навыка DBT
class DbtSkill {
  /// ID навыка (внутренний ключ)
  final String id;

  /// Название навыка
  final String name;

  /// Модуль DBT
  final DbtModule module;

  /// Подраздел внутри модуля (например, "Общие", "Навыки «Что»")
  final String? section;

  /// Порядок внутри модуля/секции
  final int order;

  /// Краткое описание
  final String shortDescription;

  /// Картинка (на будущее)
  final String? imageAsset;

  /// Эмодзи для отображения навыка
  final String? emoji;

  /// Есть ли у навыка рабочий лист
  final bool hasWorksheet;

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

  const DbtSkill({
    required this.id,
    required this.name,
    required this.module,
    required this.shortDescription,
    required this.order,
    this.section,
    this.imageAsset,
    this.emoji,
    this.hasWorksheet = false,
    this.textWhat,
    this.textWhy,
    this.textPractice,
    this.fullInfo,
    this.fullPractice,
  });

  /// ---------- JSON → объект ----------
  factory DbtSkill.fromJson(Map<String, dynamic> json) {
    return DbtSkill(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      module: DbtModuleX.fromString(json['module'] ?? ''),
      section: json['section'],
      order: int.tryParse(json['order']?.toString() ?? '') ?? 0,
      shortDescription: json['shortDescription'] ?? '',
      imageAsset: json['imageAsset'],
      emoji: json['emoji'] as String?,
      hasWorksheet:
          json['hasWorksheet'] == true || json['hasWorksheet'] == 'true',
      textWhat: json['textWhat'],
      textWhy: json['textWhy'],
      textPractice: json['textPractice'],
      fullInfo: json['fullInfo'],
      fullPractice: json['fullPractice'],
    );
  }

  /// ---------- объект → JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // здесь можно сохранить либо title, либо свой slug — пока оставим title
      'module': module.title,
      'section': section,
      'order': order,
      'shortDescription': shortDescription,
      'imageAsset': imageAsset,
      'emoji': emoji,
      'hasWorksheet': hasWorksheet,
      'textWhat': textWhat,
      'textWhy': textWhy,
      'textPractice': textPractice,
      'fullInfo': fullInfo,
      'fullPractice': fullPractice,
    };
  }
}