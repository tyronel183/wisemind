// lib/config/build_config.dart
class BuildConfig {
  /// Сейчас приложение работает в режиме RuStore:
  /// платежей через стор нет, весь контент доступен.
  ///
  /// Когда будем делать глобальный релиз с RevenueCat —
  /// переключим это значение на false и включим другой путь.
  static const bool useRuStoreBilling = true;
}