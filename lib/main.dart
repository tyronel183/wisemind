import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat/revenuecat_constants.dart';

/// Сервис-обёртка вокруг RevenueCat.
///
/// Используется для инициализации SDK, проверки доступа к Pro-версии
/// и управления покупками.
class RevenueCatService {
  static bool _isConfigured = false;

  /// Инициализация RevenueCat SDK.
  /// Вызывается один раз при старте приложения (в `main()`).
  static Future<void> init() async {
    if (_isConfigured) return;

    final configuration = PurchasesConfiguration(
      RevenueCatConstants.apiKey,
    );

    await Purchases.configure(configuration);
    _isConfigured = true;

    if (kDebugMode) {
      debugPrint('[RevenueCat] SDK configured');
    }
  }

  /// Получение информации о пользователе и его энтайтлментах.
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] Error getting customer info: $e');
      }
      return null;
    }
  }

  /// Проверка, есть ли у пользователя активная подписка / покупка Wisemind Pro.
  static Future<bool> hasProAccess() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final entitlements = info.entitlements.active;
      return entitlements.containsKey(RevenueCatConstants.entitlementWisemindPro);
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] Error checking Pro access: $e');
      }
      return false;
    }
  }

  /// Попытка восстановить покупки (Restore purchases).
  static Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      return info;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] Error restoring purchases: $e');
      }
      return null;
    }
  }
}
