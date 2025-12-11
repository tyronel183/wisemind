import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';


/// Декорации и базовые UI-паттерны: карточки, чипы, теги и т.п.
class AppDecorations {
  /// Базовая карточка (для большинства экранов)
  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    boxShadow: AppShadows.soft,
  );

  /// Вспомогательная/вторичная карточка (например, внутри списков)
  static BoxDecoration subtleCard = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
    boxShadow: AppShadows.subtle,
    border: Border.all(color: AppColors.border),
  );

  /// Заполненный чип (лейбл категории / статус)
  static BoxDecoration filledChip = BoxDecoration(
    color: AppColors.greyLight,
    borderRadius: BorderRadius.circular(999),
  );

  /// Обводка-чип (фильтры, выбор периодов и т.п.)
  static BoxDecoration outlinedChip = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: AppColors.border),
  );
}

/// Общие отступы/радиусы для чипов/тегов
class AppChipStyles {
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
}

/// Пилюля‑чип для выбора (0–5, эмодзи, теги и т.п.)
class AppPillChoice extends StatelessWidget {
  const AppPillChoice({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  /// Текст/эмодзи внутри чипа
  final String label;

  /// Выбран ли чип
  final bool selected;

  /// Обработчик нажатия
  final VoidCallback? onTap;

  /// Кастомный стиль текста внутри чипа
  final TextStyle? textStyle;

  /// Внутренние отступы
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final Color background = selected ? AppColors.primary : AppColors.greyLight;
    final Color foreground = selected ? Colors.white : AppColors.textPrimary;
    final baseStyle = textStyle ?? AppTypography.chipLabel;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: baseStyle.copyWith(color: foreground),
        ),
      ),
    );
  }
}

/// Текстовое поле в стиле Wisemind (без material‑бордера)
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.hint,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint ?? hintText,
            hintStyle: AppTypography.bodySecondary.copyWith(
              color: AppColors.textSecondary.withOpacity(0.8),
            ),
            filled: true,
            fillColor: AppColors.greyLight,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// Поле‑селектор (псевдо‑дропдаун, открывающий bottom sheet или диалог)
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.onTap,
  });

  /// Подпись над полем (что выбираем)
  final String label;

  /// Текущее отображаемое значение
  final String valueLabel;

  /// Открытие bottom sheet / диалога с выбором
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valueLabel,
                    style: AppTypography.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Секция формы, оформленная как карточка
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  /// Заголовок секции
  final String title;

  /// Подзаголовок/описание (опционально)
  final String? subtitle;

  /// Содержимое секции
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.sectionTitle,
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTypography.bodySecondary,
            ),
          ],
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Карточка с изображением слева (например, для медитаций)
class AppMediaCard extends StatelessWidget {
  const AppMediaCard({
    super.key,
    required this.title,
    this.subtitle,
    this.image,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: SizedBox(
              width: 72,
              height: 72,
              child: image,
            ),
          ),
        if (image != null) const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.cardTitle,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.bodySecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final content = Padding(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: row,
    );

    return Container(
      decoration: AppDecorations.card,
      child: onTap != null
          ? InkWell(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              onTap: onTap,
              child: content,
            )
          : content,
    );
  }
}

/// Карточка с изображением слева и чипами, прижатыми к нижнему краю
/// (например, для списка медитаций)
class AppImageCardWithBottomChips extends StatelessWidget {
  const AppImageCardWithBottomChips({
    super.key,
    required this.title,
    this.subtitle,
    required this.image,
    this.tags = const [],
    this.onTap,
  });

  /// Заголовок (например, название медитации)
  final String title;

  /// Подзаголовок / описание (ситуация и т.п.)
  final String? subtitle;

  /// Обложка слева (обычно NetworkImage / CachedNetworkImage)
  final Widget image;

  /// Чипы внизу (например, ["10 мин", "Осознанность"])
  final List<String> tags;

  /// Обработчик нажатия
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Обложка слева фиксированного размера
              SizedBox(
                width: 96,
                height: 96,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  child: image,
                ),
              ),
              const SizedBox(width: 12),
              // Справа — текст + чипы, прижатые к низу
              Expanded(
                child: SizedBox(
                  height: 96, // та же высота, что у обложки
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: tags.isNotEmpty
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      // Верх: заголовок + подзаголовок
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.cardTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: AppTypography.bodySecondary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      // Низ: чипы
                      if (tags.isNotEmpty)
                        Wrap(
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
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка категории навыка (для экрана навыков DBT)
class SkillCategoryCard extends StatelessWidget {
  const SkillCategoryCard({
    super.key,
    required this.title,
    this.assetPath,
    this.onTap,
  });

  /// Заголовок (например, "Осознанность")
  final String title;

  /// Путь до ассета (например, 'assets/images/skills/mindfulness.png')
  final String? assetPath;

  /// Обработчик нажатия
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Квадратная карта с изображением и тенью
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: AppDecorations.card,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                child: assetPath != null
                    ? Image.asset(
                        assetPath!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.greyLight,
                        child: const Icon(Icons.psychology_alt_outlined),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Кастомный аппбар с лёгким градиентом и размытием (для медитаций и др. экранов)
class FrostedGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostedGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Обычный непрозрачный аппбар с цветом из темы
      backgroundColor: AppColors.appBarBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      title: Text(title),
      centerTitle: centerTitle,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      foregroundColor: AppColors.textPrimary,

      // Настройка статус-бара, чтобы иконки были тёмными и читабельными
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light,    // iOS — тёмные иконки
      ),
    );
  }
}

/// Нижняя навигация приложения (главные разделы) — “стеклянная капсула”
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  /// Индекс текущего выбранного таба
  final int currentIndex;

  /// Колбэк при выборе таба
  final ValueChanged<int> onItemSelected;

  @override
    Widget build(BuildContext context) {
    const items = <_BottomNavItemData>[
      _BottomNavItemData(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Состояние',
      ),
      _BottomNavItemData(
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        label: 'Листы',
      ),
      _BottomNavItemData(
        icon: Icons.self_improvement_outlined,
        selectedIcon: Icons.self_improvement,
        label: 'Медитации',
      ),
      _BottomNavItemData(
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book,
        label: 'Навыки',
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _BottomNavItem(
                  data: items[i],
                  selected: i == currentIndex,
                  onTap: () => onItemSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Данные по одному табу
class _BottomNavItemData {
  const _BottomNavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Визуал одного таба внутри стеклянной капсулы
class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _BottomNavItemData data;
  final bool selected;
  final VoidCallback onTap;

    @override
    Widget build(BuildContext context) {
      final Color activeColor = AppColors.primary;
      final Color inactiveColor = AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          // Как таб «С голосом»: белый, если выбран; прозрачный, если нет
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? data.selectedIcon : data.icon,
              size: 24,
              color: selected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.chipLabel.copyWith(
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}