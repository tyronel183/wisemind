import 'package:flutter/foundation.dart';

@immutable
class Meditation {
  final String id;
  final String title;
  final String situation;
  final String description;
  final String category;
  final String audioWithVoiceUrl;
  final String audioWithoutVoiceUrl;
  final String imageUrl;
  final bool isFree;
  final String dbtSkill;
  final String duration;

  const Meditation({
    required this.id,
    required this.title,
    required this.situation,
    required this.description,
    required this.category,
    required this.audioWithVoiceUrl,
    required this.audioWithoutVoiceUrl,
    required this.imageUrl,
    required this.isFree,
    required this.dbtSkill,
    required this.duration,
  });
}