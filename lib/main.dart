import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';

import 'analytics/amplitude_service.dart';

// 🆕 Billing Service
import 'billing/billing_service.dart';

import 'state/state_repository.dart';
import 'home/home_screen.dart';
import 'meditations/meditation_screens.dart';
import 'worksheets/worksheets_root_screen.dart';
import 'worksheets/pros_cons.dart';
import 'skills/skills_screens.dart';
import 'state/state_entry.dart';
import 'state/entry_form_screen.dart';
import 'worksheets/chain_analysis.dart';
import 'worksheets/fact_check.dart';
import 'notifications/notification_service.dart';
import 'navigation/app_navigator.dart';
import 'theme/app_theme.dart';
import 'onboarding/onboarding_screen.dart';

// Подключение локализации
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Версия приложения из package_info_plus
  final packageInfo = await PackageInfo.fromPlatform();
  final String appVersion = packageInfo.version;
  final String buildNumber = packageInfo.buildNumber;
  final String appVersionFull = '$appVersion ($buildNumber)';

  // Для Amplitude: нормализуем язык до ru/en/other
  String normalizeLanguage(String code) {
    final c = code.toLowerCase();
    if (c == 'ru') return 'ru';
    if (c == 'en') return 'en';
    return 'other';
  }

  await BillingService.init();

  // Инициализация Hive
  await Hive.initFlutter();

  // Регистрация адаптеров Hive
  Hive.registerAdapter(StateEntryAdapter());
  Hive.registerAdapter(ChainAnalysisEntryAdapter());
  Hive.registerAdapter(FactCheckEntryAdapter());
  Hive.registerAdapter(ProsConsEntryAdapter());

  // Открываем боксы рабочих листов
  await Hive.openBox<ProsConsEntry>(kProsConsBoxName);

  // Открываем бокс с дневниками состояний
  final Box box = await Hive.openBox('state_entries_box');

  // Открываем бокс настроек приложения
  final Box settingsBox = await Hive.openBox('app_settings');
  final bool hasCompletedOnboarding =
      settingsBox.get('hasCompletedOnboarding', defaultValue: false) as bool;

  final String? savedLocaleCode =
      settingsBox.get('app_locale', defaultValue: null) as String?;
  final Locale? initialLocale = (savedLocaleCode == null || savedLocaleCode.isEmpty)
      ? null
      : Locale(savedLocaleCode);

  // Эффективная локаль приложения: сохранённая (если есть) иначе системная.
  final Locale effectiveLocale =
      initialLocale ?? WidgetsBinding.instance.platformDispatcher.locale;
  final String language = normalizeLanguage(effectiveLocale.languageCode);
  final String? country = effectiveLocale.countryCode;

  // Инициализация Amplitude с базовыми user properties
  await AmplitudeService.instance.init(
    apiKey: '184d3ba87a05255179cc9df84f22236b',
    appVersion: appVersion,
    initialUserProperties: {
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'app_version': appVersionFull,
      'language': language,
      'notifications_enabled': false, // будет обновляться из настроек
      'onboarding_completed': hasCompletedOnboarding,
      'usage_guide_completed': false,
      'subscription_status': 'free',
      'has_any_state_entries': box.isNotEmpty,
      'has_any_worksheet_entries':
          Hive.box<ProsConsEntry>(kProsConsBoxName).isNotEmpty,
      'country': country,
    },
  );

  // Базовое событие запуска приложения
  await AmplitudeService.instance.logEvent(
    'app_opened',
    properties: {
      'source': 'unknown',
    },
  );

  // Репозиторий для дневников состояний
  final StateRepository repository = StateRepository(box);

  runApp(
    WisemindApp(
      repository: repository,
      hasCompletedOnboarding: hasCompletedOnboarding,
      initialLocale: initialLocale,
    ),
  );
}

class WisemindApp extends StatefulWidget {
  final StateRepository repository;
  final bool hasCompletedOnboarding;
  final Locale? initialLocale;

  const WisemindApp({
    super.key,
    required this.repository,
    required this.hasCompletedOnboarding,
    this.initialLocale,
  });

  @override
  State<WisemindApp> createState() => _WisemindAppState();
}

class _WisemindAppState extends State<WisemindApp> {
  late final ValueNotifier<Locale?> _localeNotifier;

  @override
  void initState() {
    super.initState();
    _localeNotifier = ValueNotifier<Locale?>(widget.initialLocale);
  }

  @override
  void dispose() {
    _localeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      localeNotifier: _localeNotifier,
      child: ValueListenableBuilder<Locale?>(
        valueListenable: _localeNotifier,
        builder: (context, locale, _) {
          return MaterialApp(
            navigatorKey: appNavigatorKey,
            title: 'Wisemind',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            routes: {
              '/': (context) => WisemindRoot(
                    repository: widget.repository,
                    hasCompletedOnboarding: widget.hasCompletedOnboarding,
                  ),
            },
          );
        },
      ),
    );
  }
}

/// Глобальный scope для ручного переключения языка приложения.
///
/// Как использовать из любого экрана (например, Settings):
///   await AppLocaleScope.setLocale(context, const Locale('ru'));
///   await AppLocaleScope.setLocale(context, const Locale('en'));
///   await AppLocaleScope.setLocale(context, null); // вернуть системный язык
class AppLocaleScope extends InheritedWidget {
  final ValueNotifier<Locale?> localeNotifier;

  const AppLocaleScope({
    super.key,
    required this.localeNotifier,
    required super.child,
  });

  static ValueNotifier<Locale?> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found in widget tree');
    return scope!.localeNotifier;
  }

  /// Установить язык и сохранить выбор в Hive (`app_settings` -> `app_locale`).
  ///
  /// locale == null: использовать системный язык.
  static Future<void> setLocale(BuildContext context, Locale? locale) async {
    final settingsBox = Hive.box('app_settings');
    final notifier = AppLocaleScope.of(context);

    if (locale == null) {
      await settingsBox.delete('app_locale');
      notifier.value = null;
      return;
    }

    await settingsBox.put('app_locale', locale.languageCode);
    notifier.value = locale;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return oldWidget.localeNotifier != localeNotifier;
  }
}

class WisemindRoot extends StatefulWidget {
  const WisemindRoot({
    super.key,
    required this.repository,
    required this.hasCompletedOnboarding,
  });

  final StateRepository repository;
  final bool hasCompletedOnboarding;

  @override
  State<WisemindRoot> createState() => _WisemindRootState();
}

class _WisemindRootState extends State<WisemindRoot> {
  late bool _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _hasCompletedOnboarding = widget.hasCompletedOnboarding;
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      await NotificationService.instance.init();
      await NotificationService.instance.scheduleDailyStateReminder(
        const TimeOfDay(hour: 20, minute: 0),
      );
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<void> _handleOnboardingFinished() async {
    final settingsBox = Hive.box('app_settings');
    await settingsBox.put('hasCompletedOnboarding', true);
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCompletedOnboarding) {
      return OnboardingScreen(
        onFinished: _handleOnboardingFinished,
      );
    }

    return MainScaffold(repository: widget.repository);
  }
}

class MainScaffold extends StatefulWidget {
  final StateRepository repository;

  const MainScaffold({super.key, required this.repository});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _onNewEntryPressed,
              icon: const Icon(Icons.add),
              label: Text(l10n.mainFabNewEntry),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_border),
            activeIcon: const Icon(Icons.favorite),
            label: l10n.mainNavState,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article_outlined),
            activeIcon: const Icon(Icons.article),
            label: l10n.mainNavWorksheets,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.self_improvement_outlined),
            activeIcon: const Icon(Icons.self_improvement),
            label: l10n.mainNavMeditations,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: l10n.mainNavSkills,
          ),
        ],
      ),
    );
  }

  Future<void> _onNewEntryPressed() async {
    final newEntry = await Navigator.of(context).push<StateEntry>(
      MaterialPageRoute(
        builder: (context) => const EntryFormScreen(),
      ),
    );

    if (!mounted) return;

    if (newEntry != null) {
      // кладём запись в тот же бокс, который слушает HomeScreen
      await widget.repository.box.put(newEntry.id, newEntry);
      await AmplitudeService.instance.logEvent(
        'state_entry_created',
        properties: {
          'date': newEntry.date.toIso8601String(),
          'has_goal': newEntry.importantGoal != null,
          'has_skills': newEntry.skillsUsed.isNotEmpty,
        },
      );
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(repository: widget.repository);
      case 1:
        return const WorksheetsRootScreen();
      case 2:
        return const MeditationsScreen();
      case 3:
        return const SkillsRootScreen();
      default:
        return HomeScreen(repository: widget.repository);
    }
  }
}