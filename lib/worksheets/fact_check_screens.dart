// ======================================================
// lib/worksheets/fact_check_screens.dart
// Список, просмотр, редактирование, пример
// ======================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wisemind/theme/app_theme.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';
import 'package:wisemind/billing/billing_service.dart';
import '../analytics/amplitude_service.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.factCheckListAppBarTitle,
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
            final errorText = snapshot.error?.toString() ?? '';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  errorText.isEmpty
                      ? l10n.factCheckLoadErrorGeneric
                      : l10n.factCheckLoadErrorWithReason(errorText),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                l10n.factCheckLoadErrorGeneric,
                textAlign: TextAlign.center,
              ),
            );
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
                      ? l10n.factCheckEmotionNone
                      : entry.emotions.join(', ');

                  return Container(
                    decoration: AppDecorations.card,
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.cardPaddingHorizontal,
                          vertical: 0,
                        ),
                        title: Text(
                          _formatDate(entry.date),
                          style: AppTypography.cardTitle,
                        ),
                        subtitle: Text(
                          emotionsText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySecondary,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FactCheckDetailScreen(entry: entry),
                            ),
                          );
                        },
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              AmplitudeService.instance.logEvent(
                                'edit_worksheet_form',
                                properties: {
                                  'worksheet': kFactCheckWorksheetName,
                                },
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FactCheckEditScreen(entry: entry),
                                ),
                              );
                            } else if (value == 'delete') {
                              AmplitudeService.instance.logEvent(
                                'delete_worksheet',
                                properties: {
                                  'worksheet': kFactCheckWorksheetName,
                                },
                              );

                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    l10n.factCheckDeleteDialogTitle,
                                  ),
                                  content: Text(
                                    l10n.factCheckDeleteDialogBody,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(
                                        l10n.factCheckDeleteDialogCancel,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text(
                                        l10n.factCheckDeleteDialogConfirm,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                AmplitudeService.instance.logEvent(
                                  'delete_worksheet_confirmed',
                                  properties: {
                                    'worksheet': kFactCheckWorksheetName,
                                  },
                                );
                                await entry.delete();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    AppSnackbars.success(l10n.factCheckDeleteSnack),
                                  );
                                }
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(l10n.factCheckMenuEdit),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                l10n.factCheckMenuDelete,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
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
        label: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.factCheckFabNewEntry);
          },
        ),
      ),
    );
  }
}

Future<void> _onCreateNewPressed(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  // Проверяем доступ через общий биллинговый слой.
  final allowed = await BillingService.ensureProOrShowPaywall(
    context,
    screen: l10n.mainNavWorksheets,
    source: 'fact_check_fab',
  );
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
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.factCheckEmptyList,
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
    final l10n = AppLocalizations.of(context)!;
    final emotionsText =
        entry.emotions.isEmpty ? '—' : entry.emotions.join(', ');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.factCheckDetailAppBarTitle,
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
            title: l10n.factCheckSectionGeneralTitle,
            children: [
              _detailRow(
                l10n.factCheckFieldDateLabel,
                _formatDate(entry.date),
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldEmotionLabel,
                emotionsText,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldInitialIntensityLabel,
                entry.initialIntensity.toString(),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ПРОВЕРКА ФАКТОВ
          FormSectionCard(
            title: l10n.factCheckSectionWorksheetTitle,
            children: [
              _detailRow(
                l10n.factCheckFieldPromptingEventLabel,
                entry.promptingEvent,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldFactsExtremesLabel,
                entry.factsExtremes,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldMyInterpretationLabel,
                entry.myInterpretation,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldAltInterpretationsLabel,
                entry.alternativeInterpretations,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldPerceivedThreatLabel,
                entry.perceivedThreat,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldAltOutcomesLabel,
                entry.alternativeOutcomes,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldCatastropheLabel,
                entry.catastropheThoughts,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldCopingLabel,
                entry.copingPlan,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ПОСЛЕ ПРОВЕРКИ ФАКТОВ
          FormSectionCard(
            title: l10n.factCheckSectionAfterTitle,
            children: [
              _detailRow(
                l10n.factCheckFieldEmotionMatchLabel,
                entry.emotionMatchScore.toString(),
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              _detailRow(
                l10n.factCheckFieldCurrentIntensityLabel,
                entry.currentIntensity.toString(),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapXL),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    String text = value;
    if (text.trim().isEmpty) text = '—';
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
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.isEditing;

    final emotionOptions = <String>[
      l10n.factCheckEmotionAnger,
      l10n.factCheckEmotionFear,
      l10n.factCheckEmotionAnxiety,
      l10n.factCheckEmotionSadness,
      l10n.factCheckEmotionGuilt,
      l10n.factCheckEmotionShame,
      l10n.factCheckEmotionDisgust,
      l10n.factCheckEmotionDesire,
      l10n.factCheckEmotionJoy,
      l10n.factCheckEmotionHurt,
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? l10n.factCheckSaveButtonEdit : l10n.factCheckSaveButtonNew,
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

          // Пилюля с примером заполнения рабочего листа
          Container(
            decoration: AppDecorations.subtleCard,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FactCheckExampleScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const SizedBox(width: AppSpacing.gapMedium),
                    Expanded(
                      child: Text(
                        l10n.factCheckExamplePillTitle,
                        style: AppTypography.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ОБЩАЯ ИНФОРМАЦИЯ
          FormSectionCard(
            title: l10n.factCheckSectionGeneralTitle,
            children: [
              Text(
                l10n.factCheckSectionEmotionRegulationLabel,
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.factCheckSectionWorksheetTitle,
                style: AppTypography.sectionTitle,
              ),
              const SizedBox(height: AppSpacing.gapLarge),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.factCheckFieldDateLabel,
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
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ЭМОЦИЯ И ИНТЕНСИВНОСТЬ
          FormSectionCard(
            title: l10n.factCheckSectionEmotionIntensityTitle,
            children: [
              Text(
                l10n.factCheckFieldEmotionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: emotionOptions.map((emotion) {
                  final selected = _selectedEmotions.contains(emotion);
                  return AppPillChoice(
                    label: emotion,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedEmotions.remove(emotion);
                        } else {
                          _selectedEmotions.add(emotion);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _initialIntensityCtrl,
                label: l10n.factCheckFieldInitialIntensityLabel,
                hint: l10n.factCheckFieldInitialIntensityHint,
                keyboardType: TextInputType.number,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapLarge),

          // ПРОВЕРКА ФАКТОВ
          FormSectionCard(
            title: l10n.factCheckSectionWorksheetTitle,
            children: [
              AppTextField(
                controller: _promptingEventCtrl,
                label: l10n.factCheckFieldPromptingEventLabel,
                hint: l10n.factCheckFieldPromptingEventHint,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _factsExtremesCtrl,
                label: l10n.factCheckFieldFactsExtremesLabel,
                hint: l10n.factCheckFieldFactsExtremesHint,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _myInterpretationCtrl,
                label: l10n.factCheckFieldMyInterpretationLabel,
                hint: l10n.factCheckFieldMyInterpretationHint,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _altInterpretationsCtrl,
                label: l10n.factCheckFieldAltInterpretationsLabel,
                hint: l10n.factCheckFieldAltInterpretationsHint,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _perceivedThreatCtrl,
                label: l10n.factCheckFieldPerceivedThreatLabel,
                hint: l10n.factCheckFieldPerceivedThreatHint,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _altOutcomesCtrl,
                label: l10n.factCheckFieldAltOutcomesLabel,
                hint: l10n.factCheckFieldAltOutcomesHint,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _catastropheCtrl,
                label: l10n.factCheckFieldCatastropheLabel,
                hint: l10n.factCheckFieldCatastropheHint,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _copingCtrl,
                label: l10n.factCheckFieldCopingLabel,
                hint: l10n.factCheckFieldCopingHint,
                maxLines: 3,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.gapXL),

          FormSectionCard(
            title: l10n.factCheckSectionAfterTitle,
            children: [
              Text(
                l10n.factCheckFieldEmotionMatchLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(6, (index) {
                  final selected = _emotionMatchScore == index;
                  return AppPillChoice(
                    label: index.toString(),
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _emotionMatchScore = index;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _currentIntensityCtrl,
                label: l10n.factCheckFieldCurrentIntensityLabel,
                hint: l10n.factCheckFieldCurrentIntensityHint,
                keyboardType: TextInputType.number,
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
                isEditing
                    ? l10n.factCheckSaveButtonEdit
                    : l10n.factCheckSaveButtonNew,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.gapXL),
        ],
      ),
    );
  }


  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
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
          AppSnackbars.success(l10n.factCheckSaveSnackNew),
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
          AppSnackbars.success(l10n.factCheckSaveSnackEdit),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.factCheckExampleAppBarTitle,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
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