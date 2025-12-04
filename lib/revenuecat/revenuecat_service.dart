import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Экран-обёртка для показа нативного paywall от RevenueCat.
///
/// Использует RevenueCatUI.presentPaywall, который сам подтягивает
/// текущий offering и связанный с ним paywall, настроенный в Dashboard.
class WisemindPaywallScreen extends StatefulWidget {
  const WisemindPaywallScreen({super.key});

  @override
  State<WisemindPaywallScreen> createState() => _WisemindPaywallScreenState();
}

class _WisemindPaywallScreenState extends State<WisemindPaywallScreen> {
  bool _isPresenting = false;
  bool _hadError = false;

  @override
  void initState() {
    super.initState();
    _showPaywall();
  }

  Future<void> _showPaywall() async {
    setState(() {
      _isPresenting = true;
      _hadError = false;
    });

    try {
      // Показываем paywall. SDK сам подхватит актуальный offering
      // и связанный с ним paywall, если он настроен в RevenueCat.
      final result = await RevenueCatUI.presentPaywall();

      if (!mounted) return;

      // Можно передать result назад, если хочешь где-то его обработать.
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hadError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось открыть экран подписки: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPresenting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisemind Pro'),
        centerTitle: true,
      ),
      body: Center(
        child: _isPresenting
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _hadError
                        ? 'Не удалось открыть экран подписки.'
                        : 'Открываю экран подписки…',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showPaywall,
                    child: const Text('Попробовать ещё раз'),
                  ),
                ],
              ),
      ),
    );
  }
}