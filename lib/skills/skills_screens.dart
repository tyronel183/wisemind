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
                          builder: (_) => const DbtIntroScreen(),
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
        future: DbtSkillsLoader.loadSkills(),
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

          final skills = allSkills
              .where((s) => s.meta.module == module)
              .toList()
            ..sort((a, b) => a.meta.order.compareTo(b.meta.order));

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
            final key = skill.meta.section ?? '';
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
    final section = skill.meta.section;
    final meta = section == null || section.isEmpty
        ? categoryTitle
        : '$categoryTitle${l.skillOverview_meta_separator}$section';

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