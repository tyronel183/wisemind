// lib/settings/settings_webview_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingsWebViewScreen extends StatelessWidget {
  final String title;
  final String url;

  const SettingsWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}