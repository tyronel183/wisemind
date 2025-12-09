// ======================================================
// lib/worksheets/fact_check_screens.dart
// Список, просмотр, редактирование, пример
// ======================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wisemind/theme/app_theme.dart';
import 'package:wisemind/billing/billing_service.dart';
import '../analytics/amplitude_service.dart';

import 'fact_check.dart';

const String kFactCheckWorksheetName = 'Проверка фактов';

Future<Box<FactCheckEntry>> _openFactCheckBox() async {
  if (Hive.isBoxOpen(kFactCheckBoxName)) {
    return Hive.box<FactCheckEntry>(kFactCheckBoxName);
  }
  return Hive.openBox<FactCheckEntry>(kFactCheckBoxName);
}

/// Список записей "Проверка фактов"
class FactCheckListScreen extends StatefulWidget {
  const FactCheckListScreen({super.key});

  @override
  State<FactCheckListScreen> createState() => _FactCheckListScreenState();
}

class _FactCheckListScreenState extends State<FactCheckListScreen> {
  @override
  void initState() {
    super.initState();
    // Экран истории рабочего листа "Проверка фактов"
    AmplitudeService.instance.logEvent(
      'worksheet_history',
      properties: {'worksheet': kFactCheckWorksheetName},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Проверка фактов',
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: FutureBuilder<Box<FactCheckEntry>>(
        future: _openFactCheckBox(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Не удалось загрузить записи.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Не удалось загрузить записи.'));
          }

          final box = snapshot.data!;
          return ValueListenableBuilder<Box<FactCheckEntry>>(
            valueListenable: box.listenable(),
            builder: (context, box, _) {
              if (box.isEmpty) {
                return const _FactCheckEmptyState();
              }

              final entries = box.values.toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  final emotionsText = entry.emotions.isEmpty
                      ? 'Без эмоции'
                      : entry.emotions.join(', ');

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                FactCheckDetailScreen(entry: entry),
                          ),
                        );
                      },
                      title: Text(
                        _formatDate(entry.date),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        emotionsText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Открытие формы редактирования рабочего листа
                            AmplitudeService.instance.logEvent(
                              'edit_worksheet_form',
                              properties: {
                                'worksheet': kFactCheckWorksheetName,
                              },
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    FactCheckEditScreen(entry: entry),
                              ),
                            );
                          } else if (value == 'delete') {
                            // Инициирована попытка удалить рабочий лист
                            AmplitudeService.instance.logEvent(
                              'delete_worksheet',
                              properties: {
                                'worksheet': kFactCheckWorksheetName,
                              },
                            );

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Удалить запись?'),
                                content: const Text(
                                  'Эту запись нельзя будет восстановить.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Отмена'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Удалить',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              // Пользователь подтвердил удаление рабочего листа
                              AmplitudeService.instance.logEvent(
                                'delete_worksheet_confirmed',
                                properties: {
                                  'worksheet': kFactCheckWorksheetName,
                                },
                              );
                              await entry.delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Запись удалена'),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Редактировать'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Удалить',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _onCreateNewPressed(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Новая запись'),
      ),
    );
  }
}

Future<void> _onCreateNewPressed(BuildContext context) async {
  // Проверяем доступ через общий биллинговый слой.
  final allowed = await BillingService.ensureProOrShowPaywall(context);
  if (!context.mounted || !allowed) return;

  // Открытие формы нового рабочего листа "Проверка фактов"
  AmplitudeService.instance.logEvent(
    'new_worksheet_form',
    properties: {'worksheet': kFactCheckWorksheetName},
  );

  // Если доступ есть — открываем экран создания новой записи.
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const FactCheckEditScreen(),
    ),
  );
}

class _FactCheckEmptyState extends StatelessWidget {
  const _FactCheckEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          '🔍 Здесь пока нет ни одной записи.\n'
          'Нажмите "+ Новая запись", чтобы заполнить первый рабочий лист.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// Экран просмотра одной записи
class FactCheckDetailScreen extends StatelessWidget {
  final FactCheckEntry entry;

  const FactCheckDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final emotionsText =
        entry.emotions.isEmpty ? '—' : entry.emotions.join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Просмотр записи'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _detailRow('Дата', _formatDate(entry.date)),
          _detailRow('Эмоции', emotionsText),
          _detailRow(
            'Интенсивность эмоции (0–100)',
            entry.initialIntensity.toString(),
          ),
          _detailRow('Побуждающее событие', entry.promptingEvent),
          _detailRow('Проверьте факты (крайности)', entry.factsExtremes),
          _detailRow('Моя интерпретация фактов', entry.myInterpretation),
          _detailRow(
              'Другие интерпретации фактов', entry.alternativeInterpretations),
          _detailRow('Для меня это угроза?', entry.perceivedThreat),
          _detailRow('Другие исходы ситуации', entry.alternativeOutcomes),
          _detailRow('Это катастрофа?', entry.catastropheThoughts),
          _detailRow('Как совладаю с последствиями?', entry.copingPlan),
          _detailRow(
            'Мои эмоции соответствуют фактам? (0–5)',
            entry.emotionMatchScore.toString(),
          ),
          _detailRow(
            'Текущая интенсивность эмоций (0–100)',
            entry.currentIntensity.toString(),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    if (value.trim().isEmpty) value = '—';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// Экран создания / редактирования записи
class FactCheckEditScreen extends StatefulWidget {
  final FactCheckEntry? entry;

  const FactCheckEditScreen({super.key, this.entry});

  bool get isEditing => entry != null;

  @override
  State<FactCheckEditScreen> createState() => _FactCheckEditScreenState();
}

class _FactCheckEditScreenState extends State<FactCheckEditScreen> {
  late DateTime _date;

  late TextEditingController _initialIntensityCtrl;
  late TextEditingController _promptingEventCtrl;
  late TextEditingController _factsExtremesCtrl;
  late TextEditingController _myInterpretationCtrl;
  late TextEditingController _altInterpretationsCtrl;
  late TextEditingController _perceivedThreatCtrl;
  late TextEditingController _altOutcomesCtrl;
  late TextEditingController _catastropheCtrl;
  late TextEditingController _copingCtrl;
  late TextEditingController _currentIntensityCtrl;

  final List<String> _emotionOptions = const [
    '😡 Злость',
    '😨 Страх',
    '😟 Тревога',
    '😢 Грусть',
    '😞 Вина',
    '😳 Стыд',
    '🤢 Отвращение',
    '🤤 Желание',
    '😄 Радость',
    '😔 Обида',
  ];

  late Set<String> _selectedEmotions;

  int? _emotionMatchScore;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;

    _date = e?.date ?? DateTime.now();

    _selectedEmotions = Set<String>.from(e?.emotions ?? []);

    _initialIntensityCtrl = TextEditingController(
      text: e?.initialIntensity.toString() ?? '',
    );
    _promptingEventCtrl =
        TextEditingController(text: e?.promptingEvent ?? '');
    _factsExtremesCtrl =
        TextEditingController(text: e?.factsExtremes ?? '');
    _myInterpretationCtrl =
        TextEditingController(text: e?.myInterpretation ?? '');
    _altInterpretationsCtrl =
        TextEditingController(text: e?.alternativeInterpretations ?? '');
    _perceivedThreatCtrl =
        TextEditingController(text: e?.perceivedThreat ?? '');
    _altOutcomesCtrl =
        TextEditingController(text: e?.alternativeOutcomes ?? '');
    _catastropheCtrl =
        TextEditingController(text: e?.catastropheThoughts ?? '');
    _copingCtrl = TextEditingController(text: e?.copingPlan ?? '');
    _currentIntensityCtrl = TextEditingController(
      text: e?.currentIntensity.toString() ?? '',
    );
    _emotionMatchScore = e?.emotionMatchScore;
  }

  @override
  void dispose() {
    _initialIntensityCtrl.dispose();
    _promptingEventCtrl.dispose();
    _factsExtremesCtrl.dispose();
    _myInterpretationCtrl.dispose();
    _altInterpretationsCtrl.dispose();
    _perceivedThreatCtrl.dispose();
    _altOutcomesCtrl.dispose();
    _catastropheCtrl.dispose();
    _copingCtrl.dispose();
    _currentIntensityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Редактирование записи' : 'Новая запись',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Пилюля "Пример..."
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FactCheckExampleScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.description_outlined),
              label: const Text(
                'Пример заполненного листа "Проверка фактов"',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // мета + заголовок
          Text(
            'Регуляция эмоций',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            'Проверка фактов',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 24),

          // дата
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Дата',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(_formatDate(_date)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  _date = picked;
                });
              }
            },
          ),
          const Divider(height: 32),

          // эмоции
          const Text(
            'Эмоция',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emotionOptions.map((emotion) {
              final selected = _selectedEmotions.contains(emotion);
              return FilterChip(
                label: Text(emotion),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedEmotions.add(emotion);
                    } else {
                      _selectedEmotions.remove(emotion);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          _field(
            label: 'Интенсивность эмоции (0–100)',
            hint: 'От 0 до 100',
            controller: _initialIntensityCtrl,
            keyboardType: TextInputType.number,
          ),

          _field(
            label: 'Побуждающее событие',
            hint:
                'Что произошло и привело вас к этой эмоции? Кто кому что сделал? К чему это привело? '
                'Является ли это проблемой для вас? Будьте максимально конкретны.',
            controller: _promptingEventCtrl,
            maxLines: 4,
          ),

          _field(
            label: 'Проверьте факты!',
            hint: 'Выясните, нет ли крайностей и оценочности в ваших суждениях.',
            controller: _factsExtremesCtrl,
            maxLines: 3,
          ),

          _field(
            label: 'Моя интерпретация фактов',
            hint:
                'Что я допускаю (предполагаю)? Добавляю ли я какую-то свою интерпретацию в описание произошедших событий?',
            controller: _myInterpretationCtrl,
            maxLines: 3,
          ),

          _field(
            label: 'Проверьте факты! (другие интерпретации)',
            hint: 'Напишите как можно больше других интерпретаций этих фактов.',
            controller: _altInterpretationsCtrl,
            maxLines: 3,
          ),

          _field(
            label: 'Для меня это угроза?',
            hint:
                'В чем в данном случае состоит эта угроза? Чем это событие или ситуация угрожают мне? '
                'Какие тревожные события или последствия я ожидаю от этой ситуации?',
            controller: _perceivedThreatCtrl,
            maxLines: 3,
          ),

          _field(
            label: 'Проверьте факты! (другие исходы ситуации)',
            hint:
                'Напишите как можно больше других исходов этой ситуации, учитывая факты.',
            controller: _altOutcomesCtrl,
            maxLines: 3,
          ),

          _field(
            label: 'Это катастрофа?',
            hint:
                'Опишите подробно наиболее плохие последствия, которые только могут произойти.',
            controller: _catastropheCtrl,
            maxLines: 3,
          ),

          _field(
            label: 'Как совладаю с последствиями?',
            hint: 'Опишите способы, как справитесь с этим.',
            controller: _copingCtrl,
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          const Text(
            'Мои эмоции соответствуют фактам? (0–5)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(6, (index) {
              final selected = _emotionMatchScore == index;
              return ChoiceChip(
                label: Text(index.toString()),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _emotionMatchScore = index;
                  });
                },
              );
            }),
          ),

          const SizedBox(height: 16),

          _field(
            label: 'Текущая интенсивность эмоций (0–100)',
            hint: 'От 0 до 100',
            controller: _currentIntensityCtrl,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(
                isEditing ? 'Сохранить изменения' : 'Сохранить',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 2,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final box = await _openFactCheckBox();

    final initialIntensity =
        int.tryParse(_initialIntensityCtrl.text.trim()) ?? 0;
    final currentIntensity =
        int.tryParse(_currentIntensityCtrl.text.trim()) ?? 0;

    const fakeEmail = 'user@example.com';

    if (widget.entry == null) {
      final entry = FactCheckEntry(
        email: fakeEmail,
        date: _date,
        emotions: _selectedEmotions.toList(),
        initialIntensity: initialIntensity,
        promptingEvent: _promptingEventCtrl.text.trim(),
        factsExtremes: _factsExtremesCtrl.text.trim(),
        myInterpretation: _myInterpretationCtrl.text.trim(),
        alternativeInterpretations: _altInterpretationsCtrl.text.trim(),
        perceivedThreat: _perceivedThreatCtrl.text.trim(),
        alternativeOutcomes: _altOutcomesCtrl.text.trim(),
        catastropheThoughts: _catastropheCtrl.text.trim(),
        copingPlan: _copingCtrl.text.trim(),
        emotionMatchScore: _emotionMatchScore ?? 0,
        currentIntensity: currentIntensity,
      );

      await box.add(entry);
      // Новая запись рабочего листа "Проверка фактов" создана
      AmplitudeService.instance.logEvent(
        'worksheet_created',
        properties: {'worksheet': kFactCheckWorksheetName},
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запись добавлена')),
        );
      }
    } else {
      final e = widget.entry!;
      e
        ..date = _date
        ..emotions = _selectedEmotions.toList()
        ..initialIntensity = initialIntensity
        ..promptingEvent = _promptingEventCtrl.text.trim()
        ..factsExtremes = _factsExtremesCtrl.text.trim()
        ..myInterpretation = _myInterpretationCtrl.text.trim()
        ..alternativeInterpretations =
            _altInterpretationsCtrl.text.trim()
        ..perceivedThreat = _perceivedThreatCtrl.text.trim()
        ..alternativeOutcomes = _altOutcomesCtrl.text.trim()
        ..catastropheThoughts = _catastropheCtrl.text.trim()
        ..copingPlan = _copingCtrl.text.trim()
        ..emotionMatchScore = _emotionMatchScore ?? 0
        ..currentIntensity = currentIntensity;

      await e.save();
      // Существующая запись рабочего листа "Проверка фактов" отредактирована
      AmplitudeService.instance.logEvent(
        'worksheet_edited',
        properties: {'worksheet': kFactCheckWorksheetName},
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запись обновлена')),
        );
      }
    }
  }
}

/// Экран с примером заполненного листа
class FactCheckExampleScreen extends StatelessWidget {
  const FactCheckExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пример заполненного листа'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(
          data: kFactCheckExampleHtml,
          style: {
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
              fontSize: FontSize(16),
            ),
            'h2': Style(
              margin: Margins.only(bottom: 12),
              fontWeight: FontWeight.w700,
            ),
            'h3': Style(
              margin: Margins.only(top: 16, bottom: 8),
              fontWeight: FontWeight.w600,
            ),
            'p': Style(
              margin: Margins.only(bottom: 8),
            ),
            'ul': Style(
              margin: Margins.only(bottom: 8, left: 16),
            ),
            'hr': Style(
              margin: Margins.only(top: 12, bottom: 12),
              padding: HtmlPaddings.zero,
              border: Border.all(color: Colors.transparent, width: 0),
            ),
          },
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year.toString();
  return '$d.$m.$y';
}