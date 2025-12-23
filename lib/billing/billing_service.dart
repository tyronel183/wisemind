// lib/billing/billing_service.dart
import 'package:flutter/material.dart';
import '../revenuecat/revenuecat_service.dart';

/// Единая обёртка над платёжной логикой.
///
/// Сейчас:
///   - используем RevenueCat (Google Play / App Store).
///
/// Важно: UI должен ходить ТОЛЬКО сюда, а не напрямую к RevenueCat.
class BillingService {
  BillingService._();

  /// Инициализация биллинга.
  static Future<void> init() async {
    // Глобальный релиз (Google Play / App Store): RevenueCat.
    await RevenueCatService.instance.init();
  }

  /// Проверка Pro и показ paywall при необходимости.
  ///
  /// screen — название раздела/экрана (например: "home", "worksheets", "meditations", "skills").
  /// source — источник открытия (например: "fab", "locked_item", "meditation_card").
  static Future<bool> ensureProOrShowPaywall(
    BuildContext context, {
    String screen = 'unknown',
    String source = 'unknown',
  }) async {
    final service = RevenueCatService.instance;

    // Поддерживаем 2 варианта сигнатуры RevenueCatService.ensureProOrShowPaywall:
    // 1) старая: (BuildContext)
    // 2) новая:  (BuildContext, {screen, source})
    try {
      // ignore: avoid_dynamic_calls
      final result = await (service as dynamic).ensureProOrShowPaywall(
        context,
        screen: screen,
        source: source,
      ) as bool;
      return result;
    } catch (_) {
      // Фолбэк на старую сигнатуру (пока RevenueCatService не обновлён).
      return service.ensureProOrShowPaywall(context);
    }
  }

  /// Асинхронная проверка статуса Pro.
  static Future<bool> get isPro => RevenueCatService.instance.isPro;

  /// Синхронная проверка статуса Pro.
  static bool get isProSync => RevenueCatService.instance.isProSync;

  /// Восстановление покупок.
  static Future<void> restorePurchases(BuildContext context) async {
    await RevenueCatService.instance.restorePurchases(context);
  }

  /// Открыть экран управления подпиской.
  static Future<void> openSubscriptionManagement(
    BuildContext context,
  ) async {
    await RevenueCatService.instance.openCustomerCenter(context);
  }
}