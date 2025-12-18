import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../l10n/app_localizations.dart';

class WisemindPaywallScreen extends StatefulWidget {
  const WisemindPaywallScreen({super.key});

  @override
  State<WisemindPaywallScreen> createState() => _WisemindPaywallScreenState();
}

class _WisemindPaywallScreenState extends State<WisemindPaywallScreen> {
  Offering? _offering;
  Object? _error;
  bool _loading = true;

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

  /// RevenueCat UI locale должен быть language_COUNTRY с подчёркиванием.
  /// Примеры: ru_RU, en_US
  String _toRevenueCatUiLocale(ui.Locale locale) {
    final lang = locale.languageCode.toLowerCase();
    return (lang == 'ru') ? 'ru_RU' : 'en_US';
  }

  Future<void> _loadOfferingForCurrentLocale() async {
    setState(() {
      _loading = true;
      _error = null;
      _offering = null;
    });

    final appLocaleObj = Localizations.localeOf(context);
    final appLocale = appLocaleObj.toLanguageTag(); // ru / ru-RU
    final systemLocale = ui.PlatformDispatcher.instance.locale.toLanguageTag(); // en-US
    final rcLocale = _toRevenueCatUiLocale(appLocaleObj); // ru_RU / en_US

    try {
      // КРИТИЧНО: выставляем локаль ДО получения offerings и до построения PaywallView.
      await Purchases.overridePreferredUILocale(rcLocale);

      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (kDebugMode) {
        final packages = offering?.availablePackages
            .map((p) => p.identifier)
            .toList(growable: false);

        debugPrint(
          '[Paywall] appLocale=$appLocale systemLocale=$systemLocale rcLocale=$rcLocale '
          'offeringId=${offering?.identifier} packages=$packages',
        );
      }

      if (offering == null) {
        throw StateError('No current offering configured in RevenueCat.');
      }

      if (!mounted) return;
      setState(() {
        _offering = offering;
        _loading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Paywall] loadOffering failed: $e');
      }
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  String _paywallTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.paywall_title ?? 'Wisemind Pro';
  }

  String _openFailed(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.paywall_open_failed ?? 'Couldn’t open the subscription screen.';
  }

  String _retry(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.paywall_retry ?? 'Try again';
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