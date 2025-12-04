import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 🆕 RevenueCat
import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenuecat/revenuecat_constants.dart';

import 'state/state_repository.dart';
import 'home/home_screen.dart';
import 'meditations/meditation_screens.dart';
import 'worksheets/worksheets_root_screen.dart';
import 'worksheets/pros_cons.dart';
import 'skills/skills_screens.dart';
import 'state/state_entry.dart';
import 'worksheets/chain_analysis.dart';
import 'worksheets/fact_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // 🆕 Инициализация RevenueCat
  try {
    final configuration = PurchasesConfiguration(
      RevenueCatConstants.apiKey,
    );

    // Можно оставить лог в debug-режиме, чтобы видеть, что происходит
    await Purchases.configure(configuration);
    await Purchases.setLogLevel(LogLevel.debug);
  } catch (e) {
    // Если RevenueCat вдруг упадёт — приложение продолжит работать
    debugPrint('Ошибка инициализации RevenueCat: $e');
  }

  // Репозиторий для дневников состояний
  final StateRepository repository = StateRepository(box);

  runApp(WisemindApp(repository: repository));
}

class WisemindApp extends StatelessWidget {
  final StateRepository repository;

  const WisemindApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisemind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        navigationBarTheme: const NavigationBarThemeData(
          height: 64,
        ),
      ),
      home: MainScaffold(repository: repository),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final StateRepository repository;

  const MainScaffold({
    super.key,
    required this.repository,
  });

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