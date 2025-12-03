import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state/state_entry.dart';
import '../utils/date_format.dart';

/// Генерация CSV по списку записей состояния.
///
/// Колонки (в порядке):
/// - Дата
/// - Использованные навыки
/// - Как прошёл день
/// - Отдых
/// - Сколько часов спали
/// - Ночные пробуждения
/// - Время пробуждения
/// - Физический дискомфорт
/// - Эмоциональный дискомфорт
/// - Ощущение нереальности
/// - Руминации
/// - Самообвинение
/// - Суицидальные мысли
/// - Физическая активность
/// - Деятельность для удовольствия
/// - Сколько раз ели
/// - Сколько пили жидкости
String generateStateEntriesCsv(List<StateEntry> entries) {
  final buffer = StringBuffer();

  // Заголовок CSV
  buffer.writeln([
    'Дата',
    'Использованные навыки',
    'Как прошёл день',
    'Отдых',
    'Сколько часов спали',
    'Ночные пробуждения',
    'Время пробуждения',
    'Физический дискомфорт',
    'Эмоциональный дискомфорт',
    'Ощущение нереальности',
    'Руминации',
    'Самообвинение',
    'Суицидальные мысли',
    'Физическая активность',
    'Деятельность для удовольствия',
    'Сколько раз ели',
    'Сколько пили жидкости',
  ].map(_csvEscape).join(','));

  for (final e in entries) {
    final skills = e.skillsUsed.isEmpty
        ? ''
        : e.skillsUsed.join('; ');

    final row = [
      // Дата
      _csvEscape(formatDate(e.date)),
      // Использованные навыки (через ; )
      _csvEscape(skills),
      // Как прошёл день (эмодзи / описание)
      _csvEscape(e.mood ?? ''),
      // Отдых (0–5)
      _csvEscape(e.rest.toString()),
      // Сколько часов спали (double)
      _csvEscape(e.sleepHours.toString()),
      // Ночные пробуждения
      _csvEscape(e.nightWakeUps.toString()),
      // Время пробуждения (строка, уже в формате "HH:MM")
      _csvEscape(e.wakeUpTime),
      // Физический дискомфорт
      _csvEscape(e.physicalDiscomfort.toString()),
      // Эмоциональный дискомфорт
      _csvEscape(e.emotionalDistress.toString()),
      // Ощущение нереальности (dissociation)
      _csvEscape(e.dissociation.toString()),
      // Руминации
      _csvEscape(e.ruminations.toString()),
      // Самообвинение
      _csvEscape(e.selfBlame.toString()),
      // Суицидальные мысли
      _csvEscape(e.suicidalThoughts.toString()),
      // Физическая активность
      _csvEscape(e.physicalActivity.toString()),
      // Деятельность для удовольствия
      _csvEscape(e.pleasure.toString()),
      // Сколько раз ели
      _csvEscape(e.food.toString()),
      // Сколько пили жидкости (строка: литры или "Больше 4 л")
      _csvEscape(e.water),
    ];

    buffer.writeln(row.join(','));
  }

  return buffer.toString();
}

/// Экранирование значений для CSV:
/// - если нет запятых/кавычек/переносов — оставляем как есть
/// - иначе экранируем кавычки и оборачиваем в двойные кавычки
String _csvEscape(String value) {
  if (!value.contains(',') &&
      !value.contains('"') &&
      !value.contains('\n')) {
    return value;
  }

  final escaped = value.replaceAll('"', '""');
  return '"$escaped"';
}

Future<void> exportStateEntriesAsCsvFile({
  required List<StateEntry> entries,
  required String fileName,
  String? subject,
  String? text,
}) async {
  try {
    final csv = generateStateEntriesCsv(entries);
    final tempDir = await getTemporaryDirectory();

    String normalizedFileName = fileName.trim();
    if (normalizedFileName.isEmpty) {
      normalizedFileName = 'Записи состояний.csv';
    } else if (!normalizedFileName.toLowerCase().endsWith('.csv')) {
      normalizedFileName = '$normalizedFileName.csv';
    }

    final file = File('${tempDir.path}/$normalizedFileName');
    await file.writeAsString(csv, encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: 'text/csv',
            name: normalizedFileName,
          ),
        ],
        subject: subject,
      ),
    );
  } catch (e) {
    rethrow;
  }
}