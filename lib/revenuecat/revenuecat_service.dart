import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../analytics/amplitude_service.dart'; // ✅ добавили
import 'revenuecat_constants.dart';
import 'paywall_screen.dart';

class RevenueCatService {
  RevenueCatService._();

  static final RevenueCatService instance = RevenueCatService._();

  bool _initialized = false;

  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  CustomerInfo? _lastInfo;

  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

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

    // ✅ синхронизируем user property при любом апдейте CustomerInfo
    _syncSubscriptionStatusUserProperty(info);
  }

  bool get isProSync {
    final entitlement =
        _lastInfo?.entitlements.all[RevenueCatConstants.entitlementWisemindPro];
    return entitlement?.isActive == true;
  }

  Future<bool> get isPro async {
    if (_lastInfo == null) {
      final info = await Purchases.getCustomerInfo();
      _updateInfo(info);
    }
    return isProSync;
  }

  // ✅ derive subscription_status: free | monthly | yearly | lifetime
  String _deriveSubscriptionStatus(CustomerInfo info) {
    final entitlement =
        info.entitlements.all[RevenueCatConstants.entitlementWisemindPro];

    if (entitlement?.isActive != true) return 'free';

    // activeSubscriptions — самый надёжный источник для текущей активной подписки.
    final active = info.activeSubscriptions.map((e) => e.toLowerCase()).toSet();

    if (active.contains('wisemind_lifetime')) return 'lifetime';
    if (active.contains('wisemind_pro:yearly')) return 'yearly';
    if (active.contains('wisemind_pro:monthly')) return 'monthly';

    // На всякий случай: если entitlement активен, но activeSubscriptions пуст/неожиданен,
    // смотрим покупки.
    final purchased =
        info.allPurchasedProductIdentifiers.map((e) => e.toLowerCase()).toSet();

    if (purchased.contains('wisemind_lifetime')) return 'lifetime';
    if (purchased.contains('wisemind_pro:yearly')) return 'yearly';
    if (purchased.contains('wisemind_pro:monthly')) return 'monthly';

    // Детерминированный дефолт при активном entitlement
    return 'monthly';
  }

  void _syncSubscriptionStatusUserProperty(CustomerInfo info) {
    final status = _deriveSubscriptionStatus(info);

    if (kDebugMode) {
      debugPrint(
        '[RevenueCatService] subscription_status=$status '
        '(activeSubs=${info.activeSubscriptions}, allPurchased=${info.allPurchasedProductIdentifiers})',
      );
    }

    try {
      AmplitudeService.instance.setUserProperties({
        'subscription_status': status,
      });
    } catch (_) {}
  }

  // RevenueCat UI locale должен быть вида language_COUNTRY, например en_US / ru_RU
  // (подчёркивание, не дефис).
  String _toRevenueCatUiLocale(ui.Locale locale) {
    final lang = locale.languageCode.toLowerCase();

    // Поддерживаем только RU/EN.
    if (lang == 'ru') return 'ru_RU';
    return 'en_US';
  }

  Future<void> setPreferredLocale(ui.Locale locale) async {
    final String rcLocale = _toRevenueCatUiLocale(locale);

    if (kDebugMode) {
      debugPrint(
        '[RevenueCatService] overridePreferredUILocale=$rcLocale (app locale=${locale.toLanguageTag()})',
      );
    }

    await Purchases.overridePreferredUILocale(rcLocale);
  }

  Future<bool> ensureProOrShowPaywall(
    BuildContext context, {
    String screen = 'unknown',
    String source = 'unknown',
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    final appLocale = Localizations.localeOf(context);

    final wasPro = await isPro;
    if (wasPro) return true;
    if (!context.mounted) return false;

    // paywall_opened
    try {
      await AmplitudeService.instance.logEvent(
        'paywall_opened',
        properties: {
          'screen': screen,
          'source': source,
        },
      );
    } catch (_) {}

    try {
      // ВАЖНО: выставляем локаль ДО экрана paywall (и до getOfferings внутри него).
      await setPreferredLocale(appLocale);

      await navigator.push<void>(
        MaterialPageRoute(
          builder: (_) => const WisemindPaywallScreen(),
          fullscreenDialog: true,
        ),
      );

      final info = await Purchases.getCustomerInfo();
      _updateInfo(info);

      final nowPro = isProSync;

      if (nowPro) {
        final subType = _deriveSubscriptionStatus(info); // monthly/yearly/lifetime
        try {
          await AmplitudeService.instance.logEvent(
            'paywall_succeeded',
            properties: {
              'screen': screen,
              'source': source,
              'sub_type': subType,
            },
          );
        } catch (_) {}
      } else {
        try {
          await AmplitudeService.instance.logEvent(
            'paywall_closed',
            properties: {
              'screen': screen,
              'source': source,
            },
          );
        } catch (_) {}
      }

      return nowPro;
    } catch (e) {
      try {
        await AmplitudeService.instance.logEvent(
          'paywall_error',
          properties: {
            'screen': screen,
            'source': source,
            'error': e.toString(),
          },
        );
      } catch (_) {}

      messenger?.showSnackBar(
        SnackBar(content: Text('Не удалось открыть экран подписки: $e')),
      );
      return false;
    }
  }

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