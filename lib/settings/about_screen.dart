// lib/settings/about_screen.dart
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import 'settings_webview_screen.dart';
import '../theme/app_card_tile.dart';
import '../theme/app_spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final privacyUrl = l10n.aboutPrivacyPolicyUrl;
    final personalDataUrl = l10n.aboutPersonalDataPolicyUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutAppBarTitle),
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
                    title: l10n.aboutPrivacyPolicyTitle,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsWebViewScreen(
                            title: l10n.aboutPrivacyPolicyTitle,
                            url: privacyUrl,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.gapMedium),
                  AppCardTile(
                    title: l10n.aboutPersonalDataPolicyTitle,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsWebViewScreen(
                            title: l10n.aboutPersonalDataPolicyTitle,
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
                  l10n.aboutAppVersionLabel('1.0.0'),
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