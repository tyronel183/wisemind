import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'state_entry.dart';
import 'state_repository.dart';
import '../utils/date_format.dart';
import 'state_entry_detail_screen.dart';

class StateDashboardScreen extends StatelessWidget {
  final StateRepository repository;

  const StateDashboardScreen({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: repository.box.listenable(),
      builder: (context, box, _) {
        final entries = repository.getAll();

        if (entries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Здесь будет ваша статистика состояния.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Пока нет ни одной записи. Нажмите кнопку внизу, чтобы заполнить анкету за сегодня.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final recentForChart = entries.take(7).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Моё состояние',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildChartCard(context, recentForChart),
              const SizedBox(height: 12),
              _buildHistoryCard(context, entries),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartCard(BuildContext context, List<StateEntry> entries) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final barGroups = <BarChartGroupData>[];
    double maxY = 0;

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final sleep = e.sleepHours;
      final rest = e.rest.toDouble();
      final activity = e.physicalActivity.toDouble();

      final localMax = [
        sleep,
        rest,
        activity,
      ].reduce((a, b) => a > b ? a : b);

      if (localMax > maxY) {
        maxY = localMax;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: sleep,
              width: 6,
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.primary,
            ),
            BarChartRodData(
              toY: rest,
              width: 6,
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.secondary,
            ),
            BarChartRodData(
              toY: activity,
              width: 6,
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      );
    }

    maxY = maxY + 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сон, отдых и активность за последние дни',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barGroups: barGroups,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 2,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= entries.length) {
                            return const SizedBox.shrink();
                          }
                          final d = entries[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendItem(
                  context,
                  color: Theme.of(context).colorScheme.primary,
                  label: 'Сон (часы)',
                ),
                const SizedBox(width: 12),
                _buildLegendItem(
                  context,
                  color: Theme.of(context).colorScheme.secondary,
                  label: 'Отдых (0–5)',
                ),
                const SizedBox(width: 12),
                _buildLegendItem(
                  context,
                  color: Theme.of(context).colorScheme.tertiary,
                  label: 'Активность (0–5)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, List<StateEntry> entries) {
    final recent = entries.take(30).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              title: Text(
                'История записей',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text('Последние дни'),
            ),
            const Divider(height: 1),
            ...recent.map((e) {
              final mood = e.mood ?? '🙂';
              final sleepText =
                  '${e.sleepHours.toStringAsFixed(e.sleepHours == e.sleepHours.roundToDouble() ? 0 : 1)} ч';
              final restText = '${e.rest}/5 отдых';
              final activityText = '${e.physicalActivity}/5 активность';

              return Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: Text(
                      mood,
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(formatDate(e.date)),
                    subtitle: Text('$sleepText · $restText · $activityText'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StateEntryDetailScreen(entry: e),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}