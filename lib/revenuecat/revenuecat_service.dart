import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'revenuecat_constants.dart';
import 'paywall_screen.dart';

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
    await Purchases.configure(config);

    final info = await Purchases.getCustomerInfo();
    _updateInfo(info);

    Purchases.addCustomerInfoUpdateListener(_updateInfo);
  }

  void _updateInfo(CustomerInfo info) {
    _lastInfo = info;
    _customerInfoController.add(info);
  }

  /// Синхронная проверка: есть ли активный Wisemind Pro.
  bool get isProSync {
    final entitlement =
        _lastInfo?.entitlements.all[RevenueCatConstants.entitlementWisemindPro];
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

  /// Выставляет предпочтительную локаль для UI-компонентов RevenueCat.
  ///
  /// Важно: поддерживаем только RU/EN, поэтому всё, что не `ru`, считаем `en`.
  Future<void> setPreferredLocale(ui.Locale locale) async {
    final lang = locale.languageCode.toLowerCase();
    final String rcLocale = (lang == 'ru') ? 'ru' : 'en';

    if (kDebugMode) {
      debugPrint(
        '[RevenueCatService] overridePreferredUILocale=$rcLocale (app locale=${locale.toLanguageTag()})',
      );
    }

    await Purchases.overridePreferredUILocale(rcLocale);
  }

  /// Убедиться, что у пользователя есть Pro.
  /// Если нет — показать paywall. Возвращает true, если после этого Pro активен.
  Future<bool> ensureProOrShowPaywall(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    final appLocale = Localizations.localeOf(context);

    if (await isPro) return true;
    if (!context.mounted) return false;

    try {
      // ВАЖНО: выставляем локаль ДО загрузки offerings/paywall.
      await setPreferredLocale(appLocale);

      // Открываем НАШ экран с AppBar и кнопкой назад.
      await navigator.push<void>(
        MaterialPageRoute(
          builder: (_) => const WisemindPaywallScreen(),
          fullscreenDialog: true,
        ),
      );

      final info = await Purchases.getCustomerInfo();
      _updateInfo(info);

      return isProSync;
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(content: Text('Не удалось открыть экран подписки: $e')),
      );
      return false;
    }
  }

  /// Восстановление покупок.
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

  /// Открыть Customer Center.
  Future<void> openCustomerCenter(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final appLocale = Localizations.localeOf(context);

    try {
      await setPreferredLocale(appLocale);
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(content: Text('Не удалось открыть управление подпиской: $e')),
      );
    }
  }

  void dispose() {
    _initialized = false;
    _customerInfoController.close();
  }
}