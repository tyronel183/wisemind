// lib/dbt_skills_loader.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'dbt_skill.dart';

class DbtSkillsLoader {
  static Future<List<DbtSkill>> loadSkills() async {
    final jsonString =
        await rootBundle.loadString('assets/data/dbt_skills.json');

    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    return jsonList
        .map(
          (item) => DbtSkill.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}