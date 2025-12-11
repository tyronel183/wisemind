// lib/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../notifications/notification_service.dart';
import 'about_screen.dart';
import '../usage_guide/usage_guide_screen.dart';
import '../analytics/amplitude_service.dart';
import '../debug/ui_kit_screen.dart';
import '../theme/app_card_tile.dart';
import '../theme/app_spacing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeService.instance.logSettingsOpened();
    });
  }

  Future<void> _onReminderToggle(bool value) async {
    setState(() {
      _remindersEnabled = value;
    });

    // Логируем переключение напоминаний
    AmplitudeService.instance
        .logNotificationsToggled(state: value ? 'on' : 'off');

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
  AmplitudeService.instance.logFeedbackEmailOpened();

  final uri = Uri(
    scheme: 'mailto',
    path: 'dbtenthusiast@gmail.com',
    queryParameters: {
      'subject': 'Обратная связь по приложению Wisemind',
    },
  );

  try {
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть почтовое приложение'),
        ),
      );
    }
  } catch (_) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть почтовое приложение'),
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.gapMedium,
        ),
        children: [
          // Напоминания
          SwitchListTile(
            title: const Text('Напоминания о «Карте дня»'),
            subtitle: const Text('Вечером напомнить заполнить карту дня'),
            value: _remindersEnabled,
            onChanged: _onReminderToggle,
          ),

          // Как пользоваться приложением
          AppCardTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: 'Как пользоваться приложением',
            subtitle: 'Краткий гид по Wisemind',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AmplitudeService.instance.logSettingsGuideOpened();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => UsageGuideScreen(
                    onCompleted: () {
                      AmplitudeService.instance.logSettingsGuideCompleted();
                    },
                  ),
                ),
              );
            },
          ),

          // Написать нам
          AppCardTile(
            leading: const Icon(Icons.mail_outline),
            title: 'Написать нам',
            subtitle: 'Почта для вопросов и предложений',
            trailing: const Icon(Icons.chevron_right),
            onTap: _launchMail,
          ),

          // О приложении
          AppCardTile(
            leading: const Icon(Icons.info_outline),
            title: 'О приложении',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AmplitudeService.instance.logAboutAppOpened();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),

          /*
          // UI Kit (debug)
          AppCardTile(
            leading: const Icon(Icons.palette_outlined),
            title: 'UI Kit (debug)',
            subtitle: 'Экран дизайн-системы',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const UiKitScreen(),
                ),
              );
            },
          ),
          */
        ],
      ),
    );
  }
}