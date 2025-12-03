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
  static const Color primary = Color(0xFF8E70FF);       // мягкий фиолетовый
  static const Color primaryDark = Color(0xFF6C4DDB);
  static const Color secondary = Color(0xFFE4C7FF);     // пастельный розово‑фиолетовый
  static const Color accent = Color(0xFFDA7BFF);        // чуть ярче

  // Фон
  static const Color background = Color(0xFFF8F5FF);    // очень светлый пастельно‑фиолетовый
  static const Color surface = Colors.white;

  // Текстовые
  static const Color textPrimary = Color(0xFF2E2B36);
  static const Color textSecondary = Color(0xFF6F6A7C);

  // Границы
  static const Color border = Color(0xFFE5E1F0);

  // Успокаивающие серые
  static const Color greyLight = Color(0xFFF3F1F8);
  static const Color grey = Color(0xFFB9B4C8);
}

/// ======== ТИПОГРАФИКА (НОРМАЛИЗОВАННАЯ) ========
/// Единая типографика для всего приложения.
/// Используем эти стили через Theme.textTheme или напрямую.

class AppTypography {
  /// Заголовок экрана (title 1)
  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Заголовок раздела внутри экрана (title 2)
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Заголовок карточки (title 3)
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Основной текст / описание
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Вторичный текст / подписи / вспомогательное
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Мелкие лейблы / чипы / теги
  static const TextStyle chipLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

/// ======== ТИПОГРАФИКА (СТАРЫЕ ИМЕНА) ========
/// Оставляем для совместимости, но по смыслу это
/// те же уровни, что и в AppTypography.

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
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
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
    ),

    textTheme: const TextTheme(
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
  );
}