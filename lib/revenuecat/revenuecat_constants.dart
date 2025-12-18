import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class RevenueCatConstants {
  // ВАЖНО:
  // Public SDK key в RevenueCat зависит от платформы (обычно начинается с:
  //  - Android: "goog_..."
  //  - iOS:    "appl_..."
  // Если пока выпускаем только Android — можно временно оставить оба ключа одинаковыми,
  // но перед релизом на обе платформы обязательно подставь реальные ключи из RevenueCat Dashboard.

  // ВРЕМЕННО (замени на реальный Android public SDK key из RevenueCat)
  static const String apiKeyAndroid = 'goog_fUPsCuLwkPdfnNEhRrtHZmfXElg';

  // ВРЕМЕННО (замени на реальный iOS public SDK key из RevenueCat)
  static const String apiKeyIos = 'test_hgRrFFizBWwhGxKVyQLRcElkxpV';

  /// API-ключ для текущей платформы.
  static String get apiKey {
    if (kIsWeb) {
      throw UnsupportedError('RevenueCat is not supported on Web in this app.');
    }

    // `Platform` доступен только вне Web.
    if (Platform.isAndroid) return apiKeyAndroid;
    if (Platform.isIOS) return apiKeyIos;

    // Фолбэк (например, macOS/Windows/Linux при разработке). По умолчанию берём Android.
    return apiKeyAndroid;
  }

  // ВАЖНО:
  // Это значение должно 1-в-1 совпадать с *Entitlement Identifier* в RevenueCat Dashboard
  // (а не с отображаемым названием). Часто используют что-то вроде "wisemind_pro".
  static const String entitlementWisemindPro = 'Wisemind Pro';

  // Идентификатор offering ("default" подходит, если используешь дефолтный offering).
  static const String mainOfferingId = 'default';
}

enum SubscriptionStatus {
  unknown,
  notSubscribed,
  subscribed,
}

class SubscriptionInfo {
  final SubscriptionStatus status;
  final bool hasPro;
  final DateTime? expirationDate;
  final String? activeProductIdentifier;

  const SubscriptionInfo({
    required this.status,
    required this.hasPro,
    this.expirationDate,
    this.activeProductIdentifier,
  });

  SubscriptionInfo copyWith({
    SubscriptionStatus? status,
    bool? hasPro,
    DateTime? expirationDate,
    String? activeProductIdentifier,
  }) {
    return SubscriptionInfo(
      status: status ?? this.status,
      hasPro: hasPro ?? this.hasPro,
      expirationDate: expirationDate ?? this.expirationDate,
      activeProductIdentifier:
          activeProductIdentifier ?? this.activeProductIdentifier,
    );
  }

  static const empty = SubscriptionInfo(
    status: SubscriptionStatus.unknown,
    hasPro: false,
  );
}