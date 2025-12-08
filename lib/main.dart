import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 🆕 Billing Service
import 'billing/billing_service.dart';

import 'state/state_repository.dart';
import 'home/home_screen.dart';
import 'meditations/meditation_screens.dart';
import 'worksheets/worksheets_root_screen.dart';
import 'worksheets/pros_cons.dart';
import 'skills/skills_screens.dart';
import 'state/state_entry.dart';
import 'worksheets/chain_analysis.dart';
import 'worksheets/fact_check.dart';
import 'notifications/notification_service.dart';
import 'navigation/app_navigator.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        navigationBarTheme: const NavigationBarThemeData(height: 64),
      ),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Состояние',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Упражнения',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: 'Медитации',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_alt_outlined),
            selectedIcon: Icon(Icons.psychology_alt),
            label: 'Навыки DBT',
          ),
        ],
      ),
    );
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
