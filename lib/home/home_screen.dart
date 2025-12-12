import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../state/entry_form_screen.dart';
import '../state/state_repository.dart';
import '../state/state_entry.dart';
import '../state/state_entry_detail_screen.dart';
import '../utils/date_format.dart';
import '../export/state_entries_csv_exporter.dart';
import '../settings/settings_screen.dart';
import '../usage_guide/usage_guide_screen.dart';
import '../analytics/amplitude_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final StateRepository repository;

  const HomeScreen({
    super.key,
    required this.repository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasCompletedUsageGuide = false;

  @override
  void initState() {
    super.initState();
    // Читаем сохранённый флаг прохождения / скрытия usage guide из настроек
    final settingsBox = Hive.box('app_settings');
    final hasCompletedUsageGuide =
        settingsBox.get('hasCompletedUsageGuide', defaultValue: false) as bool;
    _hasCompletedUsageGuide = hasCompletedUsageGuide;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeService.instance.logHomeScreenOpened();
    });
  }

  Future<void> _onUsageGuideClosePressed() async {
    final shouldHide = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return AlertDialog(
          title: Text(l10n.homeUsageGuideHideDialogTitle),
          content: Text(l10n.homeUsageGuideHideDialogBody),
          actions: [
            // secondary
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.homeUsageGuideHideDialogHide),
            ),
            // primary
            FilledButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.homeUsageGuideHideDialogKeep),
            ),
          ],
        );
      },
    );

    if (shouldHide == true) {
      final settingsBox = Hive.box('app_settings');
      await settingsBox.put('hasCompletedUsageGuide', true);

      if (!mounted) return;
      setState(() {
        _hasCompletedUsageGuide = true;
      });

      AmplitudeService.instance.logHomeGuideCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: widget.repository.box.listenable(),
        builder: (context, box, _) {
          final entries = widget.repository.getAll();
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context)!;

          Future<void> exportCsv({
            required bool last7Days,
          }) async {
            if (entries.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.homeExportNoEntries),
                ),
              );
              return;
            }

            List<StateEntry> filtered = entries;

            if (last7Days) {
              final now = DateTime.now();
              final from = DateTime(now.year, now.month, now.day)
                  .subtract(const Duration(days: 6));

              bool isSameDay(DateTime a, DateTime b) {
                return a.year == b.year &&
                    a.month == b.month &&
                    a.day == b.day;
              }

              filtered = entries.where((e) {
                final d = e.date;
                return d.isAfter(from) || isSameDay(d, from);
              }).toList();
            }

            if (filtered.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    last7Days
                        ? l10n.homeExportNoEntries7Days
                        : l10n.homeExportNoEntries,
                  ),
                ),
              );
              return;
            }

            await exportStateEntriesAsCsvFile(
              entries: filtered,
              fileName: l10n.homeExportFileName,
              subject: last7Days
                  ? l10n.homeExportSubject7Days
                  : l10n.homeExportSubjectAll,
              text: last7Days
                  ? l10n.homeExportText7Days
                  : l10n.homeExportTextAll,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Заголовок экрана
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenTitleHorizontal,
                  vertical: AppSpacing.screenTitleVertical,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: l10n.homeSettingsTooltip,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Text(
                        l10n.homeAppBarTitle,
                        style: AppTypography.screenTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.download),
                          onSelected: (value) {
                            if (value == '7days') {
                              AmplitudeService.instance
                                  .logStatesShare(period: 'week');
                              exportCsv(last7Days: true);
                            } else if (value == 'all') {
                              AmplitudeService.instance
                                  .logStatesShare(period: 'all');
                              exportCsv(last7Days: false);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: '7days',
                              child: Text(l10n.homeExportMenu7Days),
                            ),
                            PopupMenuItem(
                              value: 'all',
                              child: Text(l10n.homeExportMenuAll),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!_hasCompletedUsageGuide)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenTitleHorizontal,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: AppSpacing.gapMedium,
                        ),
                        decoration: AppDecorations.subtleCard,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(AppSizes.cardRadius),
                          onTap: () async {
                            AmplitudeService.instance.logHomeGuideOpened();

                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => UsageGuideScreen(
                                  onCompleted: () {
                                    final settingsBox =
                                        Hive.box('app_settings');
                                    settingsBox.put(
                                        'hasCompletedUsageGuide', true);
                                    setState(() {
                                      _hasCompletedUsageGuide = true;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppSpacing.cardPaddingVertical,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.lightbulb_outline),
                                const SizedBox(
                                    width: AppSpacing.gapSmall),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.homeUsageGuideCardTitle,
                                        style: theme
                                            .textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.homeUsageGuideCardSubtitle,
                                        style: theme
                                            .textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _onUsageGuideClosePressed,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenPadding,
                          ),
                          child: Text(
                            l10n.homeEmptyStateText,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                          vertical: AppSpacing.gapMedium,
                        ),
                        children: [
                          // Карточка с графиком
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: AppDecorations.card,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal:
                                    AppSpacing.cardPaddingHorizontal,
                                vertical:
                                    AppSpacing.cardPaddingVertical,
                              ),
                              child: SizedBox(
                                height: 220,
                                child:
                                    _MoodRestActivityChart(entries: entries),
                              ),
                            ),
                          ),

                          // Заголовок списка записей
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sectionTitleTop,
                              bottom: AppSpacing.sectionTitleBottom,
                            ),
                            child: Text(
                              l10n.homeEntriesSectionTitle,
                              style: AppTypography.sectionTitle,
                            ),
                          ),

                          // Карточки записей
                          ...entries.map((entry) {
                            return GestureDetector(
                              onTap: () {
                                AmplitudeService.instance
                                    .logStateEntryDetailsViewed();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StateEntryDetailScreen(entry: entry),
                                  ),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                decoration: AppDecorations.card,
                                child: ListTile(
                                  leading: Text(
                                    entry.mood ?? '',
                                    style:
                                        const TextStyle(fontSize: 26),
                                  ),
                                  title: Text(
                                    formatDate(entry.date),
                                    style: AppTypography.cardTitle,
                                  ),
                                  subtitle: entry.grateful != null &&
                                          entry.grateful!.isNotEmpty
                                      ? Text(
                                          l10n.homeEntryGratefulPrefix(entry.grateful!),
                                          style: AppTypography
                                              .bodySecondary,
                                        )
                                      : null,
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        AmplitudeService.instance
                                            .logEditStateFormOpened();

                                        final updated =
                                            await Navigator.push<
                                                StateEntry>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EntryFormScreen(
                                              existing: entry,
                                            ),
                                          ),
                                        );
                                        if (updated != null) {
                                          AmplitudeService.instance
                                              .logStateEntryEdited();
                                          await widget.repository
                                              .update(updated);
                                        }
                                      } else if (value ==
                                          'delete') {
                                        AmplitudeService.instance
                                            .logDeleteStateEntry();
                                        await widget.repository
                                            .deleteById(entry.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(l10n.homeEntryMenuEdit),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(l10n.homeEntryMenuDelete),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MoodRestActivityChart extends StatelessWidget {
  final List<StateEntry> entries;

  const _MoodRestActivityChart({
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          l10n.homeChartNoData,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Берём последние 14 календарных дней от даты последней записи
    DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

    final latestEntryDate =
        entries.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
    final latestDay = normalize(latestEntryDate);
    final from = latestDay.subtract(const Duration(days: 13));

    // Для каждого дня в окне берём ПОСЛЕДНЮЮ запись за день
    final Map<DateTime, StateEntry> lastEntryByDay = {};
    for (final entry in entries) {
      final day = normalize(entry.date);

      // игнорируем записи вне нужного окна
      if (day.isBefore(from) || day.isAfter(latestDay)) continue;

      final existing = lastEntryByDay[day];
      if (existing == null || entry.date.isAfter(existing.date)) {
        lastEntryByDay[day] = entry;
      }
    }

    // Сортируем дни, по которым реально есть данные
    final daysWithData = lastEntryByDay.keys.toList()..sort();

    // Если вдруг в окне нет ни одного дня с данными — показываем плейсхолдер
    if (daysWithData.isEmpty) {
      return Center(
        child: Text(
          l10n.homeChartNoData14Days,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    // Формируем группы баров по дням и вычисляем maxY
    final barGroups = <BarChartGroupData>[];
    double maxY = 0;

    for (var i = 0; i < daysWithData.length; i++) {
      final day = daysWithData[i];
      final entry = lastEntryByDay[day]!;

      final double sleep = entry.sleepHours;
      final double rest = entry.rest.toDouble();
      final double activity = entry.physicalActivity.toDouble();

      if (sleep > maxY) maxY = sleep;
      if (rest > maxY) maxY = rest;
      if (activity > maxY) maxY = activity;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 0,
          barRods: [
            BarChartRodData(
              toY: sleep,
              width: 6,
              color: Colors.blue,
            ),
            BarChartRodData(
              toY: rest,
              width: 6,
              color: Colors.green,
            ),
            BarChartRodData(
              toY: activity,
              width: 6,
              color: Colors.red,
            ),
          ],
        ),
      );
    }

    // Динамический верх графика: максимум + 2, но не меньше 12
    if (maxY == 0) {
      maxY = 12;
    } else {
      maxY += 2;
      if (maxY < 12) {
        maxY = 12;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Легенда
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Colors.blue, text: l10n.homeLegendSleep),
            const SizedBox(width: 12),
            _LegendItem(color: Colors.green, text: l10n.homeLegendRest),
            const SizedBox(width: 12),
            _LegendItem(color: Colors.red, text: l10n.homeLegendActivity),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceBetween,
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        final intVal = value.round();
                        // Показываем только чётные значения от 0 до 12
                        if (intVal < 0 || intVal > 12 || intVal % 2 != 0) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '$intVal',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade800,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // убрали даты по оси X
                      reservedSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}