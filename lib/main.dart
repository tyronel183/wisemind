import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform;

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
import 'theme/app_components.dart';

import 'onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Инициализация Amplitude с базовыми user properties
  await AmplitudeService.instance.init(
    apiKey: '184d3ba87a05255179cc9df84f22236b',
    appVersion: '1.0.0', // TODO: заменить на фактическую версию из package_info_plus
    initialUserProperties: {
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'language': 'ru', // TODO: можно подтянуть из локали
      'notifications_enabled': false, // будет обновляться из настроек
      'onboarding_completed': hasCompletedOnboarding,
      'usage_guide_completed': false,
      'subscription_status': 'free',
      'has_any_state_entries': box.isNotEmpty,
      'has_any_worksheet_entries': Hive.box<ProsConsEntry>(kProsConsBoxName).isNotEmpty,
      'country': null,
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
    ),
  );
}

class WisemindApp extends StatelessWidget {
  final StateRepository repository;
  final bool hasCompletedOnboarding;

  const WisemindApp({
    super.key,
    required this.repository,
    required this.hasCompletedOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'Wisemind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/': (context) => WisemindRoot(
              repository: repository,
              hasCompletedOnboarding: hasCompletedOnboarding,
            ),
      },
    );
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
    return Scaffold(
      body: _buildBody(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _onNewEntryPressed,
              icon: const Icon(Icons.add),
              label: const Text('Новая запись'),
            )
          : null,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // ВОТ ЭТОТ МЕТОД — ЕДИНСТВЕННОЕ ИЗМЕНЕНИЕ
  Future<void> _onNewEntryPressed() async {
    final newEntry = await Navigator.of(context).push<StateEntry>(
      MaterialPageRoute(
        builder: (context) => const EntryFormScreen(),
      ),
    );

    if (newEntry != null) {
      // кладём запись в тот же бокс, который слушает HomeScreen
      await widget.repository.box.put(newEntry.id, newEntry);
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