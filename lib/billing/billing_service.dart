// lib/billing/billing_service.dart
import 'package:flutter/material.dart';
import '../config/build_config.dart';

/// Единая обёртка над платёжной логикой.
///
/// Сейчас:
///   - при [BuildConfig.useRuStoreBilling == true]
///     ничего не покупаем, считаем всех Pro.
///   - позже сюда добавим:
///     * RuStore SDK
///     * и ветку с RevenueCat для глобального релиза.
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
      // TODO: когда будем делать глобальный релиз,
      // сюда вернём инициализацию RevenueCat:
      //
      // await RevenueCatService.instance.init();
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
      // TODO: сюда вернём RevenueCat paywall:
      //
      // return RevenueCatService.instance.ensureProOrShowPaywall(context);
      return true;
    }
  }

  /// Асинхронная проверка статуса Pro.
  static Future<bool> get isPro async {
    if (BuildConfig.useRuStoreBilling) {
      return true; // всё Pro
    } else {
      // TODO: вернём сюда RevenueCat:
      //
      // return RevenueCatService.instance.isPro;
      return true;
    }
  }

  /// Синхронная проверка статуса Pro.
  static bool get isProSync {
    if (BuildConfig.useRuStoreBilling) {
      return true;
    } else {
      // TODO: вернём сюда RevenueCat:
      //
      // return RevenueCatService.instance.isProSync;
      return true;
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
      // TODO: вернуть сюда:
      //
      // await RevenueCatService.instance.restorePurchases(context);
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
      // TODO: вернуть сюда:
      //
      // await RevenueCatService.instance.openCustomerCenter(context);
    }
  }
}