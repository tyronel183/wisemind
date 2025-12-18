// lib/settings/settings_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../notifications/notification_service.dart';
import 'about_screen.dart';
import '../usage_guide/usage_guide_screen.dart';
import '../analytics/amplitude_service.dart';
// import '../debug/ui_kit_screen.dart';  // Removed as per instructions
import '../theme/app_card_tile.dart';
import '../theme/app_spacing.dart';
import '../main.dart' show AppLocaleScope;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = true;

  Locale? _selectedLocale;

  String _normLang(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (code == 'ru') return 'ru';
    if (code == 'en') return 'en';
    return 'other';
  }

  String _localeLabel(Locale? selectedLocale, Locale currentLocale) {
    final effectiveCode = selectedLocale?.languageCode ??
        (currentLocale.languageCode == 'ru' ? 'ru' : 'en');
    if (effectiveCode == 'ru') return 'Русский';
    return 'English';
  }

  Future<void> _pickLanguage() async {
    final currentLocale = Localizations.localeOf(context);
    final from = _normLang(currentLocale);

    final chosen = await showModalBottomSheet<Locale>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final effectiveCode = _selectedLocale?.languageCode ??
            (currentLocale.languageCode == 'ru' ? 'ru' : 'en');
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Русский'),
                trailing: effectiveCode == 'ru' ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(const Locale('ru')),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('English'),
                trailing: effectiveCode == 'en' ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(const Locale('en')),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    // Если пользователь закрыл выбор (null) — ничего не меняем.
    if (chosen == null) return;

    final to = _normLang(chosen);

    // Если язык не изменился — ничего не делаем и не логируем.
    if (to == from) {
      setState(() {
        _selectedLocale = chosen;
      });
      return;
    }

    setState(() {
      _selectedLocale = chosen;
    });

    // Применяем локаль через scope (см. main.dart).
    await AppLocaleScope.setLocale(context, chosen);

    // Обновляем user property (фактическая смена языка).
    await AmplitudeService.instance.setUserProperties({'language': to});

    // Логируем фактическую смену языка.
    AmplitudeService.instance.logEvent(
      'language_change',
      properties: {'to': to},
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeService.instance.logSettingsOpened();
    });
  }

  Future<void> _onReminderToggle(bool value) async {
    // Оптимистично обновляем UI.
    setState(() {
      _remindersEnabled = value;
    });

    // Логируем переключение напоминаний
    AmplitudeService.instance.logNotificationsToggled(state: value ? 'on' : 'off');

    try {
      // Здесь управляем пушами карты дня
      if (value) {
        await NotificationService.instance.scheduleDailyStateReminder(
          const TimeOfDay(hour: 20, minute: 0),
        );
      } else {
        await NotificationService.instance.cancelDailyStateReminder();
      }

      // Обновляем user property только после фактического успеха.
      await AmplitudeService.instance.setUserProperties({
        'notifications_enabled': value,
      });
    } catch (_) {
      if (!mounted) return;

      // Откатываем свитч, если не получилось применить настройку.
      setState(() {
        _remindersEnabled = !value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Не удалось включить уведомления'
                : 'Не удалось отключить уведомления',
          ),
        ),
      );
    }
  }

  Future<void> _launchMail() async {
    final l10n = AppLocalizations.of(context)!;
    AmplitudeService.instance.logFeedbackEmailOpened();

    final uri = Uri(
      scheme: 'mailto',
      path: 'dbtenthusiast@gmail.com',
      queryParameters: {
        'subject': l10n.settingsFeedbackEmailSubject,
      },
    );

    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsMailError),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsMailError),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAppBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.gapMedium,
        ),
        children: [
          // Напоминания
          SwitchListTile(
            title: Text(l10n.settingsReminderTitle),
            subtitle: Text(l10n.settingsReminderSubtitle),
            value: _remindersEnabled,
            onChanged: _onReminderToggle,
          ),

          // Язык приложения
          AppCardTile(
            leading: const Icon(Icons.language_outlined),
            title: currentLocale.languageCode == 'ru' ? 'Язык' : 'Language',
            subtitle: _localeLabel(_selectedLocale, currentLocale),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickLanguage,
          ),

          // Как пользоваться приложением
          AppCardTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: l10n.settingsGuideTitle,
            subtitle: l10n.settingsGuideSubtitle,
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
            title: l10n.settingsContactTitle,
            subtitle: l10n.settingsContactSubtitle,
            trailing: const Icon(Icons.chevron_right),
            onTap: _launchMail,
          ),

          // О приложении
          AppCardTile(
            leading: const Icon(Icons.info_outline),
            title: l10n.settingsAboutTitle,
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

          // UI Kit (debug)
//          AppCardTile(
//            leading: const Icon(Icons.palette_outlined),
//            title: 'UI Kit (debug)',
//            subtitle: 'Экран дизайн-системы',
//            trailing: const Icon(Icons.chevron_right),
//            onTap: () {
//              Navigator.of(context).push(
//                MaterialPageRoute(
//                  builder: (_) => const UiKitScreen(),
//                ),
//              );
//            },
//          ),
        ],
      ),
    );
  }
}