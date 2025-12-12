import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wisemind/theme/app_theme.dart';
import 'package:wisemind/billing/billing_service.dart';

import '../l10n/app_localizations.dart';

import '../theme/app_components.dart';
import '../theme/app_spacing.dart';

import '../analytics/amplitude_service.dart';
import 'pros_cons.dart';

const String kProsConsWorksheetName = 'За и против';

/// Список записей "За и против"
class ProsConsListScreen extends StatefulWidget {
  const ProsConsListScreen({super.key});

  @override
  State<ProsConsListScreen> createState() => _ProsConsListScreenState();
}

class _ProsConsListScreenState extends State<ProsConsListScreen> {
  @override
  void initState() {
    super.initState();
    // Открыт список рабочего листа "За и против"
    AmplitudeService.instance.logEvent(
      'worksheet_history',
      properties: {'worksheet': kProsConsWorksheetName},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final box = Hive.box<ProsConsEntry>(kProsConsBoxName);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l.prosConsListAppBarTitle,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<ProsConsEntry> box, _) {
          if (box.isEmpty) {
            return _EmptyProsConsState(
              onCreate: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProsConsEditScreen(),
                  ),
                );
              },
              message: l.prosConsEmptyList,
            );
          }

          final entries = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date)); // новые сверху

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.gapMedium,
            ),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];

              return Container(
                decoration: AppDecorations.card,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.cardPaddingHorizontal,
                    vertical: AppSpacing.cardPaddingVertical,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Основная кликабельная область карточки
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProsConsDetailScreen(entry: entry),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(entry.date),
                                style: AppTypography.cardTitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.problematicBehavior.isNotEmpty
                                    ? entry.problematicBehavior
                                    : 'Без названия',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySecondary,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.gapSmall),

                      // Меню действий
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Открытие формы редактирования рабочего листа "За и против"
                            AmplitudeService.instance.logEvent(
                              'edit_worksheet_form',
                              properties: {
                                'worksheet': kProsConsWorksheetName,
                              },
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProsConsEditScreen(entry: entry),
                              ),
                            );
                          } else if (value == 'delete') {
                            // Инициирована попытка удалить запись "За и против"
                            AmplitudeService.instance.logEvent(
                              'delete_worksheet',
                              properties: {
                                'worksheet': kProsConsWorksheetName,
                              },
                            );

                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l.prosConsDeleteDialogTitle),
                                content: Text(
                                  l.prosConsDeleteDialogBody,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(l.prosConsDeleteDialogCancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text(
                                      l.prosConsDeleteDialogConfirm,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              // Пользователь подтвердил удаление записи "За и против"
                              AmplitudeService.instance.logEvent(
                                'delete_worksheet_confirmed',
                                properties: {
                                  'worksheet': kProsConsWorksheetName,
                                },
                              );

                              await entry.delete();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l.prosConsDeleteSnack),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l.prosConsMenuEdit),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              l.prosConsMenuDelete,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _onCreateProsConsPressed(context);
        },
        icon: const Icon(Icons.add),
        label: Text(l.prosConsFabNewEntry),
      ),
    );
  }
}

Future<void> _onCreateProsConsPressed(BuildContext context) async {
  // Проверяем доступ через общий биллинговый слой.
  final allowed = await BillingService.ensureProOrShowPaywall(context);
  if (!context.mounted || !allowed) return;

  // Открытие формы нового рабочего листа "За и против"
  AmplitudeService.instance.logEvent(
    'new_worksheet_form',
    properties: {'worksheet': kProsConsWorksheetName},
  );

  // Если доступ есть — открываем экран создания новой записи.
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const ProsConsEditScreen(),
    ),
  );
}

class _EmptyProsConsState extends StatelessWidget {
  final VoidCallback onCreate;
  final String message;

  const _EmptyProsConsState({
    required this.onCreate,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран просмотра одной записи "За и против"
class ProsConsDetailScreen extends StatelessWidget {
  final ProsConsEntry entry;

  const ProsConsDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l.prosConsDetailAppBarTitle,
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
          FormSectionCard(
            title: l.prosConsDetailSectionWorksheetTitle,
            children: [
              Text(
                l.prosConsSectionDistressToleranceLabel,
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 4),
              Text(
                l.prosConsSectionWorksheetTitle,
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 16),
              _detailRow(l.prosConsFieldDateLabel, _formatDate(entry.date)),
              const SizedBox(height: 16),
              _detailRow(l.prosConsFieldProblemLabel, entry.problematicBehavior),
              const SizedBox(height: 16),
              _detailRow(l.prosConsFieldProsActImpulsivelyLabel, entry.prosActImpulsively),
              const SizedBox(height: 12),
              _detailRow(l.prosConsFieldProsResistImpulseLabel, entry.prosResistImpulse),
              const SizedBox(height: 12),
              _detailRow(l.prosConsFieldConsActImpulsivelyLabel, entry.consActImpulsively),
              const SizedBox(height: 12),
              _detailRow(l.prosConsFieldConsResistImpulseLabel, entry.consResistImpulse),
            ],
          ),
          if (entry.decision != null && entry.decision!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.gapLarge),
            FormSectionCard(
              title: l.prosConsDecisionSectionTitle,
              children: [
                Text(
                  entry.decision!.trim(),
                  style: AppTypography.body,
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.gapLarge),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    final text = value.trim().isEmpty ? '—' : value;
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
}

/// Экран создания / редактирования записи "За и против"
class ProsConsEditScreen extends StatefulWidget {
  final ProsConsEntry? entry;

  const ProsConsEditScreen({super.key, this.entry});

  bool get isEditing => entry != null;

  @override
  State<ProsConsEditScreen> createState() => _ProsConsEditScreenState();
}

class _ProsConsEditScreenState extends State<ProsConsEditScreen> {
  late DateTime _date;

  late TextEditingController _problemCtrl;
  late TextEditingController _prosActImpulseCtrl;
  late TextEditingController _prosResistCtrl;
  late TextEditingController _consActImpulseCtrl;
  late TextEditingController _consResistCtrl;
  late TextEditingController _decisionCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;

    _date = e?.date ?? DateTime.now();

    _problemCtrl = TextEditingController(text: e?.problematicBehavior ?? '');
    _prosActImpulseCtrl =
        TextEditingController(text: e?.prosActImpulsively ?? '');
    _prosResistCtrl = TextEditingController(text: e?.prosResistImpulse ?? '');
    _consActImpulseCtrl =
        TextEditingController(text: e?.consActImpulsively ?? '');
    _consResistCtrl =
        TextEditingController(text: e?.consResistImpulse ?? '');
    _decisionCtrl = TextEditingController(text: e?.decision ?? '');
  }

  @override
  void dispose() {
    _problemCtrl.dispose();
    _prosActImpulseCtrl.dispose();
    _prosResistCtrl.dispose();
    _consActImpulseCtrl.dispose();
    _consResistCtrl.dispose();
    _decisionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? l.prosConsEditAppBarTitle : l.prosConsNewAppBarTitle,
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

          // Пример заполненного листа — во вторичной карточке
          Container(
            decoration: AppDecorations.subtleCard,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProsConsExampleScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.prosConsExamplePillTitle,
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // Основной блок рабочего листа
          FormSectionCard(
            title: l.prosConsEditSectionWorksheetTitle,
            children: [
              Text(
                l.prosConsSectionDistressToleranceLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.prosConsSectionWorksheetTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l.prosConsFieldDateLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
              const SizedBox(height: 16),
              AppTextField(
                controller: _problemCtrl,
                label: l.prosConsFieldProblemLabel,
                hint: l.prosConsFieldProblemHint,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _prosActImpulseCtrl,
                label: l.prosConsFieldProsActImpulsivelyLabel,
                hint: l.prosConsFieldProsActImpulsivelyHint,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _prosResistCtrl,
                label: l.prosConsFieldProsResistImpulseLabel,
                hint: l.prosConsFieldProsResistImpulseHint,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _consActImpulseCtrl,
                label: l.prosConsFieldConsActImpulsivelyLabel,
                hint: l.prosConsFieldConsActImpulsivelyHint,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _consResistCtrl,
                label: l.prosConsFieldConsResistImpulseLabel,
                hint: l.prosConsFieldConsResistImpulseHint,
                maxLines: 4,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          FormSectionCard(
            title: l.prosConsDecisionSectionTitle,
            children: [
              AppTextField(
                controller: _decisionCtrl,
                label: l.prosConsDecisionFieldLabel,
                hint: l.prosConsDecisionFieldHint,
                maxLines: 3,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

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
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white.withValues(alpha: 0.15);
                    }
                    return null;
                  },
                ),
                animationDuration: const Duration(milliseconds: 120),
              ),
              onPressed: _save,
              child: Text(
                isEditing ? l.prosConsSaveButtonEdit : l.prosConsSaveButtonNew,
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

  Future<void> _save() async {
    final box = Hive.box<ProsConsEntry>(kProsConsBoxName);
    final l = AppLocalizations.of(context)!;

    // временная заглушка для email
    const fakeEmail = 'user@example.com';

    final decisionText = _decisionCtrl.text.trim();
    final decisionValue = decisionText.isEmpty ? null : decisionText;

    if (widget.entry == null) {
      final entry = ProsConsEntry(
        email: fakeEmail,
        date: _date,
        problematicBehavior: _problemCtrl.text.trim(),
        prosActImpulsively: _prosActImpulseCtrl.text.trim(),
        prosResistImpulse: _prosResistCtrl.text.trim(),
        consActImpulsively: _consActImpulseCtrl.text.trim(),
        consResistImpulse: _consResistCtrl.text.trim(),
        decision: decisionValue,
      );

      await box.add(entry);

      // Новая запись рабочего листа "За и против" создана
      AmplitudeService.instance.logEvent(
        'worksheet_created',
        properties: {'worksheet': kProsConsWorksheetName},
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.prosConsSaveSnackNew)),
        );
      }
    } else {
      final e = widget.entry!;
      e
        ..date = _date
        ..problematicBehavior = _problemCtrl.text.trim()
        ..prosActImpulsively = _prosActImpulseCtrl.text.trim()
        ..prosResistImpulse = _prosResistCtrl.text.trim()
        ..consActImpulsively = _consActImpulseCtrl.text.trim()
        ..consResistImpulse = _consResistCtrl.text.trim()
        ..decision = decisionValue;

      await e.save();

      // Существующая запись рабочего листа "За и против" отредактирована
      AmplitudeService.instance.logEvent(
        'worksheet_edited',
        properties: {'worksheet': kProsConsWorksheetName},
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.prosConsSaveSnackEdit)),
        );
      }
    }
  }
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year.toString();
  return '$d.$m.$y';
}

class ProsConsExampleScreen extends StatelessWidget {
  const ProsConsExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l.prosConsExampleAppBarTitle,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(
          data: '''
<h2>Пример заполнения «За и против»</h2>
<p>Этот пример показывает, как выглядит честный разбор импульса.<br>
Важно не искать «правильные» ответы — важно видеть полную картину.</p>

<hr style="margin:12px 0;" />

<h3>1. Дата</h3>
<p>12.02.2025</p>

<hr style="margin:12px 0;" />

<h3>2. Проблемное поведение</h3>
<p>Сорвался на коллегу.</p>

<hr style="margin:12px 0;" />

<h3>3. За: поддаться импульсу</h3>
<ul>
  <li>Быстро “выпускаю” эмоцию.</li>
  <li>Чувствую краткое облегчение.</li>
  <li>Кажется, что «защищаю границы».</li>
</ul>

<hr style="margin:12px 0;" />

<h3>4. За: противостоять импульсу</h3>
<ul>
  <li>Сохраняю контакт и уважение к себе.</li>
  <li>Могу объяснить, что меня задело, не разрушая отношения.</li>
  <li>Долгосрочно становлюсь устойчивее к триггерам.</li>
  <li>Чувствую себя спокойнее и сильнее после выдерживания.</li>
</ul>

<hr style="margin:12px 0;" />

<h3>5. Против: поддаться импульсу</h3>
<ul>
  <li>Порчу отношения, которые мне важны.</li>
  <li>Появляются вина, стыд, сожаление.</li>
  <li>Люди начинают держаться на расстоянии.</li>
  <li>Проблема не решается — только нарастает.</li>
</ul>

<hr style="margin:12px 0;" />

<h3>6. Против: противостоять импульсу</h3>
<ul>
  <li>Требуется усилие и концентрация.</li>
  <li>Иногда не хватает ресурса на паузу.</li>
  <li>Привычная реакция “взрываться” кажется легче и быстрее.</li>
  <li>Сперва может чувствоваться дискомфорт от “нового” поведения.</li>
</ul>

<hr style="margin:12px 0;" />

<h3>Итог</h3>
<p>Когда пункты честно записаны, становится видно:<br><br>
<strong>краткосрочно импульс облегчает, но долгосрочно разрушает;</strong><br>
<strong>устойчивое действие труднее, но приносит лучшие результаты.</strong>
</p>
          ''',
          style: {
            "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
          },
        ),
      ),
    );
  }
}