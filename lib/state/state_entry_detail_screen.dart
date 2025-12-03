import 'dart:ui';

import 'package:flutter/material.dart';
import 'state_entry.dart';

/// Детальный экран записи "Состояние дня"
///
/// Ожидается, что [entry] — это модель с полями:
/// - DateTime date;
/// - String? emotion;              // название / метка эмоции
/// - String? emotionEmoji;         // опциональный emoji для эмоции
/// - int? emotionIntensity;        // 0–100
/// - double? sleepHours;           // часы сна
/// - double? restHours;            // часы отдыха
/// - double? activityHours;        // часы активности/движения
/// - String? whatHelped;           // что помогло
/// - String? whatMadeWorse;        // что ухудшило
/// - String? observations;         // наблюдения
/// - String? notes;                // свободные заметки
///
/// Если какие-то поля в твоей модели отличаются по названию —
/// можешь либо адаптировать модель, либо поправить геттеры ниже.
class StateEntryDetailScreen extends StatelessWidget {
  final StateEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StateEntryDetailScreen({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
  });

  T? _safeGet<T>(T? Function() getter) {
    try {
      return getter();
    } catch (_) {
      return null;
    }
  }

  DateTime get _date => entry.date;

  String get _emotionEmoji => '';

  // New getters for new questionnaire fields
  String? get _mood => _safeGet<String?>(() => entry.mood);

  String? get _grateful => _safeGet<String?>(() => entry.grateful);

  String? get _importantGoal => _safeGet<String?>(() => entry.importantGoal);

  double? get _sleepHours {
    final value = _safeGet<num?>(() => entry.sleepHours);
    return value?.toDouble();
  }

  int? get _restScore => _safeGet<int?>(() => entry.rest);

  int? get _activityScore => _safeGet<int?>(() => entry.physicalActivity);

  String? get _sleepDetails {
    final wakeUpTime = _safeGet<String?>(() => entry.wakeUpTime);
    final nightWakeUps = _safeGet<int?>(() => entry.nightWakeUps);

    if ((wakeUpTime == null || wakeUpTime.trim().isEmpty) &&
        nightWakeUps == null) {
      return null;
    }

    final buffer = StringBuffer();
    if (wakeUpTime != null && wakeUpTime.trim().isNotEmpty) {
      buffer.writeln('Подъём: ${wakeUpTime.trim()}');
    }
    if (nightWakeUps != null) {
      buffer.writeln('Ночных пробуждений: $nightWakeUps');
    }
    return buffer.toString().trim();
  }

  String? get _discomfortDetails {
    final physical = _safeGet<int?>(() => entry.physicalDiscomfort);
    final emotional = _safeGet<int?>(() => entry.emotionalDistress);

    if (physical == null && emotional == null) return null;

    final buffer = StringBuffer();
    if (physical != null) {
      buffer.writeln('Физический дискомфорт: $physical/5');
    }
    if (emotional != null) {
      buffer.writeln('Эмоциональный дистресс: $emotional/5');
    }
    return buffer.toString().trim();
  }

  String? get _emotionalStateDetails {
    final dissociation = _safeGet<int?>(() => entry.dissociation);
    final ruminations = _safeGet<int?>(() => entry.ruminations);
    final selfBlame = _safeGet<int?>(() => entry.selfBlame);
    final suicidalThoughts = _safeGet<int?>(() => entry.suicidalThoughts);

    if (dissociation == null &&
        ruminations == null &&
        selfBlame == null &&
        suicidalThoughts == null) {
      return null;
    }

    final buffer = StringBuffer();
    if (dissociation != null) {
      buffer.writeln('Диссоциация: $dissociation/5');
    }
    if (ruminations != null) {
      buffer.writeln('Зацикленные мысли: $ruminations/5');
    }
    if (selfBlame != null) {
      buffer.writeln('Самообвинение: $selfBlame/5');
    }
    if (suicidalThoughts != null) {
      buffer.writeln('Суицидальные мысли: $suicidalThoughts/5');
    }
    return buffer.toString().trim();
  }

  String? get _problemBehaviorDetails {
    final urges = _safeGet<int?>(() => entry.urges);
    final action = _safeGet<String?>(() => entry.action);

    if (urges == null && (action == null || action.trim().isEmpty)) {
      return null;
    }

    final buffer = StringBuffer();
    if (urges != null) {
      buffer.writeln('Позывы: $urges/5');
    }
    if (action != null && action.trim().isNotEmpty) {
      buffer.writeln('Что произошло: ${action.trim()}');
    }
    return buffer.toString().trim();
  }

  String? get _selfCareDetails {
    final physicalActivity = _safeGet<int?>(() => entry.physicalActivity);
    final pleasure = _safeGet<int?>(() => entry.pleasure);
    final water = _safeGet<String?>(() => entry.water);
    final food = _safeGet<int?>(() => entry.food);

    if (physicalActivity == null &&
        pleasure == null &&
        (water == null || water.trim().isEmpty) &&
        food == null) {
      return null;
    }

    final buffer = StringBuffer();
    if (physicalActivity != null) {
      buffer.writeln('Физическая активность: $physicalActivity/5');
    }
    if (pleasure != null) {
      buffer.writeln('Удовольствие: $pleasure/5');
    }
    if (water != null && water.trim().isNotEmpty) {
      buffer.writeln('Вода: ${water.trim()}');
    }
    if (food != null) {
      buffer.writeln('Питание: $food/5');
    }
    return buffer.toString().trim();
  }

  String? get _skillsDetails {
    final skills = _safeGet<List<dynamic>?>(() => entry.skillsUsed);
    if (skills == null || skills.isEmpty) return null;

    final stringSkills = skills
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (stringSkills.isEmpty) return null;

    return stringSkills.join(', ');
  }

  String _formatDate(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    // Очень простой формат, чтобы не тянуть intl
    final monthsRu = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];

    final monthsEn = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final day = _date.day.toString().padLeft(2, '0');
    final monthName = locale == 'ru'
        ? monthsRu[_date.month - 1]
        : monthsEn[_date.month - 1];
    final year = _date.year.toString();

    return '$day $monthName $year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text(
          'Состояние дня',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 36,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroCard(context),
                      const SizedBox(height: 20),
                      _buildMetricsRow(context),
                      const SizedBox(height: 16),
                      _SectionCard(title: 'Как ты сегодня?', text: _mood),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'За что благодарен себе',
                        text: _grateful,
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Что сделано для цели',
                        text: _importantGoal,
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Сон и ночной отдых',
                        text: _sleepDetails,
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Дискомфорт',
                        text: _discomfortDetails,
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Эмоциональное состояние',
                        text: _emotionalStateDetails,
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Проблемное поведение',
                        text: _problemBehaviorDetails,
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(
                        title: 'Забота о себе',
                        text: _selfCareDetails,
                      ),
                      const SizedBox(height: 12),
                      _SectionCard(title: 'Навыки', text: _skillsDetails),
                      const SizedBox(height: 20),
                      _buildActions(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // Градиентный фон карты (light)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE5E7FF),
                  Color(0xFFFAF5FF),
                  Color(0xFFE0FBFF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
          // Стеклянный слой сверху
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ),
          // Контент
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(context),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_emotionEmoji.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          _emotionEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_mood != null && _mood!.trim().isNotEmpty) ...[
                  Text(
                    _mood!.trim(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (_grateful != null && _grateful!.trim().isNotEmpty) ...[
                  Text(
                    'За что благодарен себе',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _grateful!.trim(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Сон',
            value: _sleepHours,
            unit: 'ч',
            icon: Icons.nights_stay_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Отдых',
            value: _restScore?.toDouble(),
            unit: 'из 5',
            icon: Icons.self_improvement_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            label: 'Активность',
            value: _activityScore?.toDouble(),
            unit: 'из 5',
            icon: Icons.directions_walk_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (onEdit != null) {
                onEdit!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Редактирование пока не настроено'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Редактировать'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (onDelete != null) {
                onDelete!();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Удаление пока не настроено')),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.8)),
              foregroundColor: colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Удалить'),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? text;

  const _SectionCard({required this.title, this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText = (text == null || text!.trim().isEmpty)
        ? 'Нет записей'
        : text!.trim();

    final isEmpty = displayText == 'Нет записей';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black.withValues(alpha: 0.84),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black.withValues(alpha: isEmpty ? 0.4 : 0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayValue = value == null
        ? '—'
        : value!.toStringAsFixed(value! % 1 == 0 ? 0 : 1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF3F4FF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.black.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text(
              displayValue,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
