import 'package:flutter/material.dart';
import '../utils/date_format.dart';
import 'state_entry.dart';

const List<String> kAllSkills = [
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
    final start = TimeOfDay(hour: 4, minute: 0);
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
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать запись' : 'Новая запись'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Дата'),
            subtitle: Text(formatDate(_date)),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDate,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Как вы сегодня?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(_moodEmojis.length, (index) {
              final emoji = _moodEmojis[index];
              final selected = _moodIndex == index;
              return ChoiceChip(
                label: Text(emoji, style: const TextStyle(fontSize: 20)),
                selected: selected,
                onSelected: (_) {
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

          TextField(
            controller: _gratefulController,
            maxLength: 140,
            decoration: const InputDecoration(
              labelText: 'За что я себя сегодня благодарю?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _goalController,
            maxLength: 140,
            decoration: const InputDecoration(
              labelText: 'Что сделано для достижения цели?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Сон',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Как отдохнули? (0–5)',
            value: _rest,
            onChanged: (v) => setState(() => _rest = v),
          ),
          const SizedBox(height: 16),
          _buildSleepDropdown(),
          const SizedBox(height: 16),
          _buildWakeUpDropdown(),
          const SizedBox(height: 16),
          _buildChoiceRow(
            label: 'Сколько было ночных пробуждений? (0–5)',
            value: _nightWakeUps,
            onChanged: (v) => setState(() => _nightWakeUps = v),
          ),
          const SizedBox(height: 24),

          const Text(
            'Дискомфорт',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Физический дискомфорт (0–5)',
            value: _physicalDiscomfort,
            onChanged: (v) => setState(() => _physicalDiscomfort = v),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Эмоциональный дискомфорт (0–5)',
            value: _emotionalDistress,
            onChanged: (v) => setState(() => _emotionalDistress = v),
          ),
          const SizedBox(height: 24),

          const Text(
            'Эмоциональное состояние',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Ощущение нереальности (0–5)',
            value: _dissociation,
            onChanged: (v) => setState(() => _dissociation = v),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Руминации, навязчивые мысли (0–5)',
            value: _ruminations,
            onChanged: (v) => setState(() => _ruminations = v),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Самообвинение (0–5)',
            value: _selfBlame,
            onChanged: (v) => setState(() => _selfBlame = v),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Суицидальные мысли (0–5)',
            value: _suicidalThoughts,
            onChanged: (v) => setState(() => _suicidalThoughts = v),
          ),
          const SizedBox(height: 24),

          const Text(
            'Проблемное поведение',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Заполняйте, если отслеживаете какое-то конкретное проблемное поведение.',
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Насколько сильный импульс? (0–5)',
            value: _urges,
            onChanged: (v) => setState(() => _urges = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _actionController,
            maxLength: 140,
            decoration: const InputDecoration(
              labelText: 'Что сделали?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Забота о себе',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Физическая активность (0–5)',
            value: _physicalActivity,
            onChanged: (v) => setState(() => _physicalActivity = v),
          ),
          const SizedBox(height: 8),
          _buildChoiceRow(
            label: 'Сколько было удовольствия (0–5)',
            value: _pleasure,
            onChanged: (v) => setState(() => _pleasure = v),
          ),
          const SizedBox(height: 16),
          _buildWaterDropdown(),
          const SizedBox(height: 16),
          _buildChoiceRow(
            label: 'Сколько раз ели? (0–5)',
            value: _food,
            onChanged: (v) => setState(() => _food = v),
          ),
          const SizedBox(height: 24),

          const Text(
            'Навыки',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text('Можно выбрать несколько.'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedSkills.isEmpty
                      ? 'Навыки не выбраны'
                      : _selectedSkills.join(', '),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _openSkillsSelector,
                    child: const Text('Выбрать навыки'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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

                // Лёгкая анимация при нажатии
                overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.white.withValues(alpha: 0.15);
                  }
                  return null;
                }),

                animationDuration: const Duration(milliseconds: 120),
              ),
              onPressed: _save,
              child: Text(
                isEdit ? 'Сохранить изменения' : 'Сохранить',
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
          children: List.generate(6, (index) {
            return ChoiceChip(
              label: Text(index.toString()),
              selected: value == index,
              onSelected: (_) => onChanged(index),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSleepDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Сколько спали (часы)?'),
        const SizedBox(height: 8),
        DropdownButton<double>(
          value: _sleepHours,
          isExpanded: true,
          items: _sleepOptions
              .map(
                (h) => DropdownMenuItem<double>(
                  value: h,
                  child: Text(
                    h.toStringAsFixed(h == h.roundToDouble() ? 0 : 1),
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
    final options = _wakeOptions;
    if (!options.contains(_wakeUpTime)) {
      _wakeUpTime = options[1];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Во сколько проснулись?'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _wakeUpTime,
          isExpanded: true,
          items: options
              .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
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
    final options = _waterOptions;
    if (!options.contains(_water)) {
      _water = '2';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Сколько пили жидкости?'),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _water,
          isExpanded: true,
          items: options
              .map(
                (w) => DropdownMenuItem<String>(
                  value: w,
                  child: Text(w == 'Больше 4 л' ? w : '$w л'),
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
        final tempSelected = Set<String>.from(_selectedSkills);

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Выберите навыки'),
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
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () {
                    final list = tempSelected.toList()..sort();
                    Navigator.of(context).pop(list);
                  },
                  child: const Text('Готово'),
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