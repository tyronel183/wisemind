import 'package:flutter/material.dart';

/// ======== CORE THEME CONFIG ========
/// Спокойная фиолетово‑розовая палитра в стиле Calm/Headspace
///
/// Основной цвет — мягкий фиолетовый.
/// Акцентный — более тёплый розово‑фиолетовый.
/// Нейтральный — серые спокойные оттенки.
/// Фон — кремово‑белый с лёгким пастельным тоном.
///
/// Здесь лежат все:
/// • цвета
/// • тени
/// • размеры
/// • типографика
///
/// А потом: AppTheme.lightTheme применять в MaterialApp()

class AppColors {
  // Основные
  static const Color primary = Color(0xFF613DC7);       // фирменный фиолетовый Wisemind
  static const Color primaryDark = Color(0xFF4524A5);
  static const Color secondary = Color(0xFFFFB347);     // тёплый акцент
  static const Color accent = Color(0xFFE48CFF);        // яркий вспомогательный акцент

  // Фон
  static const Color background = Color(0xFFF9F6FF);    // мягкий пастельный фон, как было раньше
  static const Color appBarBackground = Color(0xFFF1EBFF); // чуть темнее фона для аппбара
  static const Color surface = Colors.white;

  // Текстовые
  static const Color textPrimary = Color(0xFF1F2430);
  static const Color textSecondary = Color(0xFF666A7A);

  // Границы
  static const Color border = Color(0xFFD0CCE8);

  // Успокаивающие серые / служебные
  static const Color greyLight = Color(0xFFECE8FF);
  static const Color grey = Color(0xFF8B8FA0);
}

/// ======== ТИПОГРАФИКА (НОРМАЛИЗОВАННАЯ) ========
/// Единая типографика для всего приложения.
/// Используем эти стили через Theme.textTheme или напрямую.

class AppTypography {
  /// Крупный заголовок (онбординг, промо-экраны)
  static const TextStyle displayTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  /// Заголовок экрана
  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Заголовок раздела внутри экрана
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Заголовок карточки
  static const TextStyle cardTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Основной текст / описание
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Вторичный текст / подписи / вспомогательное
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  /// Мелкие лейблы / чипы / теги
  static const TextStyle chipLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );
}

/// ======== ТИПОГРАФИКА (СТАРЫЕ ИМЕНА) ========
/// Оставляем для совместимости, но по смыслу это
/// те же уровни, что и в AppTypography.

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}


/// ======== РАЗМЕРЫ ========

class AppSizes {
  static const double cardRadius = 20;
  static const double buttonRadius = 14;

  static const double padding = 16;
  static const double smallPadding = 10;

  static const double elevation = 4;
}

/// ======== ТЕНИ ========

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x1A000000), // 10% чёрного
      blurRadius: 16,
      offset: Offset(0, 6),
    )
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0F000000), // 6% чёрного
      blurRadius: 10,
      offset: Offset(0, 4),
    )
  ];
}

/// ======== ГОТОВАЯ ТЕМА ДЛЯ MaterialApp ========

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    brightness: Brightness.light,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.appBarBackground,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
    ),

    textTheme: const TextTheme(
      // Крупные заголовки (онбординг, промо-блоки)
      displaySmall: AppTypography.displayTitle,

      // Заголовок экрана
      headlineSmall: AppTypography.screenTitle,

      // Заголовки секций / блоков
      titleMedium: AppTypography.sectionTitle,

      // Заголовки карточек
      titleSmall: AppTypography.cardTitle,

      // Основной текст
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.body,

      // Вторичный текст
      bodySmall: AppTypography.bodySecondary,

      // Мелкие подписи / чипы / теги
      labelSmall: AppTypography.chipLabel,
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}