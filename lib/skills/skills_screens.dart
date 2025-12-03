import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../theme/app_card_tile.dart';
import 'dbt_skill.dart';
import 'dbt_skills_loader.dart';

/// Корневой экран вкладки "Навыки DBT":
/// показывает интро DBT и 4 модуля
class SkillsRootScreen extends StatelessWidget {
  const SkillsRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: const Center(
                child: Text(
                  'Навыки DBT',
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
                children: [
                  // Интро-карточка DBT
                  AppCardTile(
                    leading: const Icon(Icons.psychology_alt, size: 32),
                    title: 'Диалектическая поведенческая терапия',
                    subtitle: 'Что такое DBT, из чего она состоит и как с ней работать в этом приложении.',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DbtIntroScreen(),
                        ),
                      );
                    },
                  ),
                  // Модули DBT
                  for (final module in modules) ...[
                    AppCardTile(
                      leading: Icon(module.icon, size: 32),
                      title: module.title,
                      subtitle: module.subtitle,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SkillsListScreen(module: module),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Интро-экран "Что такое DBT"
class DbtIntroScreen extends StatelessWidget {
  const DbtIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Что такое DBT',
          style: AppTypography.screenTitle,
          textAlign: TextAlign.center,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: ListView(
          children: [
            const Text(
              'Диалектическая поведенческая терапия',
              style: AppTypography.screenTitle,
            ),
            const SizedBox(height: 12),
            Text(
              'Здесь позже появится полный текст о том, что такое DBT, из каких модулей она состоит и как использовать это приложение как сопровождение к терапии.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 24),
            const Text(
              'С чего начать',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              'Обычно знакомство с DBT начинается с блока осознанности: навыков «что» и «как» быть в моменте. '
              'Нажми на кнопку ниже, чтобы перейти к модулю Осознанность и начать разбирать навыки по шагам.',
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
                label: const Text('Начнём с осознанности'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран списка навыков внутри одного раздела (модуля)
class SkillsListScreen extends StatelessWidget {
  final DbtModule module;

  const SkillsListScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          module.title,
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
                'Ошибка при загрузке навыков:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final allSkills = snapshot.data ?? [];

          final skills = allSkills
              .where((s) => s.module == module)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          if (skills.isEmpty) {
            return const Center(
              child: Text(
                'Навыков в этом разделе пока нет.',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Группируем по section
          final Map<String, List<DbtSkill>> bySection = {};
          for (final skill in skills) {
            final key = skill.section ?? '';
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
                      skill.emoji ?? '🧠',
                      style: const TextStyle(
                        fontSize: 28,
                      ),
                    ),
                    title: skill.name,
                    subtitle: skill.shortDescription,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SkillOverviewScreen(skill: skill),
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
class SkillOverviewScreen extends StatelessWidget {
  final DbtSkill skill;

  const SkillOverviewScreen({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    final meta = skill.section == null || skill.section!.isEmpty
        ? skill.module.title
        : '${skill.module.title} · ${skill.section}';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          skill.name,
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
              skill.name,
              style: AppTypography.screenTitle,
            ),
            const SizedBox(height: 8),
            // Краткое описание как подзаголовок
            Text(
              skill.shortDescription,
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
            const Text(
              'Что это такое',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              skill.textWhat ??
                  'Здесь будет описание того, что это за навык — мы добавим его из материалов позже.',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),

            // Кнопка "Полная информация о навыке"
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullSkillInfoScreen(
                      skillTitle: skill.name,
                      fullInfo: skill.fullInfo ??
                          'Здесь будет полное текстовое описание навыка «${skill.name}» '
                              'из твоих материалов. Пока это заглушка.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book),
              label: const Text('Полная информация о навыке'),
            ),
            const SizedBox(height: 24),

            // Блок "Зачем это нужно"
            const Text(
              'Зачем это нужно',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              skill.textWhy ??
                  'Позже здесь появится текст о том, в каких ситуациях навык особенно полезен и как он помогает.',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),

            // Блок "Как практиковать'
            const Text(
              'Как практиковать',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              skill.textPractice ??
                  'Здесь будут шаги практики: что делать сначала, что потом, как применять навык в жизни.',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),

            // Кнопка "Подробнее о практике"
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FullSkillPracticeScreen(
                      skillTitle: skill.name,
                      practiceTitle: 'Практика: ${skill.name}',
                      fullPractice: skill.fullPractice ??
                          'Здесь появится подробная практика по навыку «${skill.name}» '
                              'и рабочие листы. Пока это заглушка.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.checklist),
              label: const Text('Подробнее о практике'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран с полной информацией о навыке
class FullSkillInfoScreen extends StatelessWidget {
  final String skillTitle;
  final String fullInfo;

  const FullSkillInfoScreen({
    super.key,
    required this.skillTitle,
    required this.fullInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          skillTitle,
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
                    'Полная информация о навыке',
                    style: AppTypography.screenTitle,
                  ),
                  const SizedBox(height: 12),
                  Html(
                    data: fullInfo,
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
                          bottom: BorderSide(color: Colors.black26, width: 1),
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
class FullSkillPracticeScreen extends StatelessWidget {
  final String skillTitle;
  final String practiceTitle;
  final String fullPractice;

  const FullSkillPracticeScreen({
    super.key,
    required this.skillTitle,
    required this.practiceTitle,
    required this.fullPractice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          skillTitle,
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
                    practiceTitle,
                    style: AppTypography.screenTitle,
                  ),
                  const SizedBox(height: 12),
                  Html(
                    data: fullPractice,
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
                          bottom: BorderSide(color: Colors.black26, width: 1),
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