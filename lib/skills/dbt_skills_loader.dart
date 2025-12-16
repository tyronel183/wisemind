// lib/skills/dbt_skills_loader.dart
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;

import 'dbt_skill.dart';

class DbtSkillsLoader {
  static const String _basePath = 'assets/data/skills_base.json';
  static const String _ruPath = 'assets/data/skills_ru.json';
  static const String _enPath = 'assets/data/skills_en.json';

  /// Loads skills by combining:
  /// - meta from [skills_base.json]
  /// - texts from [skills_ru.json] or [skills_en.json] в зависимости от языка
  ///
  /// Fallback-логика:
  /// - если для локали нет файла, используем английский;
  /// - если текст для конкретного id не найден — такой skill пропускается.
  static Future<List<DbtSkill>> loadSkills() async {
    // 1. Загружаем мету
    final baseJsonString = await rootBundle.loadString(_basePath);
    final List<dynamic> baseList =
        json.decode(baseJsonString) as List<dynamic>;

    final Map<String, DbtSkillMeta> metaById = {
      for (final item in baseList)
        (item as Map<String, dynamic>)['id'] as String:
            DbtSkillMeta.fromJson(item as Map<String, dynamic>),
    };

    // 2. Определяем язык и выбираем файл с текстами
    final locale = ui.PlatformDispatcher.instance.locale;
    final langCode = locale.languageCode.toLowerCase();

    final String primaryTextsPath =
        langCode == 'ru' ? _ruPath : _enPath; // по умолчанию EN
    final String fallbackTextsPath =
        langCode == 'ru' ? _enPath : _ruPath; // запасной вариант

    Map<String, DbtSkillTexts> textsById = {};

    // 3. Пробуем загрузить тексты для основного языка
    textsById = await _loadTextsSafe(primaryTextsPath);

    // 4. Если основной язык не загрузился — пробуем фолбэк
    if (textsById.isEmpty) {
      final fallback = await _loadTextsSafe(fallbackTextsPath);
      if (fallback.isNotEmpty) {
        textsById = fallback;
      }
    }

    // 5. Собираем DbtSkill из meta + texts
    final List<DbtSkill> skills = [];

    for (final entry in metaById.entries) {
      final String id = entry.key;
      final DbtSkillMeta meta = entry.value;
      final DbtSkillTexts? texts = textsById[id];

      if (texts == null) {
        // Нет текстов для этого skill в текущем языке — пропускаем
        continue;
      }

      skills.add(
        DbtSkill(
          meta: meta,
          texts: texts,
        ),
      );
    }

    // 6. Сортируем по order, если он задан
    skills.sort(
      (a, b) => a.meta.order.compareTo(b.meta.order),
    );

    return skills;
  }

  /// Безопасная загрузка текстов: если файла нет или JSON некорректный —
  /// возвращаем пустую карту, не роняя приложение.
  static Future<Map<String, DbtSkillTexts>> _loadTextsSafe(
    String assetPath,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList =
          json.decode(jsonString) as List<dynamic>;

      return {
        for (final item in jsonList)
          (item as Map<String, dynamic>)['id'] as String:
              DbtSkillTexts.fromJson(item as Map<String, dynamic>),
      };
    } catch (_) {
      // Можно добавить логирование, если используешь какой-то logger
      return {};
    }
  }
}