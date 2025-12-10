import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wisemind/billing/billing_service.dart';

import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../theme/app_card_tile.dart';
import '../theme/app_components.dart';
import '../analytics/amplitude_service.dart';
import 'meditation.dart';
import 'meditation_repository.dart';

class MeditationsScreen extends StatefulWidget {
  const MeditationsScreen({super.key});

  @override
  State<MeditationsScreen> createState() => _MeditationsScreenState();
}

class _MeditationsScreenState extends State<MeditationsScreen> {
  @override
  void initState() {
    super.initState();
    // Экран со списком медитаций открыт
    AmplitudeService.instance.logEvent('meditations_screen');
  }

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

    // Если по каким‑то причинам ни один раздел не собрался (например,
    // изменились категории в данных), показываем все медитации подряд,
    // чтобы экран не был пустым.
    if (listChildren.isEmpty) {
      for (final m in meditations) {
        listChildren.add(_MeditationCard(meditation: m));
      }
    }

    return SafeArea(
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

    final tags = <String>[skillLabel];
    if (m.duration.isNotEmpty) {
      tags.add(m.duration);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: AppImageCardTile(
        title: m.title,
        subtitle: m.situation,
        tags: tags,
        image: CachedNetworkImage(
          imageUrl: m.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(color: Colors.black12),
          errorWidget: (_, _, _) =>
              const Icon(Icons.self_improvement),
        ),
        onTap: () async {
          // Бесплатные медитации (например, раздел "Осознанность") доступны сразу.
          if (m.isFree) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MeditationPlayerScreen(meditation: m),
              ),
            );
            return;
          }

          // Для остальных медитаций проверяем доступ через общий биллинговый слой.
          final allowed =
              await BillingService.ensureProOrShowPaywall(context);
          if (!context.mounted || !allowed) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MeditationPlayerScreen(meditation: m),
            ),
          );
        },
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    AmplitudeService.instance.logEvent(
      'meditation_viewed',
      properties: {'meditation': widget.meditation.title},
    );

    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      await _player.setUrl(
        _useVoice
            ? widget.meditation.audioWithVoiceUrl
            : widget.meditation.audioWithoutVoiceUrl,
      );
      if (!mounted) return;
      setState(() {
        _loadFailed = false;
      });
    } catch (e) {
      debugPrint("Ошибка загрузки аудио: $e");
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
    if (_isLoading) return; // игнорируем быстрые повторные тапы, пока идёт загрузка

    setState(() {
      _useVoice = withVoice;
      _loadFailed = false;
      _isLoading = true;
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
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.gapMedium,
        ),
        children: [
          // Заголовок + обложка медитации
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Обложка
              SizedBox(
                width: 96,
                height: 96,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  child: CachedNetworkImage(
                    imageUrl: meditation.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: Colors.black12),
                    errorWidget: (_, _, _) => const Icon(Icons.self_improvement),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gapMedium),
              // Текстовая часть
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meditation.situation,
                      style: AppTypography.body,
                    ),
                    const SizedBox(height: AppSpacing.gapMedium),
                    Builder(
                      builder: (context) {
                        String skillLabel = meditation.dbtSkill;
                        if (skillLabel == 'Эмпатическое присутствие') {
                          skillLabel = 'Эмпатия';
                        }

                        final tags = <String>[];
                        if (meditation.duration.isNotEmpty) {
                          tags.add(meditation.duration);
                        }
                        tags.add(skillLabel);

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final tag in tags)
                              Container(
                                decoration: AppDecorations.filledChip,
                                padding: AppChipStyles.padding,
                                child: Text(
                                  tag,
                                  style: AppTypography.chipLabel,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.gapLarge),

          // Хинт перед началом практики
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: const Text(
              '🌿 Найдите спокойное место, где вас никто не потревожит, сядьте поудобнее и начните.',
              style: AppTypography.bodySecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.gapXL),

          if (_loadFailed) ...[
            const SizedBox(height: AppSpacing.gapXL),
            Text(
              'Не удалось загрузить аудио медитации.\nЧасто это связано с подключением к интернету. Попробуйте ещё раз или переключите вкладку.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),
          ] else ...[
            // Переключатель режима аудио
            Container(
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.gapSmall),
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            _useVoice ? Colors.white : Colors.transparent,
                        foregroundColor:
                            _useVoice ? AppColors.primary : AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        if (!_useVoice) {
                          _switchAudio(true);
                        }
                      },
                      child: const Text('С голосом'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapMedium),
                  Expanded(
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            !_useVoice ? Colors.white : Colors.transparent,
                        foregroundColor:
                            !_useVoice ? AppColors.primary : AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        if (_useVoice) {
                          _switchAudio(false);
                        }
                      },
                      child: const Text('Только музыка'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapSmall),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.gapXL),

            if (_isLoading) ...[
              const SizedBox(height: AppSpacing.gapLarge),
              const Center(child: CircularProgressIndicator()),
            ] else ...[
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
              const SizedBox(height: AppSpacing.gapLarge),
              // play / pause
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return Center(
                    child: FilledButton.icon(
                      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                      label: Text(playing ? "Пауза" : "Начать"),
                      onPressed: () async {
                        if (playing) {
                          await _player.pause();
                        } else {
                          await _player.play();
                          AmplitudeService.instance.logEvent(
                            _useVoice
                                ? 'meditation_with_voice'
                                : 'meditation_background',
                            properties: {
                              'meditation': meditation.title,
                            },
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ],

          if (!meditation.isFree) ...[
            const SizedBox(height: AppSpacing.gapLarge),
            Text(
              "Для доступа к этой медитации может потребоваться подписка.",
              style: AppTypography.bodySecondary,
            ),
          ],
        ],
      ),
    );
  }
}