import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'revenuecat_constants.dart';

/// Сервис-обёртка над RevenueCat.
///
/// Отвечает за инициализацию SDK, получение информации о пользователе,
/// проверку доступа Wisemind Pro и показ paywall / customer center.
class RevenueCatService {
  RevenueCatService._();

  static final RevenueCatService instance = RevenueCatService._();

  bool _initialized = false;

  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  CustomerInfo? _lastInfo;

  /// Поток для подписки на изменения подписки / покупок.
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// Инициализация RevenueCat. Вызывать один раз при старте приложения.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (!kReleaseMode) {
      Purchases.setLogLevel(LogLevel.debug);
    }

    final config = PurchasesConfiguration(RevenueCatConstants.apiKey);

    // Если в будущем захочешь использовать собственный userId,
    // можно раскомментировать и передавать сюда свой идентификатор.
    // config.appUserId = yourUserId;

    await Purchases.configure(config);

    // Загружаем начальную информацию о клиенте и сохраняем локально.
    final info = await Purchases.getCustomerInfo();
    _updateInfo(info);

    // Подписываемся на обновления от SDK.
    Purchases.addCustomerInfoUpdateListener(_updateInfo);
  }

  void _updateInfo(CustomerInfo info) {
    _lastInfo = info;
    _customerInfoController.add(info);
  }

  /// Синхронная проверка: есть ли активный Wisemind Pro.
  bool get isProSync {
    final entitlement = _lastInfo?.entitlements
        .all[RevenueCatConstants.entitlementWisemindPro];
    return entitlement?.isActive == true;
  }

  /// Асинхронная проверка: при необходимости подтягивает свежий CustomerInfo.
  Future<bool> get isPro async {
    if (_lastInfo == null) {
      final info = await Purchases.getCustomerInfo();
      _updateInfo(info);
    }
    return isProSync;
  }

  /// Убедиться, что у пользователя есть Pro.
  /// Если нет — показать paywall. Возвращает true, если после этого Pro активен.
  Future<bool> ensureProOrShowPaywall(BuildContext context) async {
    // Если уже есть Pro — просто возвращаем true.
    if (await isPro) return true;

    try {
      // Показ нативного paywall, привязанного к offering в RevenueCat.
      await RevenueCatUI.presentPaywall();

      // После закрытия paywall обновляем информацию о пользователе.
      final info = await Purchases.getCustomerInfo();
      _updateInfo(info);

      return isProSync;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть экран подписки: $e'),
          ),
        );
      }
      return false;
    }
  }

  /// Явное получение текущего CustomerInfo (если нужно что-то особенное).
  Future<CustomerInfo> getCustomerInfo() async {
    final info = await Purchases.getCustomerInfo();
    _updateInfo(info);
    return info;
  }

  /// Восстановление покупок (для смены устройства, переустановки и т.п.).
  Future<void> restorePurchases(BuildContext context) async {
    try {
      final info = await Purchases.restorePurchases();
      _updateInfo(info);

      if (!context.mounted) return;

      final hasPro = isProSync;
      final message = hasPro
          ? 'Подписка успешно восстановлена.'
          : 'Активных покупок не найдено.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при восстановлении покупок: $e')),
      );
    }
  }

  /// Открыть Customer Center (если он включён в RevenueCat Dashboard).
  Future<void> openCustomerCenter(BuildContext context) async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть управление подпиской: $e')),
      );
    }
  }

  /// Очистка ресурсов (если когда-нибудь понадобится закрывать сервис).
  void dispose() {
    _initialized = false;
    _customerInfoController.close();
  }
}