import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../theme/app_spacing.dart';

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

          const SizedBox(height: AppSpacing.gapXL),
          const Divider(),

          // ==== ФОРМЕННЫЕ КОМПОНЕНТЫ ====
          Text('Форма / поля / выбор', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.gapLarge),

          FormSectionCard(
            title: 'Секция формы',
            subtitle: 'Пример оформления блока анкеты в стиле Wisemind',
            children: [
              AppTextField(
                controller: TextEditingController(),
                label: 'За что я себя сегодня благодарю?',
                maxLength: 140,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.gapLarge),
              AppSelectField(
                label: 'Сколько спали (часы)?',
                valueLabel: '7,5 ч',
                onTap: () {
                  // В UI Kit это просто демо без реального bottom sheet
                },
              ),
              const SizedBox(height: AppSpacing.gapLarge),
              Text(
                'Шкала от 0 до 5',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.gapMedium),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < 6; i++)
                    AppPillChoice(
                      label: i.toString(),
                      selected: i == 3, // просто пример выбранного значения
                      onTap: () {
                        // демо, здесь логика выбора не нужна
                      },
                    ),
                ],
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