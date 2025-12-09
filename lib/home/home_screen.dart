import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../state/entry_form_screen.dart';
import '../state/state_repository.dart';
import '../state/state_entry.dart';
import '../state/state_entry_detail_screen.dart';
import '../utils/date_format.dart';
import '../export/state_entries_csv_exporter.dart';
import '../settings/settings_screen.dart';
import '../usage_guide/usage_guide_screen.dart';
import '../analytics/amplitude_service.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeService.instance.logHomeScreenOpened();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          AmplitudeService.instance.logNewStateFormOpened();

          final entry = await Navigator.push<StateEntry>(
            context,
            MaterialPageRoute(
              builder: (_) => const EntryFormScreen(),
            ),
          );

          if (entry != null) {
            AmplitudeService.instance.logStateEntryCreated();
            await widget.repository.save(entry);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Новая запись'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: widget.repository.box.listenable(),
          builder: (context, box, _) {
            final entries = widget.repository.getAll();
            final theme = Theme.of(context);

            Future<void> exportCsv({
              required bool last7Days,
            }) async {
              if (entries.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Нет записей для экспорта.'),
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
                          ? 'За последние 7 дней нет записей для экспорта.'
                          : 'Нет записей для экспорта.',
                    ),
                  ),
                );
                return;
              }

              await exportStateEntriesAsCsvFile(
                entries: filtered,
                fileName: 'Записи состояний',
                subject: last7Days
                    ? 'Записи состояний за последние 7 дней'
                    : 'Все записи состояний',
                text: last7Days
                    ? 'Записи состояний за последние 7 дней (CSV).'
                    : 'Все записи состояний (CSV).',
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
                        tooltip: 'Настройки',
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
                          'Моё состояние',
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
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: '7days',
                                child: Text('Экспорт за последние 7 дней'),
                              ),
                              PopupMenuItem(
                                value: 'all',
                                child: Text('Экспорт всех записей'),
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
                    child: Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.gapMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          AmplitudeService.instance.logHomeGuideOpened();

                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UsageGuideScreen(
                                onCompleted: () {
                                  setState(() {
                                    _hasCompletedUsageGuide = true;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.all(AppSpacing.cardPaddingVertical),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.lightbulb_outline),
                              const SizedBox(width: AppSpacing.gapSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Как пользоваться приложением',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Краткий гид на 2–3 минуты, чтобы выжать максимум пользы из Wisemind.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
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
                  ),
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenPadding,
                            ),
                            child: Text(
                              '🔍 Здесь пока нет ваших записей.\n'
                              'Нажмите «+ Новая запись», чтобы добавить первую.',
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
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.cardPaddingHorizontal,
                                  vertical: AppSpacing.cardPaddingVertical,
                                ),
                                child: SizedBox(
                                  height: 220,
                                  child: _MoodRestActivityChart(entries: entries),
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
                                'Записи состояний',
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
                                      builder: (_) => StateEntryDetailScreen(entry: entry),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: Text(
                                      entry.mood ?? '',
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                    title: Text(formatDate(entry.date)),
                                    subtitle: entry.grateful != null &&
                                            entry.grateful!.isNotEmpty
                                        ? Text('Благодарю себя: ${entry.grateful}')
                                        : null,
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          AmplitudeService.instance
                                              .logEditStateFormOpened();

                                          final updated =
                                              await Navigator.push<StateEntry>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EntryFormScreen(
                                                existing: entry,
                                              ),
                                            ),
                                          );
                                          if (updated != null) {
                                            AmplitudeService.instance
                                                .logStateEntryEdited();
                                            await widget.repository.update(updated);
                                          }
                                        } else if (value == 'delete') {
                                          AmplitudeService.instance
                                              .logDeleteStateEntry();
                                          await widget.repository.deleteById(entry.id);
                                          AmplitudeService.instance
                                              .logDeleteStateEntryConfirmed();
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Редактировать'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Удалить'),
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
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'Пока нет данных для графика.\nДобавь записи за последние дни.',
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
          'Пока нет данных за последние 14 дней.',
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Colors.blue, text: 'Часы сна'),
            SizedBox(width: 12),
            _LegendItem(color: Colors.green, text: 'Отдых'),
            SizedBox(width: 12),
            _LegendItem(color: Colors.red, text: 'Активность'),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceBetween, // расстояние между днями
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