// lib/settings/about_screen.dart
import 'package:flutter/material.dart';

import 'settings_webview_screen.dart';
import '../theme/app_card_tile.dart';
import '../theme/app_spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const privacyUrl =
        'https://tyronel183.github.io/wisemind-legal/privacy-policy.html';
    const personalDataUrl =
        'https://tyronel183.github.io/wisemind-legal/personal-data-policy.html';

    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.gapMedium,
        ),
        child: Column(
          children: [
            // Основной контент — карточки с политиками
            Expanded(
              child: ListView(
                children: [
                  AppCardTile(
                    title: 'Политика конфиденциальности',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsWebViewScreen(
                            title: 'Политика конфиденциальности',
                            url: privacyUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.gapMedium),
                  AppCardTile(
                    title: 'Политика обработки персональных данных',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsWebViewScreen(
                            title: 'Политика обработки персональных данных',
                            url: personalDataUrl,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.gapLarge),
            // Версия приложения — по центру внизу экрана
            Builder(
              builder: (context) {
                final baseStyle = Theme.of(context).textTheme.bodySmall;
                final style = baseStyle?.copyWith(
                      color: baseStyle.color?.withValues(alpha: 0.7),
                    ) ??
                    const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    );
                return Text(
                  'Версия 1.0.0',
                  textAlign: TextAlign.center,
                  style: style,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}