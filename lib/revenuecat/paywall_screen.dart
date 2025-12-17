import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../l10n/app_localizations.dart';

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

  // Временный фолбэк для локализации: если ARB-ключи ещё не сгенерились
  // в AppLocalizations, берём дефолтные строки по языку устройства.
  bool _isRu(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase() == 'ru';
  }

  String _paywallTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      try {
        final dynamic d = l10n;
        final v = d.paywallTitle;
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
    }
    return 'Wisemind Pro';
  }

  String _paywallOpening(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      try {
        final dynamic d = l10n;
        final v = d.paywallOpening;
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
    }
    return _isRu(context) ? 'Открываю экран подписки…' : 'Opening the subscription screen…';
  }

  String _paywallOpenFailed(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      try {
        final dynamic d = l10n;
        final v = d.paywallOpenFailed;
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
    }
    return _isRu(context)
        ? 'Не удалось открыть экран подписки.'
        : 'Couldn’t open the subscription screen.';
  }

  String _paywallRetry(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      try {
        final dynamic d = l10n;
        final v = d.paywallRetry;
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
    }
    return _isRu(context) ? 'Попробовать ещё раз' : 'Try again';
  }

  String _paywallOpenFailedWithError(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      try {
        final dynamic d = l10n;
        final v = d.paywallOpenFailedWithError(error);
        if (v is String && v.isNotEmpty) return v;
      } catch (_) {}
    }
    return _isRu(context)
        ? 'Не удалось открыть экран подписки: $error'
        : 'Couldn’t open the subscription screen: $error';
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

      // Если пользователь купил/закрыл paywall — просто возвращаемся назад.
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hadError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_paywallOpenFailedWithError(context, e.toString())),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isPresenting ? null : () => Navigator.of(context).maybePop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(_paywallTitle(context)),
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
                        ? _paywallOpenFailed(context)
                        : _paywallOpening(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showPaywall,
                    child: Text(_paywallRetry(context)),
                  ),
                ],
              ),
      ),
    );
  }
}