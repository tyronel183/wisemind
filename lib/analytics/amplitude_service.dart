import 'package:flutter/foundation.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';

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

    // Устанавливаем стартовые user properties (например, platform, app_version и др.)
    if (appVersion != null || (initialUserProperties != null && initialUserProperties.isNotEmpty)) {
      final identify = Identify();

      if (appVersion != null) {
        identify.set('app_version', appVersion);
      }

      if (initialUserProperties != null && initialUserProperties.isNotEmpty) {
        initialUserProperties.forEach((key, value) {
          identify.set(key, value);
        });
      }

      amplitude.identify(identify);
    }

    _amplitude = amplitude;
    _initialized = true;

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