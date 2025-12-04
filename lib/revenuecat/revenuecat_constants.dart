class RevenueCatConstants {
  // Тестовый ключ, который ты дал
  static const String apiKey = 'test_hgRrFFizBWwhGxKVyQLRcElkxpV';

  // Имена офферинга и энтайтла — такие же должны быть в RevenueCat Dashboard
  static const String entitlementWisemindPro = 'Wisemind Pro';

  // Если будешь использовать конкретный offering
  static const String mainOfferingId = 'default'; 
  // можно оставить 'default', если в RC используется стандартный офферинг
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