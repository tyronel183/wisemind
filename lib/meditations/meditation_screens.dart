import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';

import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import 'meditation.dart';
import 'meditation_repository.dart';

class MeditationsScreen extends StatelessWidget {
  const MeditationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meditations = MeditationRepository.getAll();

    // Группируем медитации по "разделам" (категориям)
    final Map<String, List<Meditation>> grouped = {};
    for (final m in meditations) {
      final rawCategory = m.category;
      final header = _mapCategoryToHeader(rawCategory);
      grouped.putIfAbsent(header, () => []).add(m);
    }

    // Задаём порядок разделов
    final sectionOrder = <String>[
      'Осознанность',
      'Устойчивость к стрессу',
      'Регуляция эмоций',
      'Межличностная эффективность',
    ];

    final listChildren = <Widget>[];

    for (final section in sectionOrder) {
      final items = grouped[section];
      if (items == null || items.isEmpty) continue;

      // Заголовок раздела
      listChildren.add(
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sectionTitleTop,
            bottom: AppSpacing.sectionTitleBottom,
          ),
          child: Text(
            section,
            style: AppTypography.sectionTitle,
          ),
        ),
      );

      // Карточки медитаций раздела
      for (final m in items) {
        listChildren.add(_MeditationCard(meditation: m));
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок экрана
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenTitleHorizontal,
                vertical: AppSpacing.screenTitleVertical,
              ),
              child: Center(
                child: Text(
                  'Медитации',
                  style: AppTypography.screenTitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.gapMedium,
                ),
                children: listChildren,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Маппинг "тегов" в желаемые заголовки разделов
  String _mapCategoryToHeader(String raw) {
    switch (raw) {
      case 'Осознанность':
        return 'Осознанность';
      case 'Снижение стресса':
        return 'Устойчивость к стрессу';
      case 'Принятие себя':
        return 'Регуляция эмоций';
      case 'Межличностная эффективность':
        return 'Межличностная эффективность';
      default:
        // на всякий случай — если появится новый тег
        return raw;
    }
  }
}

class _MeditationCard extends StatelessWidget {
  final Meditation meditation;

  const _MeditationCard({
    required this.meditation,
  });

  @override
  Widget build(BuildContext context) {
    final m = meditation;

    // Преобразуем "Эмпатическое присутствие" в короткий тег "Эмпатия"
    String skillLabel = m.dbtSkill;
    if (skillLabel == 'Эмпатическое присутствие') {
      skillLabel = 'Эмпатия';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MeditationPlayerScreen(meditation: m),
              ),
            );
          },
          child: Padding(
            // небольшие отступы слева/справа/сверху/снизу внутри карточки
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPaddingHorizontal,
              vertical: AppSpacing.cardPaddingVertical,
            ),
            child: Row(
              children: [
                // картинка слева со скруглёнными углами
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: CachedNetworkImage(
                      imageUrl: m.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: Colors.black12,
                      ),
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.self_improvement),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // текст справа
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.title,
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: AppSpacing.gapSmall),
                        Text(
                          m.situation,
                          style: AppTypography.bodySecondary,
                        ),
                        const SizedBox(height: AppSpacing.gapMedium),
                        Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _chip(context, skillLabel),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              m.duration,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.chipLabel.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class MeditationPlayerScreen extends StatefulWidget {
  final Meditation meditation;

  const MeditationPlayerScreen({super.key, required this.meditation});

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen> {
  late AudioPlayer _player;
  bool _useVoice = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(
        _useVoice
            ? widget.meditation.audioWithVoiceUrl
            : widget.meditation.audioWithoutVoiceUrl,
      );
      setState(() {
        _loadFailed = false;
      });
    } catch (e) {
      debugPrint("Ошибка загрузки аудио: $e");
      if (mounted) {
        setState(() {
          _loadFailed = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _switchAudio(bool withVoice) async {
    setState(() {
      _useVoice = withVoice;
      _loadFailed = false;
    });
    await _player.stop();
    try {
      await _player.setUrl(
        withVoice
            ? widget.meditation.audioWithVoiceUrl
            : widget.meditation.audioWithoutVoiceUrl,
      );
    } catch (e) {
      debugPrint("Ошибка переключения аудио: $e");
      if (mounted) {
        setState(() {
          _loadFailed = true;
        });
      }
    }
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$mm:$ss";
  }

  @override
  Widget build(BuildContext context) {
    final meditation = widget.meditation;

    return Scaffold(
      appBar: AppBar(title: Text(meditation.title)),
      body: DefaultTabController(
        length: 2,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.gapMedium,
          ),
          children: [
            Text(
              meditation.situation,
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: 6),
            Text(
              meditation.description,
              style: AppTypography.body,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.psychology, size: 16),
                  label: Text(meditation.dbtSkill),
                ),
                Chip(
                  avatar: const Icon(Icons.timer, size: 16),
                  label: Text(meditation.duration),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_loadFailed) ...[
              const SizedBox(height: 24),
              Text(
                'Не удалось загрузить аудио медитации.\nПроверьте подключение к интернету и попробуйте ещё раз.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary,
              ),
            ] else ...[
              TabBar(
                onTap: (index) {
                  _switchAudio(index == 0);
                },
                tabs: const [
                  Tab(text: 'С голосом'),
                  Tab(text: 'Только музыка'),
                ],
              ),
              const SizedBox(height: 24),
              // прогресс
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final pos = snapshot.data ?? Duration.zero;
                  final total = _player.duration ?? Duration.zero;

                  return Column(
                    children: [
                      Slider(
                        min: 0,
                        max: total.inMilliseconds.toDouble(),
                        value: pos.inMilliseconds
                            .clamp(0, total.inMilliseconds)
                            .toDouble(),
                        onChanged: (v) =>
                            _player.seek(Duration(milliseconds: v.toInt())),
                      ),
                      Text("${_fmt(pos)} / ${_fmt(total)}"),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // play / pause
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return Center(
                    child: FilledButton.icon(
                      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                      label: Text(playing ? "Пауза" : "Играть"),
                      onPressed: () =>
                          playing ? _player.pause() : _player.play(),
                    ),
                  );
                },
              ),
            ],

            if (!meditation.isFree) ...[
              const SizedBox(height: 20),
              Text(
                "Для доступа к этой медитации может потребоваться подписка.",
                style: AppTypography.bodySecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}