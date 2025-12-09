import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wisemind/theme/app_theme.dart';

import '../analytics/amplitude_service.dart';
import 'chain_analysis.dart';

const String kChainAnalysisBoxName = 'chain_analysis_entries';

const String kChainAnalysisExampleHtml = '''
<h2>Пример анализа</h2>

<p>Вот пример заполненной цепочки, чтобы вы видели, как происходит разбор шаг за шагом.</p>

<hr>

<h3>1. Дата</h3>

<p>12.02.2025</p>

<hr>

<h3>2. Проблемное поведение</h3>

<p>Сорвался на коллегу, повысил голос и ушёл из разговора.</p>

<hr>

<h3>3. Что конкретно происходило?</h3>

<p>Всё, что произошло между триггером и проблемным поведением:</p>

<ul>
  <li><strong>Мысли:</strong> «Он меня не уважает», «Я опять всё делаю неправильно».</li>
  <li><strong>Эмоции:</strong> раздражение → злость → вспышка гнева.</li>
  <li><strong>Телесные реакции:</strong> жар в груди → напряжённые плечи → учащённое сердцебиение.</li>
  <li><strong>Импульсы:</strong> желание резко ответить, защититься, уйти.</li>
</ul>

<hr>

<h3>4. Побуждающее событие (триггер)</h3>

<p>Коллега сделал замечание резким тоном во время обсуждения.</p>

<hr>

<h3>5. Уязвимости</h3>

<p><strong>Уязвимости</strong> — это факторы, которые делают вас более чувствительным и снижают устойчивость. Они бывают:</p>

<ul>
  <li><strong>Физические:</strong> недосып, боль, голод, усталость, болезни, ПМС, кофеин, алкоголь.</li>
  <li><strong>Эмоциональные:</strong> накопленная тревога, стрессовая неделя, мысли «я недостаточно хорош», одиночество.</li>
</ul>

<p><strong>Пример заполнения:</strong> Недосып → голод → напряжённая неделя → накопленная раздражительность.</p>

<hr>

<h3>6. Последствия для окружения</h3>

<p>Коллега обиделся, разговор прервался, команда почувствовала напряжение.</p>

<hr>

<h3>7. Последствия для меня</h3>

<p>Момент облегчения → потом стыд и вина → упавшее настроение → самокритика.</p>

<hr>

<h3>8. Нанесённый вред</h3>

<p>Испортились рабочие отношения, снизилось доверие коллег, стало сложнее обсуждать задачи открыто.</p>

<hr>

<h3>9. Что можно было бы сделать по-другому?</h3>

<p>Пауза 10 секунд → глубокий выдох → фраза: «Мне нужно минуту, я вернусь» → выйти из комнаты спокойно.</p>

<hr>

<h3>10. Как снизить уязвимость в будущем</h3>

<p>Наладить сон → регулярные приёмы пищи → делать короткие перерывы → планировать отдых в течение недели.</p>

<hr>

<h3>11. Как предотвратить побуждающее событие</h3>

<p>Обсудить с коллегой стиль коммуникации заранее → уточнять тон и смысл, а не реагировать сразу.</p>

<hr>

<h3>12. План исправления</h3>

<p>Извиниться перед коллегой за тон → проговорить, что именно задело → предложить вместе обсудить формат обратной связи.</p>
''';

String _formatDate(DateTime date) {
  final d = date.toLocal();
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year.toString();
  return '$day.$month.$year';
}

Future<Box<ChainAnalysisEntry>> _openChainAnalysisBox() async {
  if (Hive.isBoxOpen(kChainAnalysisBoxName)) {
    return Hive.box<ChainAnalysisEntry>(kChainAnalysisBoxName);
  }
  return Hive.openBox<ChainAnalysisEntry>(kChainAnalysisBoxName);
}

/// Список записей "Анализ нежелательного поведения"
class ChainAnalysisListScreen extends StatefulWidget {
  const ChainAnalysisListScreen({super.key});

  @override
  State<ChainAnalysisListScreen> createState() => _ChainAnalysisListScreenState();
}

class _ChainAnalysisListScreenState extends State<ChainAnalysisListScreen> {
  @override
  void initState() {
    super.initState();
    // Логируем открытие истории рабочего листа
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeService.instance.logEvent(
        'worksheet_history',
        properties: {
          'worksheet': 'Анализ нежелательного поведения',
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Анализ нежелательного поведения',
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: FutureBuilder<Box<ChainAnalysisEntry>>(
        future: _openChainAnalysisBox(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Не удалось загрузить данные.\nПопробуйте ещё раз позже.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final box = snapshot.data!;

          return ValueListenableBuilder<Box<ChainAnalysisEntry>>(
            valueListenable: box.listenable(),
            builder: (context, box, _) {
              final entries = box.values.toList()
                ..sort((a, b) => b.date.compareTo(a.date)); // свежие сверху

              if (entries.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      '🔍 Здесь пока нет ни одной записи.\n'
                      'Нажмите «+ Новая запись», чтобы заполнить первый рабочий лист.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  // В заголовке карточки показываем дату,
                  // в подзаголовке — проблемное поведение (если оно заполнено)
                  final title = _formatDate(entry.date);

                  final subtitle = entry.problematicBehavior.isNotEmpty
                      ? entry.problematicBehavior
                      : 'Без названия';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChainAnalysisDetailScreen(entry: entry),
                          ),
                        );
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Открытие формы редактирования
                            AmplitudeService.instance.logEvent(
                              'edit_worksheet_form',
                              properties: {
                                'worksheet': 'Анализ нежелательного поведения',
                              },
                            );

                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChainAnalysisEditScreen(
                                  existingEntry: entry,
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            // Выбор удаления записи
                            AmplitudeService.instance.logEvent(
                              'delete_worksheet',
                              properties: {
                                'worksheet': 'Анализ нежелательного поведения',
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
                              // Подтверждение удаления
                              AmplitudeService.instance.logEvent(
                                'delete_worksheet_confirmed',
                                properties: {
                                  'worksheet':
                                      'Анализ нежелательного поведения',
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
        onPressed: () async {
          // Открытие формы новой записи
          AmplitudeService.instance.logEvent(
            'new_worksheet_form',
            properties: {
              'worksheet': 'Анализ нежелательного поведения',
            },
          );

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ChainAnalysisEditScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Новая запись'),
      ),
    );
  }
}

/// Экран создания/редактирования одной записи
class ChainAnalysisEditScreen extends StatefulWidget {
  final ChainAnalysisEntry? existingEntry;

  const ChainAnalysisEditScreen({super.key, this.existingEntry});

  @override
  State<ChainAnalysisEditScreen> createState() =>
      _ChainAnalysisEditScreenState();
}

class _ChainAnalysisEditScreenState extends State<ChainAnalysisEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;

  final _problematicBehaviorController = TextEditingController();
  final _promptingEventController = TextEditingController();
  final _environmentController = TextEditingController();
  final _chainLinksController = TextEditingController();
  final _consequencesForOthersController = TextEditingController();
  final _consequencesForMeController = TextEditingController();
  late TextEditingController _damageCtrl;
  late TextEditingController _adaptiveBehaviourCtrl;
  late TextEditingController _decreaseVulnerabilityCtrl;
  late TextEditingController _preventEventCtrl;
  late TextEditingController _fixPlanCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEntry;
    if (e != null) {
      _date = e.date;
      _problematicBehaviorController.text = e.problematicBehavior;
      _promptingEventController.text = e.promptingEvent;
      _environmentController.text = e.environment;
      _chainLinksController.text = e.chainLinks;
      _consequencesForOthersController.text = e.consequencesForOthers;
      _consequencesForMeController.text = e.consequencesForMe;
      _damageCtrl = TextEditingController(text: e.damage);
      _adaptiveBehaviourCtrl =
          TextEditingController(text: e.adaptiveBehaviour);
      _decreaseVulnerabilityCtrl =
          TextEditingController(text: e.decreaseVulnerability);
      _preventEventCtrl =
          TextEditingController(text: e.preventEvent);
      _fixPlanCtrl = TextEditingController(text: e.fixPlan);
    } else {
      _date = DateTime.now();
      _damageCtrl = TextEditingController();
      _adaptiveBehaviourCtrl = TextEditingController();
      _decreaseVulnerabilityCtrl = TextEditingController();
      _preventEventCtrl = TextEditingController();
      _fixPlanCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _problematicBehaviorController.dispose();
    _promptingEventController.dispose();
    _environmentController.dispose();
    _chainLinksController.dispose();
    _consequencesForOthersController.dispose();
    _consequencesForMeController.dispose();
    _damageCtrl.dispose();
    _adaptiveBehaviourCtrl.dispose();
    _decreaseVulnerabilityCtrl.dispose();
    _preventEventCtrl.dispose();
    _fixPlanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final box = await _openChainAnalysisBox();
    final isNew = widget.existingEntry == null;

    if (isNew) {
      final entry = ChainAnalysisEntry(
        email: 'local@user', // пока заглушка, до авторизации
        date: _date,
        problematicBehavior: _problematicBehaviorController.text.trim(),
        promptingEvent: _promptingEventController.text.trim(),
        environment: _environmentController.text.trim(),
        chainLinks: _chainLinksController.text.trim(),
        adaptiveBehaviour: _adaptiveBehaviourCtrl.text.trim(),
        consequencesForOthers:
            _consequencesForOthersController.text.trim(),
        consequencesForMe: _consequencesForMeController.text.trim(),
        damage: _damageCtrl.text.trim(),
        decreaseVulnerability:
            _decreaseVulnerabilityCtrl.text.trim(),
        preventEvent: _preventEventCtrl.text.trim(),
        fixPlan: _fixPlanCtrl.text.trim(),
        worksheetName: 'Анализ нежелательного поведения',
      );

      await box.add(entry);

      // Логируем создание новой записи рабочего листа
      AmplitudeService.instance.logEvent(
        'worksheet_created',
        properties: {
          'worksheet': 'Анализ нежелательного поведения',
        },
      );
    } else {
      final e = widget.existingEntry!;

      e
        ..date = _date
        ..problematicBehavior =
            _problematicBehaviorController.text.trim()
        ..promptingEvent = _promptingEventController.text.trim()
        ..environment = _environmentController.text.trim()
        ..chainLinks = _chainLinksController.text.trim()
        ..adaptiveBehaviour = _adaptiveBehaviourCtrl.text.trim()
        ..consequencesForOthers =
            _consequencesForOthersController.text.trim()
        ..consequencesForMe =
            _consequencesForMeController.text.trim()
        ..damage = _damageCtrl.text.trim()
        ..decreaseVulnerability =
            _decreaseVulnerabilityCtrl.text.trim()
        ..preventEvent = _preventEventCtrl.text.trim()
        ..fixPlan = _fixPlanCtrl.text.trim();

      await e.save();

      // Логируем редактирование существующей записи рабочего листа
      AmplitudeService.instance.logEvent(
        'worksheet_edited',
        properties: {
          'worksheet': 'Анализ нежелательного поведения',
        },
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isNew ? 'Запись добавлена' : 'Запись обновлена'),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingEntry != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Редактировать анализ'
              : 'Анализ нежелательного поведения',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChainAnalysisExampleScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text(
                    'Пример заполненного листа "Анализ нежелательного поведения"',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Осознанность',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Анализ нежелательного поведения',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Дата
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Дата'),
                subtitle: Text(_formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const Divider(height: 24),

              // Проблемное поведение (обязательное, 140 символов)
              TextFormField(
                controller: _problematicBehaviorController,
                maxLength: 140,
                decoration: const InputDecoration(
                  labelText: 'Проблемное поведение',
                  hintText: 'Например: бытовой алкоголизм, селфхарм, грызу ногти и так далее',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Опиши проблемное поведение';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Что именно происходило (цепочка)
              TextFormField(
                controller: _chainLinksController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Что именно происходило (цепочка)',
                  hintText:
                      'Перечислите конкретное поведение и события в окружении, которые происходили',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Побуждающее событие
              TextFormField(
                controller: _promptingEventController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Побуждающее событие',
                  hintText:
                      'Вспомните, что случилось непосредственно перед тем, как побуждение или мысль пришли в вашу голову',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Уязвимости (environment)
              TextFormField(
                controller: _environmentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Уязвимости',
                  hintText:
                      'Что во мне или в моем окружении сделало меня уязвимой(-ым). Например, усталость, напряжение от работы, зубная боль и так далее',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Последствия для окружения
              TextFormField(
                controller: _consequencesForOthersController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Последствия для окружения',
                  hintText: 'Каковы были последствия для тех, кто вас окружал в процессе проблемного поведения или после него',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Последствия для меня
              TextFormField(
                controller: _consequencesForMeController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Последствия для меня',
                  hintText:
                      'Чем проблемное поведение было чревато для вас',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Как можно было по-другому (адаптивное поведение)
              TextFormField(
                controller: _adaptiveBehaviourCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Как можно было по-другому?',
                  hintText:
                      'Перечислите новые, более адаптивные виды поведения, которыми следует заменить неэффективное',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Ущерб
              TextFormField(
                controller: _damageCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Нанесённый вред',
                  hintText:
                      'Какой вред нанесён? Отношения, репутация, деньги, здоровье…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Как снизить уязвимость
              TextFormField(
                controller: _decreaseVulnerabilityCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Как снизить уязвимость в будущем?',
                  hintText:
                      'Что планируете сделать, чтобы было меньше факторов, влияющих на проявление проблемного поведения',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Как предотвратить событие
              TextFormField(
                controller: _preventEventCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Как предотвратить побуждающее событие?',
                  hintText:
                      'Что планируете сделать, чтобы избежать или предотвратить побуждающее событие, вызвавшее проблемное поведение',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // План исправления
              TextFormField(
                controller: _fixPlanCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'План исправления',
                  hintText:
                      'Что вы можете сделать сейчас, чтобы уменьшить ущерб и восстановить отношения?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: Text(
                    isEdit ? 'Сохранить изменения' : 'Сохранить',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ChainAnalysisExampleScreen extends StatelessWidget {
  const ChainAnalysisExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пример заполненного листа'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Html(
  data: kChainAnalysisExampleHtml,
  style: {
    "body": Style(
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
    ),
    "h2": Style(margin: Margins.only(bottom: 12)),
    "h3": Style(margin: Margins.only(top: 16, bottom: 8)),
    "p": Style(margin: Margins.only(bottom: 8)),
    "ul": Style(margin: Margins.only(bottom: 8, left: 16)),
    "hr": Style(
      margin: Margins.only(top: 12, bottom: 12),
      border: const Border(
        bottom: BorderSide(
          color: Colors.black26,
          width: 1,
        ),
      ),
    ),
  },
),
        ),
      ),
    );
  }
}
/// Детальный просмотр записи
class ChainAnalysisDetailScreen extends StatelessWidget {
  final ChainAnalysisEntry entry;
  const ChainAnalysisDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали анализа'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _detailRow('Дата', _formatDate(entry.date)),
          _detailRow('Проблемное поведение', entry.problematicBehavior),
          _detailRow('Что именно происходило (цепочка)', entry.chainLinks),
          _detailRow('Побуждающее событие', entry.promptingEvent),
          _detailRow('Уязвимости', entry.environment),
          _detailRow('Последствия для окружения', entry.consequencesForOthers),
          _detailRow('Последствия для меня', entry.consequencesForMe),
          _detailRow('Как можно было по-другому?', entry.adaptiveBehaviour),
          _detailRow('Нанесённый вред', entry.damage),
          _detailRow('Как снизить уязвимость в будущем?', entry.decreaseVulnerability),
          _detailRow('Как предотвратить побуждающее событие?', entry.preventEvent),
          _detailRow('План исправления', entry.fixPlan),
        ],
      ),
    );
  }
}

Widget _detailRow(String title, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        if (value != null && value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(value),
          ),
      ],
    ),
  );
}