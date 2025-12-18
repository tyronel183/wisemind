import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../l10n/app_localizations.dart';
import 'dbt_faq_data.dart';
import '../analytics/amplitude_service.dart';

class DbtFaqScreen extends StatefulWidget {
  const DbtFaqScreen({super.key});

  @override
  State<DbtFaqScreen> createState() => _DbtFaqScreenState();
}

class _DbtFaqScreenState extends State<DbtFaqScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Screen opened
    AmplitudeService.instance.logEvent('about_dbt');
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final langFolder = localeCode.startsWith('ru') ? 'ru' : 'en';

    final imagePaths = <String>[
      'assets/images/dbt_faq/$langFolder/1_before.png',
      'assets/images/dbt_faq/$langFolder/2_getting_to_know.png',
      'assets/images/dbt_faq/$langFolder/3_process.png',
      'assets/images/dbt_faq/$langFolder/4_changes.png',
      'assets/images/dbt_faq/$langFolder/5_final.png',
    ];

    final l10n = AppLocalizations.of(context)!;
    final titleText = () {
      try {
        // Prefer localized title if present.
        // ignore: unnecessary_dynamic
        return (l10n as dynamic).skills_dbt_faq_title as String;
      } catch (_) {
        return 'DBT';
      }
    }();

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _CatsCarousel(
            controller: _pageController,
            imagePaths: imagePaths,
          ),
          const SizedBox(height: 16),
          ..._buildFaq(context),
        ],
      ),
    );
  }

  List<Widget> _buildFaq(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final tiles = <Widget>[];

    for (var i = 0; i < dbtFaqItems.length; i++) {
      final item = dbtFaqItems[i];

      tiles.add(
        _FaqTile(
          title: l.getByKey(item.titleKey),
          body: l.getByKey(item.bodyKey),
        ),
      );

      if (i != dbtFaqItems.length - 1) {
        tiles.add(const SizedBox(height: 10));
      }
    }

    return tiles;
  }
}

class _CatsCarousel extends StatelessWidget {
  final PageController controller;
  final List<String> imagePaths;

  const _CatsCarousel({
    required this.controller,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    // Keep in sync with PageController(viewportFraction: 0.92)
    const viewportFraction = 0.92;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemSize = constraints.maxWidth * viewportFraction;

        return SizedBox(
          height: itemSize,
          child: PageView.builder(
            controller: controller,
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imagePaths[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String title;
  final String body;

  const _FaqTile({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      shadowColor: theme.shadowColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Removes the default ExpansionTile divider.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Html(
                // `flutter_html` collapses plain text newlines; convert them to <br>.
                // This preserves our `\n` formatting from .arb without forcing manual <p> tags.
                data: body.replaceAll('\n', '<br>'),
                style: {
                  // `flutter_html` applies `body` style to all descendants.
                  'body': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 14),
                    color: theme.textTheme.bodyMedium?.color,
                    lineHeight: const LineHeight(1.35),
                  ),
                  'strong': Style(fontWeight: FontWeight.w700),
                  'p': Style(margin: Margins.only(bottom: 10)),
                  'ul': Style(margin: Margins.only(left: 18, bottom: 10)),
                  'ol': Style(margin: Margins.only(left: 18, bottom: 10)),
                  'li': Style(margin: Margins.only(bottom: 6)),
                  'hr': Style(margin: Margins.symmetric(vertical: 10)),
                  'br': Style(margin: Margins.only(bottom: 4)),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _AppLocalizationsByKey on AppLocalizations {
  /// Resolve FAQ strings by key.
  ///
  /// We keep FAQ item definitions data-driven (keys in a list), but the
  /// generated `AppLocalizations` API is strongly typed. This switch is a
  /// small, explicit bridge.
  String getByKey(String key) {
    switch (key) {
      case 'dbtFaq_q1_title':
        return dbtFaq_q1_title;
      case 'dbtFaq_q1_body':
        return dbtFaq_q1_body;

      case 'dbtFaq_q2_title':
        return dbtFaq_q2_title;
      case 'dbtFaq_q2_body':
        return dbtFaq_q2_body;

      case 'dbtFaq_q3_title':
        return dbtFaq_q3_title;
      case 'dbtFaq_q3_body':
        return dbtFaq_q3_body;

      case 'dbtFaq_q4_title':
        return dbtFaq_q4_title;
      case 'dbtFaq_q4_body':
        return dbtFaq_q4_body;

      case 'dbtFaq_q5_title':
        return dbtFaq_q5_title;
      case 'dbtFaq_q5_body':
        return dbtFaq_q5_body;

      case 'dbtFaq_q6_title':
        return dbtFaq_q6_title;
      case 'dbtFaq_q6_body':
        return dbtFaq_q6_body;

      case 'dbtFaq_q7_title':
        return dbtFaq_q7_title;
      case 'dbtFaq_q7_body':
        return dbtFaq_q7_body;

      case 'dbtFaq_q8_title':
        return dbtFaq_q8_title;
      case 'dbtFaq_q8_body':
        return dbtFaq_q8_body;

      case 'dbtFaq_q9_title':
        return dbtFaq_q9_title;
      case 'dbtFaq_q9_body':
        return dbtFaq_q9_body;

      case 'dbtFaq_q10_title':
        return dbtFaq_q10_title;
      case 'dbtFaq_q10_body':
        return dbtFaq_q10_body;

      case 'dbtFaq_q11_title':
        return dbtFaq_q11_title;
      case 'dbtFaq_q11_body':
        return dbtFaq_q11_body;

      case 'dbtFaq_q12_title':
        return dbtFaq_q12_title;
      case 'dbtFaq_q12_body':
        return dbtFaq_q12_body;

      default:
        // Fail safe: returning the key makes missing mappings obvious in UI.
        return key;
    }
  }
}
