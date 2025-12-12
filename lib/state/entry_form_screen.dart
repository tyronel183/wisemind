import 'package:flutter/material.dart';
import '../utils/date_format.dart';
import 'state_entry.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

const List<String> kAllSkills = [
  'Карта дня',
  'Анализ проблемного поведения',
  'Мудрый разум',
  'Наблюдение',
  'Описание',
  'Участие',
  'Безоценочность',
  'Однозадачность',
  'Эффективность',
  'Осознанное питание',
  'Серфинг на волне желания',
  'STOP',
  'За и Против',
  'ACCEPTS',
  'TIP',
  '5 чувств',
  'IMPROVE',
  'Радикальное принятие',
  'Полуулыбка, раскрытые ладони',
  'Готовность',
  'Осознанность мыслей',
  'Определение эмоций',
  'Проверка фактов',
  'Противоположное действие',
  'Решение проблем',
  'А: накапливать позитивные эмоции',
  'В: наращивать мастерство',
  'С: справляться заранее',
  'PLEASE: снижать физическую уязвимость',
  'Альтернативный бунт',
  'DEAR',
  'MAN',
  'GIVE',
  'FAST',
  'Валидация',
];

class EntryFormScreen extends StatefulWidget {
  const EntryFormScreen({super.key, this.existing});

  final StateEntry? existing;

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  late DateTime _date;

  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _gratefulController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  int _rest = 3;
  double _sleepHours = 8.0;
  String _wakeUpTime = '07:00';
  int _nightWakeUps = 0;

  int _physicalDiscomfort = 0;
  int _emotionalDistress = 0;

  int _dissociation = 0;
  int _ruminations = 0;
  int _selfBlame = 0;
  int _suicidalThoughts = 0;

  int _urges = 0;
  final TextEditingController _actionController = TextEditingController();

  int _physicalActivity = 2;
  int _pleasure = 2;
  String _water = '2';
  int _food = 3;

  List<String> _selectedSkills = [];

  final List<String> _moodEmojis = ['😢', '😕', '😐', '🙂', '😎'];
  int _moodIndex = -1;

  List<String> get _wakeOptions {
    final List<String> result = ['Раньше 4:00'];
    final start = const TimeOfDay(hour: 4, minute: 0);
    for (int i = 0; i <= 18; i++) {
      final minutes = start.hour * 60 + start.minute + i * 30;
      final h = minutes ~/ 60;
      final m = minutes % 60;
      final hh = h.toString().padLeft(2, '0');
      final mm = m.toString().padLeft(2, '0');
      result.add('$hh:$mm');
    }
    result.add('Позже 13:00');
    return result;
  }

  List<double> get _sleepOptions {
    final items = <double>[];
    for (double h = 1; h <= 12; h += 0.5) {
      items.add(h);
    }
    return items;
  }

  List<String> get _waterOptions {
    final items = <String>[];
    for (double l = 1; l <= 4; l += 0.5) {
      if (l == l.roundToDouble()) {
        items.add(l.toStringAsFixed(0));
      } else {
        items.add(l.toStringAsFixed(1));
      }
    }
    items.add('Больше 4 л');
    return items;
  }

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _date = e.date;
      _moodController.text = e.mood ?? '';
      _moodIndex = _moodEmojis.indexOf(_moodController.text);
      _gratefulController.text = e.grateful ?? '';
      _goalController.text = e.importantGoal ?? '';

      _rest = e.rest;
      _sleepHours = e.sleepHours;
      _wakeUpTime = e.wakeUpTime;
      _nightWakeUps = e.nightWakeUps;

      _physicalDiscomfort = e.physicalDiscomfort;
      _emotionalDistress = e.emotionalDistress;

      _dissociation = e.dissociation;
      _ruminations = e.ruminations;
      _selfBlame = e.selfBlame;
      _suicidalThoughts = e.suicidalThoughts;

      _urges = e.urges ?? 0;
      _actionController.text = e.action ?? '';

      _physicalActivity = e.physicalActivity;
      _pleasure = e.pleasure;
      _water = e.water;
      _food = e.food;

      _selectedSkills = List<String>.from(e.skillsUsed);
    } else {
      _date = DateTime.now();
      _wakeUpTime = '07:00';
      _water = '2';
      _selectedSkills = [];
      _urges = 0;
      _moodIndex = -1;
    }
  }

  @override
  void dispose() {
    _moodController.dispose();
    _gratefulController.dispose();
    _goalController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _save() {
    final id =
        widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final entry = StateEntry(
      id: id,
      date: _date,
      mood: _moodController.text.trim().isEmpty
          ? null
          : _moodController.text.trim(),
      grateful: _gratefulController.text.trim().isEmpty
          ? null
          : _gratefulController.text.trim(),
      importantGoal: _goalController.text.trim().isEmpty
          ? null
          : _goalController.text.trim(),
      rest: _rest,
      sleepHours: _sleepHours,
      wakeUpTime: _wakeUpTime,
      nightWakeUps: _nightWakeUps,
      physicalDiscomfort: _physicalDiscomfort,
      emotionalDistress: _emotionalDistress,
      dissociation: _dissociation,
      ruminations: _ruminations,
      selfBlame: _selfBlame,
      suicidalThoughts: _suicidalThoughts,
      urges: _urges,
      action: _actionController.text.trim().isEmpty
          ? null
          : _actionController.text.trim(),
      physicalActivity: _physicalActivity,
      pleasure: _pleasure,
      water: _water,
      food: _food,
      skillsUsed: _selectedSkills,
    );

    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? l10n.entryFormEditAppBarTitle : l10n.entryFormNewAppBarTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.gapMedium,
        ),
        children: [
          const SizedBox(height: AppSpacing.gapMedium),

          // ОБЩЕЕ СОСТОЯНИЕ
          FormSectionCard(
            title: l10n.entryFormSectionGeneralTitle,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.entryFormFieldDateLabel),
                subtitle: Text(formatDate(_date)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.entryFormMoodQuestion,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_moodEmojis.length, (index) {
                  final emoji = _moodEmojis[index];
                  final selected = _moodIndex == index;
                  return _EmojiChoiceChip(
                    emoji: emoji,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _moodIndex = -1;
                          _moodController.text = '';
                        } else {
                          _moodIndex = index;
                          _moodController.text = emoji;
                        }
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _gratefulController,
                label: l10n.entryFormFieldGratefulLabel,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _goalController,
                label: l10n.entryFormFieldGoalLabel,
                maxLines: 2,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // СОН
          FormSectionCard(
            title: l10n.entryFormSectionSleepTitle,
            children: [
              _buildChoiceRow(
                label: l10n.entryFormFieldRestLabel,
                value: _rest,
                onChanged: (v) => setState(() => _rest = v),
              ),
              const SizedBox(height: 16),
              _buildSleepDropdown(),
              const SizedBox(height: 16),
              _buildWakeUpDropdown(),
              const SizedBox(height: 16),
              _buildChoiceRow(
                label: l10n.entryFormFieldNightWakeupsLabel,
                value: _nightWakeUps,
                onChanged: (v) => setState(() => _nightWakeUps = v),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ДИСКОМФОРТ
          FormSectionCard(
            title: l10n.entryFormSectionDiscomfortTitle,
            children: [
              _buildChoiceRow(
                label: l10n.entryFormFieldPhysicalDiscomfortLabel,
                value: _physicalDiscomfort,
                onChanged: (v) =>
                    setState(() => _physicalDiscomfort = v),
              ),
              const SizedBox(height: 8),
              _buildChoiceRow(
                label: l10n.entryFormFieldEmotionalDiscomfortLabel,
                value: _emotionalDistress,
                onChanged: (v) =>
                    setState(() => _emotionalDistress = v),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ЭМОЦИОНАЛЬНОЕ СОСТОЯНИЕ
          FormSectionCard(
            title: l10n.entryFormSectionEmotionalStateTitle,
            children: [
              _buildChoiceRow(
                label: l10n.entryFormFieldDissociationLabel,
                value: _dissociation,
                onChanged: (v) => setState(() => _dissociation = v),
              ),
              const SizedBox(height: 8),
              _buildChoiceRow(
                label: l10n.entryFormFieldRuminationsLabel,
                value: _ruminations,
                onChanged: (v) => setState(() => _ruminations = v),
              ),
              const SizedBox(height: 8),
              _buildChoiceRow(
                label: l10n.entryFormFieldSelfBlameLabel,
                value: _selfBlame,
                onChanged: (v) => setState(() => _selfBlame = v),
              ),
              const SizedBox(height: 8),
              _buildChoiceRow(
                label: l10n.entryFormFieldSuicidalThoughtsLabel,
                value: _suicidalThoughts,
                onChanged: (v) =>
                    setState(() => _suicidalThoughts = v),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ПРОБЛЕМНОЕ ПОВЕДЕНИЕ
          FormSectionCard(
            title: l10n.entryFormSectionProblemBehaviorTitle,
            children: [
              Text(
                l10n.entryFormProblemBehaviorHint,
              ),
              const SizedBox(height: 12),
              _buildChoiceRow(
                label: l10n.entryFormFieldUrgesLabel,
                value: _urges,
                onChanged: (v) => setState(() => _urges = v),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _actionController,
                label: l10n.entryFormFieldActionLabel,
                maxLines: 2,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ЗАБОТА О СЕБЕ
          FormSectionCard(
            title: l10n.entryFormSectionSelfCareTitle,
            children: [
              _buildChoiceRow(
                label: l10n.entryFormFieldPhysicalActivityLabel,
                value: _physicalActivity,
                onChanged: (v) =>
                    setState(() => _physicalActivity = v),
              ),
              const SizedBox(height: 8),
              _buildChoiceRow(
                label: l10n.entryFormFieldPleasureLabel,
                value: _pleasure,
                onChanged: (v) => setState(() => _pleasure = v),
              ),
              const SizedBox(height: 16),
              _buildWaterDropdown(),
              const SizedBox(height: 16),
              _buildChoiceRow(
                label: l10n.entryFormFieldMealsCountLabel,
                value: _food,
                onChanged: (v) => setState(() => _food = v),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // НАВЫКИ
          FormSectionCard(
            title: l10n.entryFormSectionSkillsTitle,
            children: [
              Text(l10n.entryFormSkillsHint),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final skill in _selectedSkills)
                    Container(
                      decoration: AppDecorations.filledChip,
                      padding: AppChipStyles.padding,
                      child: Text(
                        skill,
                        style: AppTypography.chipLabel,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openSkillsSelector,
                  icon: const Icon(Icons.tune),
                  label: Text(l10n.entryFormSkillsButtonLabel),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapXL),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 16),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                elevation: WidgetStateProperty.all(0),
                overlayColor:
                    WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.white.withValues(alpha: 0.15);
                  }
                  return null;
                }),
                animationDuration:
                    const Duration(milliseconds: 120),
              ),
              onPressed: _save,
              child: Text(
                isEdit
                    ? l10n.entryFormButtonSaveEdit
                    : l10n.entryFormButtonSaveNew,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceRow({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(6, (index) {
            final selected = value == index;
            return AppPillChoice(
              label: index.toString(),
              selected: selected,
              onTap: () => onChanged(index),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSleepDropdown() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.entryFormFieldSleepHoursLabel),
        const SizedBox(height: 8),
        DropdownButton<double>(
          value: _sleepHours,
          isExpanded: true,
          items: _sleepOptions
              .map(
                (h) => DropdownMenuItem<double>(
                  value: h,
                  child: Text(
                    h.toStringAsFixed(
                      h == h.roundToDouble() ? 0 : 1,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _sleepHours = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildWakeUpDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final options = _wakeOptions;
    if (!options.contains(_wakeUpTime)) {
      _wakeUpTime = options[1];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.entryFormFieldWakeTimeLabel),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _wakeUpTime,
          isExpanded: true,
          items: options
              .map(
                (t) => DropdownMenuItem<String>(
                  value: t,
                  child: Text(
                    t == 'Раньше 4:00'
                        ? l10n.entryFormWakeOptionBefore4
                        : t == 'Позже 13:00'
                            ? l10n.entryFormWakeOptionAfter13
                            : t,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _wakeUpTime = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildWaterDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final options = _waterOptions;
    if (!options.contains(_water)) {
      _water = '2';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.entryFormFieldWaterLabel),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _water,
          isExpanded: true,
          items: options
              .map(
                (w) => DropdownMenuItem<String>(
                  value: w,
                  child: Text(
                    w == 'Больше 4 л'
                        ? l10n.entryFormWaterOptionMoreThan4
                        : l10n.entryFormWaterOptionLiters(w),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _water = value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _openSkillsSelector() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final tempSelected = Set<String>.from(_selectedSkills);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(l10n.entryFormSkillsDialogTitle),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView(
                  children: kAllSkills.map((skill) {
                    final selected = tempSelected.contains(skill);
                    return CheckboxListTile(
                      value: selected,
                      title: Text(skill),
                      onChanged: (checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            tempSelected.add(skill);
                          } else {
                            tempSelected.remove(skill);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(null),
                  child: Text(l10n.entryFormDialogCancel),
                ),
                TextButton(
                  onPressed: () {
                    final list = tempSelected.toList()..sort();
                    Navigator.of(context).pop(list);
                  },
                  child: Text(l10n.entryFormDialogConfirm),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedSkills = result;
      });
    }
  }
}

class _EmojiChoiceChip extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _EmojiChoiceChip({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color bg = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : Colors.transparent;
    final Color borderColor =
        selected ? theme.colorScheme.primary : Colors.grey.shade300;
    final Color textColor =
        selected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}