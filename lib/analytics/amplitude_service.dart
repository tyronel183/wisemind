import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Централизованный сервис для работы с Amplitude.
///
/// Инициализация:
///   await AmplitudeService.instance.init(apiKey: 'XXX');
/// Логирование:
///   AmplitudeService.instance.logEvent('app_opened', properties: {...});
class AmplitudeService {
  AmplitudeService._internal();

  static final AmplitudeService instance = AmplitudeService._internal();

  Amplitude? _amplitude;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Инициализация Amplitude. Вызывается один раз при старте приложения.
  Future<void> init({
    required String apiKey,
    String? userId,
    // оставляем для будущего, когда определимся с поддержкой user properties
    String? appVersion,
    Map<String, dynamic>? initialUserProperties,
  }) async {
    if (_initialized) {
      return;
    }

    // Новый SDK v4: создаём инстанс через Configuration
    final amplitude = Amplitude(
      Configuration(
        apiKey: apiKey,
        // при необходимости сюда можно добавить serverZone, minIdLength и т.п.
      ),
    );

    // Ждём полной инициализации SDK
    await amplitude.isBuilt;

    // userId в v4 по умолчанию требует длину >= 5
    if (userId != null && userId.length >= 5) {
      amplitude.setUserId(userId);
    }

    _amplitude = amplitude;
    _initialized = true;

    // --- Base user properties (platform, app_version, language, country)
    final resolvedAppVersion = appVersion ?? await _safeGetAppVersionString();
    final baseProps = <String, dynamic>{
      'platform': _platformString(),
      if (resolvedAppVersion != null) 'app_version': resolvedAppVersion,
      'language': _normalizeLanguage(ui.PlatformDispatcher.instance.locale.languageCode),
      'country': _countryCodeOrNull(),
    };

    // --- Merge with initial user properties provided by caller
    final mergedProps = <String, dynamic>{
      ...baseProps,
      if (initialUserProperties != null) ...initialUserProperties,
    };

    if (mergedProps.isNotEmpty) {
      final identify = Identify();
      mergedProps.forEach((key, value) {
        identify.set(key, value);
      });
      amplitude.identify(identify);
    }

    debugPrint('[AmplitudeService] Initialized');
  }

  /// Обновить user properties через Identify (например, при смене языка,
  /// статуса подписки, включении уведомлений и т.п.).
  Future<void> setUserProperties(Map<String, dynamic> properties) async {
    if (properties.isEmpty) return;

    final amplitude = _ensureInstance();
    if (amplitude == null) return;

    final identify = Identify();
    properties.forEach((key, value) {
      identify.set(key, value);
    });

    amplitude.identify(identify);
  }

  /// Полный синк user properties (вызывай при старте и после изменений).
  ///
  /// Проперти, которые тут поддерживаем:
  /// - platform: android / ios
  /// - app_version: например 1.0.0 (3)
  /// - language: ru / en / other
  /// - notifications_enabled: true/false
  /// - onboarding_completed: true/false
  /// - usage_guide_completed: true/false
  /// - subscription_status: free, ru_monthly, ru_yearly, ru_lifetime, revcat_monthly, ...
  /// - has_any_state_entries: true/false
  /// - has_any_worksheet_entries: true/false
  /// - country: RU/US/... (ISO 3166-1 alpha-2), если доступно
  Future<void> syncUserProperties({
    String? languageCode,
    bool? notificationsEnabled,
    bool? onboardingCompleted,
    bool? usageGuideCompleted,
    String? subscriptionStatus,
    bool? hasAnyStateEntries,
    bool? hasAnyWorksheetEntries,
    String? countryCode,
    String? appVersion,
    String? platform,
  }) async {
    final props = <String, dynamic>{
      // base
      'platform': platform ?? _platformString(),
      'app_version': appVersion ?? (await _safeGetAppVersionString()),
      'language': _normalizeLanguage(languageCode ?? ui.PlatformDispatcher.instance.locale.languageCode),
      'country': _normalizeCountry(countryCode ?? _countryCodeOrNull()),

      // flags
      if (notificationsEnabled != null) 'notifications_enabled': notificationsEnabled,
      if (onboardingCompleted != null) 'onboarding_completed': onboardingCompleted,
      if (usageGuideCompleted != null) 'usage_guide_completed': usageGuideCompleted,
      if (subscriptionStatus != null) 'subscription_status': subscriptionStatus,
      if (hasAnyStateEntries != null) 'has_any_state_entries': hasAnyStateEntries,
      if (hasAnyWorksheetEntries != null) 'has_any_worksheet_entries': hasAnyWorksheetEntries,
    };

    // Удаляем null, чтобы не отправлять мусор
    props.removeWhere((_, v) => v == null);

    await setUserProperties(props);
  }

  /// Точечные хелперы (удобно дергать из UI/сервисов)
  Future<void> setLanguage(String languageCode) async {
    await setUserProperties({'language': _normalizeLanguage(languageCode)});
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await setUserProperties({'notifications_enabled': enabled});
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await setUserProperties({'onboarding_completed': completed});
  }

  Future<void> setUsageGuideCompleted(bool completed) async {
    await setUserProperties({'usage_guide_completed': completed});
  }

  Future<void> setSubscriptionStatus(String status) async {
    await setUserProperties({'subscription_status': status});
  }

  Future<void> setHasAnyStateEntries(bool hasAny) async {
    await setUserProperties({'has_any_state_entries': hasAny});
  }

  Future<void> setHasAnyWorksheetEntries(bool hasAny) async {
    await setUserProperties({'has_any_worksheet_entries': hasAny});
  }

  Future<void> setCountry(String? countryCode) async {
    await setUserProperties({'country': _normalizeCountry(countryCode)});
  }

  // -------------------------
  // Helpers
  // -------------------------

  String _platformString() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  /// Нормализуем язык в формат ru/en/other.
  String _normalizeLanguage(String? languageCode) {
    final code = (languageCode ?? '').toLowerCase();
    if (code == 'ru') return 'ru';
    if (code == 'en') return 'en';
    return 'other';
  }

  String? _countryCodeOrNull() {
    try {
      final c = ui.PlatformDispatcher.instance.locale.countryCode;
      return (c == null || c.isEmpty) ? null : c;
    } catch (_) {
      return null;
    }
  }

  String? _normalizeCountry(String? countryCode) {
    if (countryCode == null) return null;
    final c = countryCode.trim();
    if (c.isEmpty) return null;
    // обычно ISO alpha-2 приходит уже в верхнем регистре, но на всякий случай:
    return c.toUpperCase();
  }

  /// Версия приложения в формате `1.0.0 (3)`.
  Future<String?> _safeGetAppVersionString() async {
    if (kIsWeb) return null;
    try {
      final info = await PackageInfo.fromPlatform();
      final v = info.version;
      final b = info.buildNumber;
      if (v.isEmpty) return null;
      if (b.isEmpty) return v;
      return '$v ($b)';
    } catch (e) {
      debugPrint('[AmplitudeService] Failed to read app version: $e');
      return null;
    }
  }

  /// Установить/сменить userId (когда появится авторизация).
  Future<void> setUserId(String? userId) async {
    final amplitude = _ensureInstance();
    if (amplitude == null) return;
    if (userId == null || userId.length < 5) {
      debugPrint('[AmplitudeService] userId is null or too short, skip setUserId');
      return;
    }

    amplitude.setUserId(userId);
  }

  /// Базовый метод логирования события.
  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    final amplitude = _ensureInstance();
    if (amplitude == null) return;

    try {
      // В твоей версии SDK конструктор BaseEvent ожидает 1 позиционный аргумент
      // (eventType), eventProperties — именованный параметр.
      amplitude.track(
        BaseEvent(
          eventName,
          eventProperties: properties,
        ),
      );
    } catch (e, stack) {
      debugPrint('[AmplitudeService] Error logging event "$eventName": $e');
      debugPrint(stack.toString());
    }
  }

  // =========================
  // Convenience methods (events)
  // =========================

  // App lifecycle

  Future<void> logAppOpened({String source = 'unknown'}) async {
    await logEvent(
      'app_opened',
      properties: {
        'source': source,
      },
    );
  }

  // Onboarding

  Future<void> logOnboardingStarted() async {
    await logEvent('onboarding_started');
  }

  Future<void> logOnboardingCompleted() async {
    await logEvent('onboarding_completed');
  }

  Future<void> logOnboardingSkipped({int? stepsTotal}) async {
    await logEvent(
      'onboarding_skipped',
      properties: stepsTotal != null
          ? {
              'steps_total': stepsTotal,
            }
          : null,
    );
  }

  // Home screen guide (hs_ = home screen)

  Future<void> logHomeGuideOpened() async {
    await logEvent('hs_guide_opened');
  }

  Future<void> logHomeGuideStepViewed({required int stepIndex}) async {
    await logEvent(
      'hs_guide_step_viewed',
      properties: {
        'step_index': stepIndex,
      },
    );
  }

  Future<void> logHomeGuideCompleted() async {
    await logEvent('hs_guide_completed');
  }

  // Home / State entries

  Future<void> logHomeScreenOpened() async {
    await logEvent('home_screen');
  }

  Future<void> logNewStateFormOpened() async {
    await logEvent('new_state_form');
  }

  Future<void> logEditStateFormOpened() async {
    await logEvent('edit_state_form');
  }

  Future<void> logDeleteStateEntry() async {
    await logEvent('delete_state_entry');
  }

  Future<void> logDeleteStateEntryConfirmed() async {
    await logEvent('delete_state_entry_confirmed');
  }

  /// Имя события исправлено на `state_entry_created`.
  Future<void> logStateEntryCreated() async {
    await logEvent('state_entry_created');
  }

  Future<void> logStateEntryEdited() async {
    await logEvent('state_entry_edited');
  }

  Future<void> logStateEntryDetailsViewed() async {
    await logEvent('state_entry_details');
  }

  Future<void> logStatesShare({required String period}) async {
    await logEvent(
      'states_share',
      properties: {
        'period': period, // week, all
      },
    );
  }

  // Worksheets (Упражнения)

  Future<void> logWorksheetsScreenOpened() async {
    await logEvent('worksheets_screen');
  }

  Future<void> logWorksheetHistoryOpened({required String worksheet}) async {
    await logEvent(
      'worksheet_history',
      properties: {
        'worksheet': worksheet,
      },
    );
  }

  Future<void> logNewWorksheetFormOpened({required String worksheet}) async {
    await logEvent(
      'new_worksheet_form',
      properties: {
        'worksheet': worksheet,
      },
    );
  }

  Future<void> logEditWorksheetFormOpened({required String worksheet}) async {
    await logEvent(
      'edit_worksheet_form',
      properties: {
        'worksheet': worksheet,
      },
    );
  }

  Future<void> logDeleteWorksheet({required String worksheet}) async {
    await logEvent(
      'delete_worksheet',
      properties: {
        'worksheet': worksheet,
      },
    );
  }

  Future<void> logDeleteWorksheetConfirmed({required String worksheet}) async {
    await logEvent(
      'delete_worksheet_confirmed',
      properties: {
        'worksheet': worksheet,
      },
    );
  }

  Future<void> logWorksheetCreated({required String worksheet}) async {
    await logEvent(
      'worksheet_created',
      properties: {
        'worksheet': worksheet,
      },
    );
  }

  Future<void> logWorksheetEdited({required String worksheet}) async {
    await logEvent(
      'worksheet_edited',
      properties: {
        'worksheet': worksheet,
      },
    );
  }

  // Meditations

  Future<void> logMeditationsScreenOpened() async {
    await logEvent('meditations_screen');
  }

  Future<void> logMeditationViewed({required String meditation}) async {
    await logEvent(
      'meditation_viewed',
      properties: {
        'meditation': meditation,
      },
    );
  }

  Future<void> logMeditationWithVoice({required String meditation}) async {
    await logEvent(
      'meditation_with_voice',
      properties: {
        'meditation': meditation,
      },
    );
  }

  Future<void> logMeditationBackground({required String meditation}) async {
    await logEvent(
      'meditation_background',
      properties: {
        'meditation': meditation,
      },
    );
  }

  // DBT Skills

  Future<void> logSkillsCategoriesScreenOpened() async {
    await logEvent('skills_categories_screen');
  }

  Future<void> logSkillListOpened({required String category}) async {
    await logEvent(
      'skill_list',
      properties: {
        'category': category,
      },
    );
  }

  Future<void> logSkillOverviewOpened({
    required String category,
    required String skill,
  }) async {
    await logEvent(
      'skill_overview',
      properties: {
        'category': category,
        'skill': skill,
      },
    );
  }

  Future<void> logSkillFullDescriptionOpened({
    required String category,
    required String skill,
  }) async {
    await logEvent(
      'skill_full_description',
      properties: {
        'category': category,
        'skill': skill,
      },
    );
  }

  Future<void> logSkillPractice({
    required String category,
    required String skill,
  }) async {
    await logEvent(
      'skill_practice',
      properties: {
        'category': category,
        'skill': skill,
      },
    );
  }

  // Settings

  Future<void> logSettingsOpened() async {
    await logEvent('settings');
  }

  Future<void> logNotificationsToggled({required String state}) async {
    await logEvent(
      'notifications',
      properties: {
        'state': state, // on, off
      },
    );
  }

  Future<void> logSettingsGuideOpened() async {
    await logEvent('s_guide_opened');
  }

  Future<void> logSettingsGuideCompleted() async {
    await logEvent('s_guide_completed');
  }

  Future<void> logFeedbackEmailOpened() async {
    await logEvent('feedback_email');
  }

  Future<void> logAboutAppOpened() async {
    await logEvent('about_app');
  }

  /// Вспомогательный метод, чтобы не падать, если вдруг забыли init().
  Amplitude? _ensureInstance() {
    if (!_initialized || _amplitude == null) {
      debugPrint(
        '[AmplitudeService] Called before initialization. '
        'Make sure to call AmplitudeService.instance.init() in main().',
      );
      return null;
    }
    return _amplitude;
  }
}