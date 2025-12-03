import 'package:flutter/material.dart';

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

    return Card(
      margin: effectiveMargin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
