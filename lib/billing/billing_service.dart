// lib/billing/billing_service.dart
import 'package:flutter/material.dart';
import '../config/build_config.dart';
import '../revenuecat/revenuecat_service.dart';

/// Единая обёртка над платёжной логикой.
///
/// Сейчас:
///   - при [BuildConfig.useRuStoreBilling == true]
///     пока ничего не покупаем, считаем всех Pro (заглушка под RuStore).
///   - иначе используем RevenueCat (Google Play / App Store).
///
/// Важно: UI должен ходить ТОЛЬКО сюда, а не напрямую к RevenueCat.
class BillingService {
  BillingService._();

  /// Инициализация биллинга.
  static Future<void> init() async {
    if (BuildConfig.useRuStoreBilling) {
      // RuStore-режим, пока без реальных платежей.
      debugPrint('[Billing] RuStore mode: skip store SDK init for now');
      return;
    } else {
      // Глобальный релиз (Google Play / App Store): RevenueCat.
      await RevenueCatService.instance.init();
      return;
    }
  }

  /// Проверка Pro и показ paywall при необходимости.
  /// Сейчас — всегда true, всё открыто.
  static Future<bool> ensureProOrShowPaywall(BuildContext context) async {
    if (BuildConfig.useRuStoreBilling) {
      // TODO: сюда придёт RuStore-пейволл.
      return true;
    } else {
      return RevenueCatService.instance.ensureProOrShowPaywall(context);
    }
  }

  /// Асинхронная проверка статуса Pro.
  static Future<bool> get isPro async {
    if (BuildConfig.useRuStoreBilling) {
      return true; // всё Pro
    } else {
      return RevenueCatService.instance.isPro;
    }
  }

  /// Синхронная проверка статуса Pro.
  static bool get isProSync {
    if (BuildConfig.useRuStoreBilling) {
      return true;
    } else {
      return RevenueCatService.instance.isProSync;
    }
  }

  /// Восстановление покупок (пока просто заглушка).
  static Future<void> restorePurchases(BuildContext context) async {
    if (BuildConfig.useRuStoreBilling) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Восстановление покупок появится после подключения RuStore-оплаты.',
          ),
        ),
      );
    } else {
      await RevenueCatService.instance.restorePurchases(context);
    }
  }

  /// Открыть экран управления подпиской.
  static Future<void> openSubscriptionManagement(
    BuildContext context,
  ) async {
    if (BuildConfig.useRuStoreBilling) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Управление подпиской появится после подключения RuStore-оплаты.',
          ),
        ),
      );
    } else {
      await RevenueCatService.instance.openCustomerCenter(context);
    }
  }
}