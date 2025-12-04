import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wisemind/theme/app_theme.dart';

import 'pros_cons.dart';

/// Список записей "За и против"
class ProsConsListScreen extends StatelessWidget {
  const ProsConsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<ProsConsEntry>(kProsConsBoxName);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'За и против',
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<ProsConsEntry> box, _) {
          if (box.isEmpty) {
            return _EmptyProsConsState(onCreate: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProsConsEditScreen(),
                ),
              );
            });
          }

          final entries = box.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date)); // новые сверху

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProsConsDetailScreen(entry: entry),
                      ),
                    );
                  },
                  title: Text(
                    _formatDate(entry.date),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    entry.problematicBehavior.isNotEmpty
                        ? entry.problematicBehavior
                        : 'Без названия',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProsConsEditScreen(entry: entry),
                          ),
                        );
                      } else if (value == 'delete') {
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
                          await entry.delete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Запись удалена')),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _onCreateProsConsPressed(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Новая запись'),
      ),
    );
  }
}

void _onCreateProsConsPressed(BuildContext context) {
  // TODO: заменить на реальную проверку подписки и экран paywall
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Полный доступ к «За и против»',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Этот рабочий лист доступен по подписке. '
              'Оформите доступ, чтобы заполнять и сохранять записи, а также отслеживать динамику.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: здесь открыть настоящий экран paywall / экран подписки
                  Navigator.of(context).pop();
                },
                child: const Text('Оформить доступ'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    },
  );
}

class _EmptyProsConsState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyProsConsState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              '🔍 Здесь пока нет ни одной записи.\nНажмите "+ Новая запись", чтобы заполнить первый рабочий лист.',
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Просмотр записи',
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _detailRow('Дата', _formatDate(entry.date)),
          _detailRow('Проблемное поведение', entry.problematicBehavior),
          _detailRow('За: поддаться импульсу', entry.prosActImpulsively),
          _detailRow(
            'За: противостоять импульсу',
            entry.prosResistImpulse,
          ),
          _detailRow(
            'Против: поддаться импульсу',
            entry.consActImpulsively,
          ),
          _detailRow(
            'Против: противостоять импульсу',
            entry.consResistImpulse,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    final text = value.trim().isEmpty ? '—' : value;
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
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
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

  @override
  void initState() {
    super.initState();
    final e = widget.entry;

    _date = e?.date ?? DateTime.now();

    _problemCtrl =
        TextEditingController(text: e?.problematicBehavior ?? '');
    _prosActImpulseCtrl =
        TextEditingController(text: e?.prosActImpulsively ?? '');
    _prosResistCtrl =
        TextEditingController(text: e?.prosResistImpulse ?? '');
    _consActImpulseCtrl =
        TextEditingController(text: e?.consActImpulsively ?? '');
    _consResistCtrl =
        TextEditingController(text: e?.consResistImpulse ?? '');
  }

  @override
  void dispose() {
    _problemCtrl.dispose();
    _prosActImpulseCtrl.dispose();
    _prosResistCtrl.dispose();
    _consActImpulseCtrl.dispose();
    _consResistCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? 'Редактирование записи' : 'Новая запись',
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Пример заполненного листа — в виде "пилюли" как на экране анализа цепочки
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProsConsExampleScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(32),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Пример заполненного листа "За и против"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Мета-текст и заголовок рабочего листа
          const Text(
            'Устойчивость к стрессу',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'За и против',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Дата
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
          const SizedBox(height: 12),
          _field(
            label: 'Проблемное поведение',
            hint: 'Какое проблемное поведение оцениваем?',
            controller: _problemCtrl,
            maxLength: 140,
          ),
          _field(
            label: 'За: поддаться импульсу',
            hint:
                'Запишите все "за" в пользу того, чтобы поддаться импульсу проблемного поведения',
            controller: _prosActImpulseCtrl,
            maxLines: 4,
          ),
          _field(
            label: 'За: противостоять импульсу',
            hint:
                'Запишите все "за" в пользу того, чтобы противостоять импульсу проблемного поведения',
            controller: _prosResistCtrl,
            maxLines: 4,
          ),
          _field(
            label: 'Против: поддаться импульсу',
            hint:
                'Запишите все "против" в пользу того, чтобы поддаться импульсу проблемного поведения',
            controller: _consActImpulseCtrl,
            maxLines: 4,
          ),
          _field(
            label: 'Против: противостоять импульсу',
            hint:
                'Запишите все "против" в пользу того, чтобы противостоять импульсу проблемного поведения',
            controller: _consResistCtrl,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
    final box = Hive.box<ProsConsEntry>(kProsConsBoxName);

    // временная заглушка для email
    const fakeEmail = 'user@example.com';

    if (widget.entry == null) {
      final entry = ProsConsEntry(
        email: fakeEmail,
        date: _date,
        problematicBehavior: _problemCtrl.text.trim(),
        prosActImpulsively: _prosActImpulseCtrl.text.trim(),
        prosResistImpulse: _prosResistCtrl.text.trim(),
        consActImpulsively: _consActImpulseCtrl.text.trim(),
        consResistImpulse: _consResistCtrl.text.trim(),
      );

      await box.add(entry);

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
        ..problematicBehavior = _problemCtrl.text.trim()
        ..prosActImpulsively = _prosActImpulseCtrl.text.trim()
        ..prosResistImpulse = _prosResistCtrl.text.trim()
        ..consActImpulsively = _consActImpulseCtrl.text.trim()
        ..consResistImpulse = _consResistCtrl.text.trim();

      await e.save();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Запись обновлена')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Пример заполнения')),
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