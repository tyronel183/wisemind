import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wisemind/billing/billing_service.dart';
import '../l10n/app_localizations.dart';

import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../theme/app_card_tile.dart';
import '../theme/app_components.dart';
import '../analytics/amplitude_service.dart';
import 'dbt_skill.dart';
import 'dbt_skills_loader.dart';
import 'dbt_faq_screen.dart';

// Helper: Localize module title
String localizedModuleTitle(BuildContext context, DbtModule module) {
  final l = AppLocalizations.of(context)!;
  switch (module) {
    case DbtModule.mindfulness:
      return l.dbtModule_mindfulness;
    case DbtModule.distressTolerance:
      return l.dbtModule_distressTolerance;
    case DbtModule.emotionRegulation:
      return l.dbtModule_emotionRegulation;
    case DbtModule.interpersonalEffectiveness:
      return l.dbtModule_interpersonalEffectiveness;
  }
}

// Workaround (TEMP): derive subsection headers for a couple of DBT modules in code
// to avoid manual upkeep of `meta.section` inside dbt_skills.json.
// NOTE: Move this to stable section keys in JSON + l10n once the content settles.
bool _isRuLocale(BuildContext context) {
  final l = AppLocalizations.of(context)!;
  return l.localeName.toLowerCase().startsWith('ru');
}

String _whatSectionTitle(BuildContext context) {
  return _isRuLocale(context) ? 'Навыки «Что»' : 'Skills “What”';
}

String _howSectionTitle(BuildContext context) {
  return _isRuLocale(context) ? 'Навыки «Как»' : 'Skills “How”';
}

String _stressCopingSectionTitle(BuildContext context) {
  return _isRuLocale(context)
      ? 'Навыки справления со стрессом'
      : 'Crisis survival skills';
}

String _realityAcceptanceSectionTitle(BuildContext context) {
  return _isRuLocale(context)
      ? 'Навыки принятия реальности'
      : 'Reality acceptance skills';
}

String _additionalSectionTitle(BuildContext context) {
  return _isRuLocale(context) ? 'Дополнительно' : 'Additional';
}

int _mindfulnessRank(String name) {
  // 0: Wise Mind (no header)
  if (_containsAny(name, ['мудрый разум', 'wise mind'])) return 0;

  // 1..3: WHAT skills
  if (_containsAny(name, ['наблюд', 'observe', 'observation'])) return 1;
  if (_containsAny(name, ['опис', 'describe', 'description'])) return 2;
  if (_containsAny(name, ['участ', 'участие', 'participate', 'participation'])) return 3;

  // 4..6: HOW skills
  if (_containsAny(name, ['безоцен', 'non-judgment', 'nonjudgment'])) return 4;
  if (_containsAny(name, [
    'однозадач',
    'однонаправ',
    'one-mind',
    'onemind',
    'single-tasking',
    'single tasking',
  ])) return 5;
  if (_containsAny(name, ['эффектив', 'effectively', 'effectiveness'])) return 6;

  // 7..8: Additional
  if (_containsAny(name, ['осознанное питание', 'mindful eating'])) return 7;
  if (_containsAny(name, ['серфинг', 'urge surfing'])) return 8;

  return 999;
}

int _distressToleranceRank(String name) {
  // 0..5: Crisis survival skills
  if (_containsAny(name, ['за и против', 'pros and cons', 'pros & cons'])) return 0;
  if (_containsAny(name, ['стоп', 'stop'])) return 1;
  if (_containsAny(name, ['тип', 'tip'])) return 2;
  if (_containsAny(name, ['accepts'])) return 3;
  if (_containsAny(name, ['5 чувств', 'пять чувств', '5 senses', 'five senses'])) return 4;
  if (_containsAny(name, ['improve'])) return 5;

  // 100..103: Reality acceptance skills
  if (_containsAny(name, ['радикаль', 'radical acceptance'])) return 100;
  if (_containsAny(name, ['полуулыб', 'half-smile', 'half smile'])) return 101;
  if (_containsAny(name, ['готовност', 'willingness'])) return 102;
  if (_containsAny(name, ['осознанность мыслей', 'mindfulness of thoughts'])) return 103;

  return 999;
}

String _normalizeSkillName(String? name) {
  return (name ?? '').trim().toLowerCase();
}

bool _containsAny(String haystack, List<String> needles) {
  for (final n in needles) {
    if (haystack.contains(n)) return true;
  }
  return false;
}

/// Returns a localized subsection title for the given skill.
/// - If `meta.section` is set, uses it.
/// - Otherwise, for Mindfulness and Distress Tolerance, derives section from the skill name.
/// - For other modules returns empty string.
String _sectionTitleForSkill(BuildContext context, DbtSkill skill) {
  final explicit = (skill.meta.section ?? '').trim();
  if (explicit.isNotEmpty) return explicit;

  final module = skill.meta.module;
  final name = _normalizeSkillName(skill.texts.name);

  // Mindfulness: Wise Mind (no header) + WHAT / HOW + Additional
  if (module == DbtModule.mindfulness) {
    // "Wise Mind" should be shown at the very top, without any section header.
    if (_containsAny(name, ['мудрый разум', 'wise mind'])) {
      return '';
    }

    // Additional skills
    if (_containsAny(name, ['осознанное питание', 'mindful eating', 'серфинг', 'urge surfing'])) {
      return _additionalSectionTitle(context);
    }

    // WHAT skills
    if (_containsAny(name, [
      'наблюд',
      'опис',
      'участ',
      'участие',
      'observe',
      'observation',
      'describe',
      'description',
      'participate',
      'participation',
    ])) {
      return _whatSectionTitle(context);
    }

    // HOW skills
    if (_containsAny(name, [
      'безоцен',
      'однозадач',
      'однонаправ',
      'эффектив',
      'non-judgment',
      'nonjudgment',
      'one-mind',
      'onemind',
      'single-tasking',
      'single tasking',
      'effectively',
      'effectiveness',
    ])) {
      return _howSectionTitle(context);
    }

    // Everything else: no header.
    return '';
  }

  // Distress tolerance: crisis survival vs reality acceptance
  if (module == DbtModule.distressTolerance) {
    final isAcceptance = _containsAny(name, [
      // RU
      'радикаль',
      'приняти',
      'поворот разума',
      'поворот',
      'готовност',
      'полуулыб',
      'улыб',
      'готовые руки',
      'осознанность мыслей',
      // EN
      'radical acceptance',
      'turning the mind',
      'willingness',
      'half-smile',
      'half smile',
      'willing hands',
      'mindfulness of thoughts',
    ]);

    return isAcceptance
        ? _realityAcceptanceSectionTitle(context)
        : _stressCopingSectionTitle(context);
  }

  return '';
}

/// Корневой экран вкладки "Навыки DBT":
/// показывает интро DBT и 4 модуля
class SkillsRootScreen extends StatefulWidget {
  const SkillsRootScreen({super.key});

  @override
  State<SkillsRootScreen> createState() => _SkillsRootScreenState();
}

class _SkillsRootScreenState extends State<SkillsRootScreen> {
  @override
  void initState() {
    super.initState();
    // Экран категорий навыков
    AmplitudeService.instance.logEvent('skills_categories_screen');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final modules = DbtModule.values;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenTitleHorizontal,
                vertical: AppSpacing.screenTitleVertical,
              ),
              child: Center(
                child: Text(
                  l.skillsRoot_title,
                  style: AppTypography.screenTitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.padding),
                children: [
                  // Интро-карточка DBT
                  AppCardTile(
                    leading: const Icon(Icons.psychology_alt, size: 32),
                    title: l.skillsRoot_dbtIntro_title,
                    subtitle: l.skillsRoot_dbtIntro_subtitle,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DbtFaqScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.gapLarge),

                  // Модули DBT — карточки с картинками 2 в ряд
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSizes.padding,
                    crossAxisSpacing: AppSizes.padding,
                    childAspectRatio: 0.9,
                    children: [
                      for (final module in modules)
                        SkillCategoryCard(
                          title: localizedModuleTitle(context, module),
                          assetPath: _assetPathForModule(context, module),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SkillsListScreen(module: module),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _assetPathForModule(BuildContext context, DbtModule module) {
    final l = AppLocalizations.of(context)!;
    final localeName = l.localeName; // e.g. 'en', 'en_US', 'ru', 'ru_RU'
    final isRu = localeName.toLowerCase().startsWith('ru');
    final prefix = isRu ? 'assets/images/skills/ru' : 'assets/images/skills/en';

    switch (module) {
      case DbtModule.mindfulness:
        return '$prefix/mindfulness.png';
      case DbtModule.distressTolerance:
        return '$prefix/distress_tolerance.png';
      case DbtModule.emotionRegulation:
        return '$prefix/emotion_regulation.png';
      case DbtModule.interpersonalEffectiveness:
        return '$prefix/interpersonal_effectiveness.png';
    }
  }
}

/// Интро-экран "Что такое DBT"
class DbtIntroScreen extends StatelessWidget {
  const DbtIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l.dbtIntro_appBar_title,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ListView(
          children: [
            Text(
              l.dbtIntro_header,
              style: AppTypography.screenTitle,
            ),
            const SizedBox(height: 12),
            Text(
              l.dbtIntro_body,
              style: AppTypography.body,
            ),
            const SizedBox(height: 24),
            Text(
              l.dbtIntro_section_start,
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              l.dbtIntro_howToStart,
              style: AppTypography.body,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const SkillsListScreen(module: DbtModule.mindfulness),
                    ),
                  );
                },
                icon: const Icon(Icons.self_improvement),
                label: Text(l.dbtIntro_startMindfulness_button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран списка навыков внутри одного раздела (модуля)
class SkillsListScreen extends StatefulWidget {
  final DbtModule module;

  const SkillsListScreen({super.key, required this.module});

  @override
  State<SkillsListScreen> createState() => _SkillsListScreenState();
}

class _SkillsListScreenState extends State<SkillsListScreen> {
  Future<List<DbtSkill>>? _skillsFuture;
  String? _lastLocaleName;
  @override
  void initState() {
    super.initState();
    // Открыт список навыков конкретного модуля
    AmplitudeService.instance.logEvent(
      'skill_list',
      properties: {'category': widget.module.title},
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    // При смене языка пересоздаём Future, чтобы список реально перезагрузился.
    if (_skillsFuture == null || _lastLocaleName != l10n.localeName) {
      _lastLocaleName = l10n.localeName;
      _skillsFuture = DbtSkillsLoader.loadSkills(localeOverride: locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final module = widget.module;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          localizedModuleTitle(context, module),
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: FutureBuilder<List<DbtSkill>>(
        future: _skillsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Пока грузим JSON — показываем крутилку
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${l.skillsList_error_prefix}\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final allSkills = snapshot.data ?? [];

          final skills = allSkills.where((s) => s.meta.module == module).toList();

          // WORKAROUND (TEMP): enforce the intended teaching sequence for Mindfulness
          // and Distress Tolerance.
          skills.sort((a, b) {
            if (module == DbtModule.mindfulness) {
              final ar = _mindfulnessRank(_normalizeSkillName(a.texts.name));
              final br = _mindfulnessRank(_normalizeSkillName(b.texts.name));
              if (ar != br) return ar.compareTo(br);
            }

            if (module == DbtModule.distressTolerance) {
              final ar =
                  _distressToleranceRank(_normalizeSkillName(a.texts.name));
              final br =
                  _distressToleranceRank(_normalizeSkillName(b.texts.name));
              if (ar != br) return ar.compareTo(br);
            }

            return a.meta.order.compareTo(b.meta.order);
          });

          if (skills.isEmpty) {
            return Center(
              child: Text(
                l.skillsList_empty,
                textAlign: TextAlign.center,
              ),
            );
          }

          // Группируем по section
          final Map<String, List<DbtSkill>> bySection = {};
          for (final skill in skills) {
            final key = _sectionTitleForSkill(context, skill);
            bySection.putIfAbsent(key, () => []).add(skill);
          }

          return ListView(
            padding: const EdgeInsets.only(
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              top: AppSpacing.contentTopWithoutTitle,
              bottom: AppSpacing.screenPadding,
            ),
            children: [
              for (final entry in bySection.entries) ...[
                if (entry.key.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sectionTitleTop,
                      bottom: AppSpacing.sectionTitleBottom,
                    ),
                    child: Text(
                      entry.key,
                      style: AppTypography.sectionTitle,
                    ),
                  ),
                ],
                for (final skill in entry.value)
                  AppCardTile(
                    leading: Text(
                      skill.meta.emoji ?? '🧠',
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                    title: skill.texts.name,
                    subtitle: skill.texts.shortDescription,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      // Модуль "Осознанность" всегда доступен бесплатно.
                      if (module == DbtModule.mindfulness) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SkillOverviewScreen(skill: skill),
                          ),
                        );
                        return;
                      }

                      // Для остальных модулей проверяем доступ через общий биллинговый слой.
                      final allowed =
                          await BillingService.ensureProOrShowPaywall(
                              context);
                      if (!context.mounted || !allowed) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              SkillOverviewScreen(skill: skill),
                        ),
                      );
                    },
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Экран с общей информацией о навыке
class SkillOverviewScreen extends StatefulWidget {
  final DbtSkill skill;

  const SkillOverviewScreen({super.key, required this.skill});

  @override
  State<SkillOverviewScreen> createState() => _SkillOverviewScreenState();
}

class _SkillOverviewScreenState extends State<SkillOverviewScreen> {
  @override
  void initState() {
    super.initState();
    final categoryTitle = widget.skill.meta.module.title;

    AmplitudeService.instance.logEvent(
      'skill_overview',
      properties: {
        'category': categoryTitle,
        'skill': widget.skill.texts.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final skill = widget.skill;
    final categoryTitle = localizedModuleTitle(context, skill.meta.module);
    final sectionTitle = _sectionTitleForSkill(context, skill);
    final meta = sectionTitle.isEmpty
        ? categoryTitle
        : '$categoryTitle${l.skillOverview_meta_separator}$sectionTitle';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          skill.texts.name,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ListView(
          children: [
            // Заголовок
            Text(
              skill.texts.name,
              style: AppTypography.screenTitle,
            ),
            const SizedBox(height: 8),
            // Краткое описание как подзаголовок
            Text(
              skill.texts.shortDescription,
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: 8),
            // Мета: раздел / подкатегория
            Text(
              meta,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // Блок "Что это такое"
            Text(
              l.skillOverview_section_what,
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              skill.textWhat ?? l.skillOverview_section_what_placeholder,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),

            // Кнопка "Полная информация о навыке"
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullSkillInfoScreen(
                      skillTitle: skill.texts.name,
                      categoryTitle: skill.meta.module.title,
                      fullInfo: skill.texts.fullInfo ??
                          l.skillOverview_fullInfo_placeholder(skill.texts.name),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book),
              label: Text(l.skillOverview_fullInfo_button),
            ),
            const SizedBox(height: 24),

            // Блок "Зачем это нужно"
            Text(
              l.skillOverview_section_why,
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              skill.texts.textWhy ??
                  l.skillOverview_section_why_placeholder,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),

            // Блок "Как практиковать'
            Text(
              l.skillOverview_section_practice,
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              skill.texts.textPractice ??
                  l.skillOverview_section_practice_placeholder,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),

            // Кнопка "Подробнее о практике"
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullSkillPracticeScreen(
                      skillTitle: skill.texts.name,
                      categoryTitle: skill.meta.module.title,
                      practiceTitle: l.skillPractice_titlePattern(skill.texts.name),
                      fullPractice: skill.texts.fullPractice ??
                          l.skillOverview_fullPractice_placeholder(skill.texts.name),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.checklist),
              label: Text(l.skillOverview_morePractice_button),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран с полной информацией о навыке
class FullSkillInfoScreen extends StatefulWidget {
  final String skillTitle;
  final String categoryTitle;
  final String fullInfo;

  const FullSkillInfoScreen({
    super.key,
    required this.skillTitle,
    required this.categoryTitle,
    required this.fullInfo,
  });

  @override
  State<FullSkillInfoScreen> createState() => _FullSkillInfoScreenState();
}

class _FullSkillInfoScreenState extends State<FullSkillInfoScreen> {
  @override
  void initState() {
    super.initState();
    AmplitudeService.instance.logEvent(
      'skill_full_description',
      properties: {
        'category': widget.categoryTitle,
        'skill': widget.skillTitle,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.skillTitle,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: SingleChildScrollView(
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.skillFullInfo_title,
                    style: AppTypography.screenTitle,
                  ),
                  const SizedBox(height: 12),
                  Html(
                    data: widget.fullInfo,
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(16),
                        lineHeight: LineHeight.number(1.35),
                      ),
                      'p': Style(
                        margin: Margins.only(bottom: 10),
                      ),
                      'h2': Style(
                        margin: Margins.only(top: 16, bottom: 12),
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize(22),
                      ),
                      'h3': Style(
                        margin: Margins.only(top: 14, bottom: 8),
                        fontWeight: FontWeight.w600,
                        fontSize: FontSize(18),
                      ),
                      'ul': Style(
                        margin: Margins.only(top: 6, bottom: 6),
                        padding: HtmlPaddings.only(left: 20),
                      ),
                      'li': Style(
                        margin: Margins.only(bottom: 4),
                      ),
                      'hr': Style(
                        margin: Margins.symmetric(vertical: 12),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black26,
                            width: 1,
                          ),
                        ),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Экран с полной практикой по навыку
class FullSkillPracticeScreen extends StatefulWidget {
  final String skillTitle;
  final String categoryTitle;
  final String practiceTitle;
  final String fullPractice;

  const FullSkillPracticeScreen({
    super.key,
    required this.skillTitle,
    required this.categoryTitle,
    required this.practiceTitle,
    required this.fullPractice,
  });

  @override
  State<FullSkillPracticeScreen> createState() =>
      _FullSkillPracticeScreenState();
}

class _FullSkillPracticeScreenState extends State<FullSkillPracticeScreen> {
  @override
  void initState() {
    super.initState();
    AmplitudeService.instance.logEvent(
      'skill_practice',
      properties: {
        'category': widget.categoryTitle,
        'skill': widget.skillTitle,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.skillTitle,
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: SingleChildScrollView(
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.practiceTitle,
                    style: AppTypography.screenTitle,
                  ),
                  const SizedBox(height: 12),
                  Html(
                    data: widget.fullPractice,
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(16),
                        lineHeight: LineHeight.number(1.35),
                      ),
                      'p': Style(
                        margin: Margins.only(bottom: 10),
                      ),
                      'h2': Style(
                        margin: Margins.only(top: 16, bottom: 12),
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize(22),
                      ),
                      'h3': Style(
                        margin: Margins.only(top: 14, bottom: 8),
                        fontWeight: FontWeight.w600,
                        fontSize: FontSize(18),
                      ),
                      'ul': Style(
                        margin: Margins.only(top: 6, bottom: 6),
                        padding: HtmlPaddings.only(left: 20),
                      ),
                      'li': Style(
                        margin: Margins.only(bottom: 4),
                      ),
                      'hr': Style(
                        margin: Margins.symmetric(vertical: 12),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.black26,
                            width: 1,
                          ),
                        ),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}