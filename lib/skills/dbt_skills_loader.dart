import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dbt_skill.dart';

class DbtSkillsLoader {
  static const String _basePath = 'assets/data/skills_base.json';
  static const String _ruPath = 'assets/data/skills_ru.json';
  static const String _enPath = 'assets/data/skills_en.json';

  /// Локаль, выбранная внутри приложения (если ты даёшь пользователю переключатель).
  /// Её нужно выставлять снаружи через [setAppLocale].
  static ui.Locale? _appLocale;

  /// Вызывай это при смене языка в настройках приложения.
  /// Например: DbtSkillsLoader.setAppLocale(const Locale('ru'));
  static void setAppLocale(ui.Locale? locale) {
    _appLocale = locale;
    if (kDebugMode) {
      debugPrint(
        '[DbtSkillsLoader] appLocale set to: ${locale?.toLanguageTag()}',
      );
    }
  }

  /// Loads skills by combining:
  /// - meta from [skills_base.json]
  /// - texts from [skills_ru.json] or [skills_en.json] в зависимости от языка
  ///
  /// Fallback-логика:
  /// - если для локали нет файла, используем английский;
  /// - если текст для конкретного id не найден — такой skill пропускается.
  ///
  /// Приоритет выбора локали:
  /// 1) [localeOverride] (если передан)
  /// 2) [_appLocale] (локаль приложения, если выставлена через [setAppLocale])
  /// 3) [ui.PlatformDispatcher.instance.locale] (системная локаль устройства)
  static Future<List<DbtSkill>> loadSkills({ui.Locale? localeOverride}) async {
    // 1) Загружаем мету
    final baseJsonString = await rootBundle.loadString(_basePath);
    final List<dynamic> baseList = json.decode(baseJsonString) as List<dynamic>;

    final Map<String, DbtSkillMeta> metaById = {};

    for (final item in baseList) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] as String;
      metaById[id] = DbtSkillMeta.fromJson(map);
    }

    // 2) Определяем язык и выбираем файл с текстами
    final locale = localeOverride ?? _appLocale ?? ui.PlatformDispatcher.instance.locale;
    final langCode = locale.languageCode.toLowerCase();

    // Поддерживаем ровно RU/EN. Всё остальное — считаем EN.
    final bool isRu = langCode == 'ru';

    final String primaryTextsPath = isRu ? _ruPath : _enPath; // по умолчанию EN
    final String fallbackTextsPath = isRu ? _enPath : _ruPath; // запасной вариант

    if (kDebugMode) {
      debugPrint(
        '[DbtSkillsLoader] locale=${locale.toLanguageTag()} '
        'lang=$langCode primary=$primaryTextsPath fallback=$fallbackTextsPath',
      );
    }

    // 3) Загружаем тексты
    Map<String, DbtSkillTexts> textsById = await _loadTextsSafe(primaryTextsPath);

    // 4) Если основной язык не загрузился — пробуем фолбэк
    if (textsById.isEmpty) {
      final fallback = await _loadTextsSafe(fallbackTextsPath);
      if (fallback.isNotEmpty) {
        textsById = fallback;
      }
    }

    // 5) Собираем DbtSkill из meta + texts
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

    // 6) Сортируем по order
    skills.sort((a, b) => a.meta.order.compareTo(b.meta.order));

    if (kDebugMode) {
      debugPrint('[DbtSkillsLoader] loaded skills: ${skills.length}');
    }

    return skills;
  }

  /// Безопасная загрузка текстов: если файла нет или JSON некорректный —
  /// возвращаем пустую карту, не роняя приложение.
  static Future<Map<String, DbtSkillTexts>> _loadTextsSafe(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      final Map<String, DbtSkillTexts> result = {};

      for (final item in jsonList) {
        final map = item as Map<String, dynamic>;
        final id = map['id'] as String;
        result[id] = DbtSkillTexts.fromJson(map);
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DbtSkillsLoader] failed to load $assetPath: $e');
      }
      return {};
    }
  }
}