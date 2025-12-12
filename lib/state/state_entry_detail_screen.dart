import 'package:flutter/material.dart';
import 'state_entry.dart';
import '../theme/app_components.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

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

  String? _sleepDetails(BuildContext context) {
    final wakeUpTime = _safeGet<String?>(() => entry.wakeUpTime);
    final nightWakeUps = _safeGet<int?>(() => entry.nightWakeUps);

    if ((wakeUpTime == null || wakeUpTime.trim().isEmpty) &&
        nightWakeUps == null) {
      return null;
    }

    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    if (wakeUpTime != null && wakeUpTime.trim().isNotEmpty) {
      buffer.writeln(
        l10n.stateEntryDetailSleepWakeUp(wakeUpTime.trim()),
      );
    }
    if (nightWakeUps != null) {
      buffer.writeln(
        l10n.stateEntryDetailSleepNightWakeups(nightWakeUps),
      );
    }
    return buffer.toString().trim();
  }

  String? _discomfortDetails(BuildContext context) {
    final physical = _safeGet<int?>(() => entry.physicalDiscomfort);
    final emotional = _safeGet<int?>(() => entry.emotionalDistress);

    if (physical == null && emotional == null) return null;

    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    if (physical != null) {
      buffer.writeln(l10n.stateEntryDetailDiscomfortPhysical(physical));
    }
    if (emotional != null) {
      buffer.writeln(l10n.stateEntryDetailDiscomfortEmotional(emotional));
    }
    return buffer.toString().trim();
  }

  String? _emotionalStateDetails(BuildContext context) {
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

    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    if (dissociation != null) {
      buffer.writeln(
        l10n.stateEntryDetailEmotionalDissociation(dissociation),
      );
    }
    if (ruminations != null) {
      buffer.writeln(
        l10n.stateEntryDetailEmotionalRuminations(ruminations),
      );
    }
    if (selfBlame != null) {
      buffer.writeln(
        l10n.stateEntryDetailEmotionalSelfBlame(selfBlame),
      );
    }
    if (suicidalThoughts != null) {
      buffer.writeln(
        l10n.stateEntryDetailEmotionalSuicidalThoughts(suicidalThoughts),
      );
    }
    return buffer.toString().trim();
  }

  String? _problemBehaviorDetails(BuildContext context) {
    final urges = _safeGet<int?>(() => entry.urges);
    final action = _safeGet<String?>(() => entry.action);

    if (urges == null && (action == null || action.trim().isEmpty)) {
      return null;
    }

    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    if (urges != null) {
      buffer.writeln(l10n.stateEntryDetailProblemUrge(urges));
    }
    if (action != null && action.trim().isNotEmpty) {
      buffer.writeln(
        l10n.stateEntryDetailProblemAction(action.trim()),
      );
    }
    return buffer.toString().trim();
  }

  String? _selfCareDetails(BuildContext context) {
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

    final l10n = AppLocalizations.of(context)!;
    final buffer = StringBuffer();
    if (physicalActivity != null) {
      buffer.writeln(
        l10n.stateEntryDetailSelfCarePhysicalActivity(physicalActivity),
      );
    }
    if (pleasure != null) {
      buffer.writeln(
        l10n.stateEntryDetailSelfCarePleasure(pleasure),
      );
    }
    if (water != null && water.trim().isNotEmpty) {
      buffer.writeln(
        l10n.stateEntryDetailSelfCareWater(water.trim()),
      );
    }
    if (food != null) {
      buffer.writeln(
        l10n.stateEntryDetailSelfCareFood(food),
      );
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
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat('dd MMMM yyyy', locale);
    return formatter.format(_date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stateEntryDetailAppBarTitle),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.stateEntryDetailSectionSkillsTitle,
              text: _skillsDetails,
            ),
            const SizedBox(height: 12),
            _buildMetricsRow(context),
            const SizedBox(height: 16),
            _SectionCard(
              title: l10n.stateEntryDetailSectionGoalTitle,
              text: _importantGoal,
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.stateEntryDetailSectionSleepTitle,
              text: _sleepDetails(context),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.stateEntryDetailSectionDiscomfortTitle,
              text: _discomfortDetails(context),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.stateEntryDetailSectionEmotionalStateTitle,
              text: _emotionalStateDetails(context),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.stateEntryDetailSectionProblemBehaviorTitle,
              text: _problemBehaviorDetails(context),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: l10n.stateEntryDetailSectionSelfCareTitle,
              text: _selfCareDetails(context),
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

    return Container(
      decoration: AppDecorations.card,
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
                AppLocalizations.of(context)!.stateEntryDetailHeaderGratefulLabel,
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
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: l10n.stateEntryDetailMetricSleepLabel,
            value: _sleepHours,
            unit: l10n.stateEntryDetailMetricSleepUnitHours,
            icon: Icons.nights_stay_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: l10n.stateEntryDetailMetricRestLabel,
            value: _restScore?.toDouble(),
            unit: l10n.stateEntryDetailMetricScoreUnitOutOfFive,
            icon: Icons.self_improvement_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricCard(
            label: l10n.stateEntryDetailMetricActivityLabel,
            value: _activityScore?.toDouble(),
            unit: l10n.stateEntryDetailMetricScoreUnitOutOfFive,
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
    final l10n = AppLocalizations.of(context)!;
    final rawText = text?.trim();
    final isEmpty = rawText == null || rawText.isEmpty;
    final displayText = isEmpty ? l10n.stateEntryDetailNoData : rawText;

    return Container(
      decoration: AppDecorations.card,
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
              displayText!,
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

    return Container(
      decoration: AppDecorations.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey[700]),
            const SizedBox(height: 8),
            Text(
              '$displayValue $unit',
              style: theme.textTheme.titleMedium?.copyWith(
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