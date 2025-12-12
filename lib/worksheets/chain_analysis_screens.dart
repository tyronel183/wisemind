import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wisemind/theme/app_theme.dart';
import 'package:wisemind/l10n/app_localizations.dart';

import '../theme/app_components.dart';
import '../theme/app_spacing.dart';

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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l.chainAnalysisListAppBarTitle,
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.chainAnalysisLoadError,
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l.chainAnalysisEmptyList,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final title = _formatDate(entry.date);
                  final subtitle = entry.problematicBehavior.isNotEmpty
                      ? entry.problematicBehavior
                      : l.chainAnalysisUntitled;
                  return Container(
                    decoration: AppDecorations.card,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.cardPaddingHorizontal,
                        vertical: AppSpacing.cardPaddingVertical,
                      ),
                      title: Text(
                        title,
                        style: AppTypography.cardTitle,
                      ),
                      subtitle: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySecondary,
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChainAnalysisDetailScreen(entry: entry),
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
                                title: Text(l.chainAnalysisDeleteDialogTitle),
                                content: Text(
                                  l.chainAnalysisDeleteDialogBody,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(l.chainAnalysisDeleteDialogCancel),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(
                                      l.chainAnalysisDeleteDialogConfirm,
                                      style: const TextStyle(color: Colors.red),
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
                                  'worksheet': 'Анализ нежелательного поведения',
                                },
                              );
                              await entry.delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l.chainAnalysisDeleteSnack),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l.chainAnalysisMenuEdit),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              l.chainAnalysisMenuDelete,
                              style: const TextStyle(color: Colors.red),
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
        label: Text(l.chainAnalysisFabNewEntry),
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
    final l = AppLocalizations.of(context)!;
    // Проблемное поведение — обязательное поле
    final problematic = _problematicBehaviorController.text.trim();
    if (problematic.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.chainAnalysisProblemRequiredSnack)),
        );
      }
      return;
    }

    final box = await _openChainAnalysisBox();
    final isNew = widget.existingEntry == null;

    if (isNew) {
      final entry = ChainAnalysisEntry(
        email: 'local@user', // пока заглушка, до авторизации
        date: _date,
        problematicBehavior: problematic,
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
        ..problematicBehavior = problematic
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
        content: Text(isNew ? l.chainAnalysisSaveSnackNew : l.chainAnalysisSaveSnackEdit),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = widget.existingEntry != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEdit ? l.chainAnalysisEditAppBarTitle : l.chainAnalysisNewAppBarTitle,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.gapMedium,
            ),
            children: [
              const SizedBox(height: AppSpacing.gapMedium),

              // Кнопка с примером заполнения
              Container(
                decoration: AppDecorations.subtleCard,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChainAnalysisExampleScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l.chainAnalysisExampleCardTitle,
                            style: AppTypography.bodySecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.gapLarge),

              // Блок: заголовок рабочего листа + дата
              FormSectionCard(
                title: l.chainAnalysisSectionGeneralTitle,
                children: [
                  Text(
                    l.chainAnalysisSectionMindfulnessLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.chainAnalysisSectionWorksheetTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.chainAnalysisFieldDateLabel),
                    subtitle: Text(_formatDate(_date)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    controller: _problematicBehaviorController,
                    label: l.chainAnalysisFieldProblemLabel,
                    hint: l.chainAnalysisFieldProblemHint,
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.gapLarge),

              // Блок: цепочка
              FormSectionCard(
                title: l.chainAnalysisSectionChainTitle,
                children: [
                  AppTextField(
                    controller: _chainLinksController,
                    label: l.chainAnalysisFieldChainLinksLabel,
                    hint: l.chainAnalysisFieldChainLinksHint,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _promptingEventController,
                    label: l.chainAnalysisFieldPromptingEventLabel,
                    hint: l.chainAnalysisFieldPromptingEventHint,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _environmentController,
                    label: l.chainAnalysisFieldVulnerabilitiesLabel,
                    hint: l.chainAnalysisFieldVulnerabilitiesHint,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.gapLarge),

              FormSectionCard(
                title: l.chainAnalysisSectionConsequencesTitle,
                children: [
                  AppTextField(
                    controller: _consequencesForOthersController,
                    label: l.chainAnalysisFieldConsequencesOthersLabel,
                    hint: l.chainAnalysisFieldConsequencesOthersHint,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _consequencesForMeController,
                    label: l.chainAnalysisFieldConsequencesMeLabel,
                    hint: l.chainAnalysisFieldConsequencesMeHint,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _damageCtrl,
                    label: l.chainAnalysisFieldDamageLabel,
                    hint: l.chainAnalysisFieldDamageHint,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.gapLarge),

              FormSectionCard(
                title: l.chainAnalysisSectionPlanTitle,
                children: [
                  AppTextField(
                    controller: _adaptiveBehaviourCtrl,
                    label: l.chainAnalysisFieldAdaptiveBehaviourLabel,
                    hint: l.chainAnalysisFieldAdaptiveBehaviourHint,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _decreaseVulnerabilityCtrl,
                    label: l.chainAnalysisFieldDecreaseVulnerabilityLabel,
                    hint: l.chainAnalysisFieldDecreaseVulnerabilityHint,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _preventEventCtrl,
                    label: l.chainAnalysisFieldPreventEventLabel,
                    hint: l.chainAnalysisFieldPreventEventHint,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _fixPlanCtrl,
                    label: l.chainAnalysisFieldFixPlanLabel,
                    hint: l.chainAnalysisFieldFixPlanHint,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.gapXL),

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
                    isEdit ? l.chainAnalysisSaveButtonEdit : l.chainAnalysisSaveButtonNew,
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.chainAnalysisExampleAppBarTitle),
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
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l.chainAnalysisDetailAppBarTitle,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.gapMedium,
        ),
        children: [
          const SizedBox(height: AppSpacing.gapMedium),

          // ОБЩАЯ ИНФОРМАЦИЯ
          FormSectionCard(
            title: l.chainAnalysisSectionGeneralTitle,
            children: [
              Text(
                l.chainAnalysisSectionMindfulnessLabel,
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 4),
              Text(
                l.chainAnalysisSectionWorksheetTitle,
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldDateLabel, _formatDate(entry.date)),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldProblemLabel, entry.problematicBehavior),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ЦЕПОЧКА СОБЫТИЙ
          FormSectionCard(
            title: l.chainAnalysisSectionChainTitle,
            children: [
              _detailRow(l.chainAnalysisFieldChainLinksLabel, entry.chainLinks),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldPromptingEventLabel, entry.promptingEvent),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldVulnerabilitiesLabel, entry.environment),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ПОСЛЕДСТВИЯ
          FormSectionCard(
            title: l.chainAnalysisSectionConsequencesTitle,
            children: [
              _detailRow(l.chainAnalysisFieldConsequencesOthersLabel, entry.consequencesForOthers),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldConsequencesMeLabel, entry.consequencesForMe),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldDamageLabel, entry.damage),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ПЛАН ИЗМЕНЕНИЙ
          FormSectionCard(
            title: l.chainAnalysisSectionPlanTitle,
            children: [
              _detailRow(l.chainAnalysisFieldAdaptiveBehaviourLabel, entry.adaptiveBehaviour),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldDecreaseVulnerabilityLabel, entry.decreaseVulnerability),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldPreventEventLabel, entry.preventEvent),
              const SizedBox(height: 16),
              _detailRow(l.chainAnalysisFieldFixPlanLabel, entry.fixPlan),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),
        ],
      ),
    );
  }
}

Widget _detailRow(String title, String? value) {
  final text = (value == null || value.trim().isEmpty) ? '—' : value.trim();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: AppTypography.bodySecondary.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        text,
        style: AppTypography.body,
      ),
    ],
  );
}