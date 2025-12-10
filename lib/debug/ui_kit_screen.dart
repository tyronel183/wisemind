import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';

class UiKitScreen extends StatelessWidget {
  const UiKitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const FrostedGradientAppBar(
        title: 'UI Kit',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.padding),
        children: [
          // ==== ТИПОГРАФИКА ====
          Text('Типографика', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Display title / Онбординг', style: textTheme.displaySmall),
          const SizedBox(height: 4),
          Text('Screen title / Заголовок экрана', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Section title / Заголовок секции', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Card title / Заголовок карточки', style: textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Body / Основной текст. Здесь можно посмотреть, как выглядит обычный параграф в несколько строк.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Body secondary / Вторичный текст для подсказок и описаний.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          const Divider(),

          // ==== КНОПКИ ====
          Text('Кнопки', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Primary button'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Outlined button'),
          ),
          const SizedBox(height: 16),

          const Divider(),

          // ==== КАРТОЧКИ ====
          Text('Карточки', style: textTheme.titleMedium),
          const SizedBox(height: 8),

          Container(
            decoration: AppDecorations.card,
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Основная карточка', style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Используется для основного контента: записи, блоки состояния, рабочие листы.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: AppDecorations.subtleCard,
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Вторичная карточка', style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Может использоваться для вложенных блоков или менее важного контента.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Divider(),

          // ==== МЕДИА-КАРТОЧКА ====
          Text('Медиа-карточка', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          AppMediaCard(
            title: 'Медитация: Дыхание',
            subtitle: '5 минут, чтобы вернуться в тело и в текущий момент.',
            image: Container(
              color: AppColors.primary.withOpacity(0.15),
              child: const Center(
                child: Icon(
                  Icons.self_improvement,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 16),

          const Divider(),

          // ==== ЧИПЫ / ТЕГИ ====
          Text('Чипы / теги', style: textTheme.titleMedium),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                label: 'Осознанность',
                decoration: AppDecorations.filledChip,
                textStyle: AppTypography.chipLabel,
              ),
              _buildChip(
                label: 'Стресс',
                decoration: AppDecorations.filledChip,
                textStyle: AppTypography.chipLabel,
              ),
              _buildChip(
                label: 'Регуляция эмоций',
                decoration: AppDecorations.outlinedChip,
                textStyle: AppTypography.chipLabel,
              ),
              _buildChip(
                label: 'Отношения',
                decoration: AppDecorations.outlinedChip,
                textStyle: AppTypography.chipLabel,
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Divider(),

          // ==== КАРТОЧКИ НАВЫКОВ ====
          Text('Карточки навыков', style: textTheme.titleMedium),
          const SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSizes.padding,
            crossAxisSpacing: AppSizes.padding,
            childAspectRatio: 0.9,
            children: const [
              SkillCategoryCard(
                title: 'Осознанность',
                assetPath: 'assets/images/skills/mindfulness.png',
              ),
              SkillCategoryCard(
                title: 'Устойчивость к стрессу',
                assetPath: 'assets/images/skills/distress_tolerance.png',
              ),
              SkillCategoryCard(
                title: 'Регуляция эмоций',
                assetPath: 'assets/images/skills/emotion_regulation.png',
              ),
              SkillCategoryCard(
                title: 'Межличностная эффективность',
                assetPath: 'assets/images/skills/interpersonal_effectiveness.png',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required BoxDecoration decoration,
    required TextStyle textStyle,
  }) {
    return Container(
      decoration: decoration,
      padding: AppChipStyles.padding,
      child: Text(label, style: textStyle),
    );
  }
}