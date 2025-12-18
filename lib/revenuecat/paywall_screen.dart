import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../l10n/app_localizations.dart';

/// Экран-обёртка вокруг paywall от RevenueCat.
///
/// Важно: НЕ используем `RevenueCatUI.presentPaywall()` — это нативная модалка.
/// Мы встраиваем paywall как Flutter-виджет (`PaywallView`) внутрь нашего экрана:
/// - есть стабильная кнопка «назад» (AppBar)
/// - локаль контролируем сами (через overridePreferredUILocale)
class WisemindPaywallScreen extends StatefulWidget {
  const WisemindPaywallScreen({super.key});

  @override
  State<WisemindPaywallScreen> createState() => _WisemindPaywallScreenState();
}

class _WisemindPaywallScreenState extends State<WisemindPaywallScreen> {
  Offering? _offering;
  Object? _error;
  bool _loading = true;

  // Чтобы реально перезагружать offering при смене языка.
  String? _lastLocaleTag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final localeTag = Localizations.localeOf(context).toLanguageTag();
    if (_lastLocaleTag == null || _lastLocaleTag != localeTag) {
      _lastLocaleTag = localeTag;
      _loadOfferingForCurrentLocale();
    }
  }

  Future<void> _loadOfferingForCurrentLocale() async {
    setState(() {
      _loading = true;
      _error = null;
      _offering = null;
    });

    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode.toLowerCase();
    final rcLocale = (lang == 'ru') ? 'ru' : 'en';

    try {
      // КРИТИЧНО: выставляем локаль ДО получения offerings
      await Purchases.overridePreferredUILocale(rcLocale);

      if (kDebugMode) {
        debugPrint('[Paywall] locale=${locale.toLanguageTag()} rcLocale=$rcLocale');
      }

      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null) {
        throw StateError('No current offering configured in RevenueCat.');
      }

      if (!mounted) return;
      setState(() {
        _offering = offering;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  String _paywallTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      return l10n.paywall_title;
    }
    return 'Wisemind Pro';
  }

  String _openFailed(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      return l10n.paywall_open_failed;
    }
    return 'Couldn’t open the subscription screen.';
  }

  String _retry(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      return l10n.paywall_retry;
    }
    return 'Try again';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        title: Text(_paywallTitle(context)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_openFailed(context), textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          Text(_error.toString(), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadOfferingForCurrentLocale,
                            child: Text(_retry(context)),
                          ),
                        ],
                      ),
                    ),
                  )
                : (_offering == null)
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_openFailed(context), textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadOfferingForCurrentLocale,
                                child: Text(_retry(context)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : PaywallView(offering: _offering!),
      ),
    );
  }
}