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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(32),
              boxShadow: AppShadows.soft,
            ),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
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