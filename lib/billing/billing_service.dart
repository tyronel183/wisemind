// lib/billing/billing_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  static Future<bool> ensureProOrShowPaywall(BuildContext context) async {
    return RevenueCatService.instance.ensureProOrShowPaywall(context);
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