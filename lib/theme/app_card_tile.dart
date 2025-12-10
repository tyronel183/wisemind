import 'package:flutter/material.dart';
import 'package:wisemind/theme/app_components.dart';

import 'app_spacing.dart';
import 'app_theme.dart';

/// Унифицированная карточка-превью для списков (упражнения, навыки, медитации и т.п.)
///
/// Примеры использования:
/// - иконка слева + заголовок + подзаголовок + стрелка:
///   AppCardTile(
///     leadingIcon: Icons.commit,
///     title: 'Анализ нежелательного поведения',
///     subtitle: 'Исследование поведения, которое хочется изменить',
///     onTap: () { ... },
///   );
///
/// - без иконки, только текст:
///   AppCardTile(
///     title: 'Название медитации',
///     subtitle: 'Краткое описание',
///   );
class AppCardTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Иконка слева (если нужно). Можно не задавать.
  final IconData? leadingIcon;

  /// Кастомный leading-виджет (картинка, аватар и т.п.).
  /// Если задан и [leadingIcon] тоже задан, используется [leading].
  final Widget? leading;

  /// Кастомный trailing-виджет (по умолчанию — стрелка).
  final Widget? trailing;

  /// Обработчик нажатия по карточке.
  final VoidCallback? onTap;

  /// Внешний отступ карточки. По умолчанию — только отступ снизу.
  final EdgeInsetsGeometry? margin;

  /// Внутренние отступы ListTile.
  final EdgeInsetsGeometry? contentPadding;

  const AppCardTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMargin =
        margin ?? const EdgeInsets.only(bottom: AppSpacing.sectionTitleBottom);

    final effectiveContentPadding = contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPaddingHorizontal,
          vertical: AppSpacing.gapMedium,
        );

    return Container(
      margin: effectiveMargin,
      decoration: AppDecorations.card,
      child: ListTile(
        onTap: onTap,
        contentPadding: effectiveContentPadding,
        leading: leadingIcon != null && leading == null
            ? Icon(leadingIcon)
            : leading,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) SizedBox(height: 4),
            if (subtitle != null)
              Text(
                subtitle!,
                style: AppTypography.bodySecondary.copyWith(height: 1.2),
              ),
          ],
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// Карточка с изображением и тегами (чипами).
///
/// Подходит, например, для списка медитаций:
/// - слева обложка / превью;
/// - справа заголовок, описание и теги (например, "С голосом", "Фоновая").
class AppImageCardTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<String>? tags;

  /// Обязательная картинка слева.
  final Widget image;

  /// Обработчик нажатия по карточке.
  final VoidCallback? onTap;

  /// Внешний отступ карточки. По умолчанию — только отступ снизу.
  final EdgeInsetsGeometry? margin;

  const AppImageCardTile({
    super.key,
    required this.title,
    required this.image,
    this.subtitle,
    this.tags,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMargin =
        margin ?? const EdgeInsets.only(bottom: AppSpacing.sectionTitleBottom);

    return Container(
      margin: effectiveMargin,
      decoration: AppDecorations.card,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingHorizontal),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение слева фиксированного размера
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: image,
                ),
              ),
              const SizedBox(width: AppSpacing.gapMedium),
              // Контент справа
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySecondary.copyWith(height: 1.2),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (tags != null && tags!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.gapMedium),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in tags!)
                            Container(
                              padding: AppChipStyles.padding,
                              decoration: AppDecorations.filledChip,
                              child: Text(
                                tag,
                                style:
                                    Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
