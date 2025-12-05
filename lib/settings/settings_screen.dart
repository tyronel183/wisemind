// lib/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../notifications/notification_service.dart';
import 'about_screen.dart';
import '../usage_guide/usage_guide_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = true; // TODO: потом подружить с реальным хранилищем

  @override
  void initState() {
    super.initState();
    // TODO: сюда можно будет подтянуть состояние из Hive/SettingsRepository
  }

  Future<void> _onReminderToggle(bool value) async {
    setState(() {
      _remindersEnabled = value;
    });

    // Здесь управляем пушами карты дня
    if (value) {
      await NotificationService.instance.scheduleDailyStateReminder(
        const TimeOfDay(hour: 20, minute: 0),
      );
    } else {
      await NotificationService.instance.cancelDailyStateReminder();
    }
  }

  Future<void> _launchMail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'dbtenthusiast@gmail.com',
      query: Uri.encodeQueryComponent('subject=Обратная связь по приложению Wisemind'),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Напоминания
          SwitchListTile(
            title: const Text('Напоминания о «Карте дня»'),
            subtitle: const Text('Вечером напомнить заполнить карту дня'),
            value: _remindersEnabled,
            onChanged: _onReminderToggle,
          ),

          const Divider(),

          // Как пользоваться приложением
          ListTile(
            title: const Text('Как пользоваться приложением'),
            subtitle: const Text('Краткий гид по Wisemind'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UsageGuideScreen(),
                ),
              );
            },
          ),

          // Написать нам
          ListTile(
            title: const Text('Написать нам'),
            subtitle: const Text('Почта для вопросов и предложений'),
            onTap: _launchMail,
          ),

          const Divider(),

          // О приложении
          ListTile(
            title: const Text('О приложении'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}