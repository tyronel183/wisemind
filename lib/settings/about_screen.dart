// lib/settings/about_screen.dart
import 'package:flutter/material.dart';

import 'settings_webview_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: вынести URL-ы в константы при желании
    const privacyUrl =
        'https://tyronel183.github.io/wisemind-legal/privacy-policy.html';
    const personalDataUrl =
        'https://tyronel183.github.io/wisemind-legal/personal-data-policy.html';

    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Политика конфиденциальности'),
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
          ListTile(
            title: const Text('Политика обработки персональных данных'),
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
          const Divider(),
          const ListTile(
            title: Text('Версия'),
            subtitle: Text('1.0.0'), // TODO: потом подтянуть из package_info_plus
          ),
          const ListTile(
            title: Text('Контакты'),
            subtitle: Text('dbtenthusiast@gmail.com'),
          ),
        ],
      ),
    );
  }
}