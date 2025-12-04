import 'package:flutter/material.dart';
import 'state_entry.dart';

/// Детальный экран записи "Состояние дня"
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

  // Используем настроение как эмодзи
  String get _emotionEmoji => (_mood ?? '').trim();

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
      buffer.writeln('Физический: $physical/5');
    }
    if (emotional != null) {
      buffer.writeln('Эмоциональный: $emotional/5');
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
      buffer.writeln('Сила импульса: $urges/5');
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
      buffer.writeln('Количество выпитой жидкости: ${water.trim()} л');
    }
    if (food != null) {
      buffer.writeln('Количество приемов пищи: $food');
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

    final day = _date.day.toString().padLeft(2, '0');
    final monthName = monthsRu[_date.month - 1];
    final year = _date.year.toString();

    return '$day $monthName $year';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Состояние дня'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 12),
            _SectionCard(title: 'Примененные навыки', text: _skillsDetails),
            const SizedBox(height: 12),
            _buildMetricsRow(context),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Что сделано для достижения цели',
              text: _importantGoal,
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Качество сна',
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
            const SizedBox(height: 20),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _formatDate(context),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_emotionEmoji.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _emotionEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
              ],
            ),
            if (_grateful != null && _grateful!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'За что себя благодарю',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _grateful!.trim(),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
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
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: 'Отдых',
            value: _restScore?.toDouble(),
            unit: 'из 5',
            icon: Icons.self_improvement_rounded,
          ),
        ),
        const SizedBox(width: 8),
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

}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? text;

  const _SectionCard({
    required this.title,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayText =
        (text == null || text!.trim().isEmpty) ? 'Нет записей' : text!.trim();
    final isEmpty = displayText == 'Нет записей';

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isEmpty ? Colors.grey : null,
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

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              '$displayValue $unit',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}