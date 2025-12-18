/// DBT FAQ data (localized via l10n keys).
///
/// Notes:
/// - This file intentionally contains NO Russian/English text.
/// - All user-facing strings must live in ARB files (ru/en) and be accessed
///   via AppLocalizations using the keys below.
///
/// The UI layer should render these items as an accordion (e.g., ExpansionTile).


class DbtFaqItem {
  /// Stable identifier (useful for analytics / tests / deep links later).
  final String id;

  /// l10n key for the question title.
  final String titleKey;

  /// l10n key for the answer body.
  ///
  /// The value can contain line breaks ("\n\n") for paragraphs.
  final String bodyKey;

  const DbtFaqItem({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
  });
}

/// FAQ items for the "Dialectical Behavior Therapy" section.
///
/// Expected keys in ARB files (ru/en):
/// - dbtFaq_q1_title, dbtFaq_q1_body
/// - ...
/// - dbtFaq_q12_title, dbtFaq_q12_body
const List<DbtFaqItem> dbtFaqItems = <DbtFaqItem>[
  DbtFaqItem(
    id: 'q1_therapy_or_skills',
    titleKey: 'dbtFaq_q1_title',
    bodyKey: 'dbtFaq_q1_body',
  ),
  DbtFaqItem(
    id: 'q2_who_is_it_for',
    titleKey: 'dbtFaq_q2_title',
    bodyKey: 'dbtFaq_q2_body',
  ),
  DbtFaqItem(
    id: 'q3_dbt_vs_cbt',
    titleKey: 'dbtFaq_q3_title',
    bodyKey: 'dbtFaq_q3_body',
  ),
  DbtFaqItem(
    id: 'q4_what_is_dialectics',
    titleKey: 'dbtFaq_q4_title',
    bodyKey: 'dbtFaq_q4_body',
  ),
  DbtFaqItem(
    id: 'q5_wise_mind',
    titleKey: 'dbtFaq_q5_title',
    bodyKey: 'dbtFaq_q5_body',
  ),
  DbtFaqItem(
    id: 'q6_biosocial_theory',
    titleKey: 'dbtFaq_q6_title',
    bodyKey: 'dbtFaq_q6_body',
  ),
  DbtFaqItem(
    id: 'q7_evidence_base',
    titleKey: 'dbtFaq_q7_title',
    bodyKey: 'dbtFaq_q7_body',
  ),
  DbtFaqItem(
    id: 'q8_when_results',
    titleKey: 'dbtFaq_q8_title',
    bodyKey: 'dbtFaq_q8_body',
  ),
  DbtFaqItem(
    id: 'q9_how_to_learn',
    titleKey: 'dbtFaq_q9_title',
    bodyKey: 'dbtFaq_q9_body',
  ),
  DbtFaqItem(
    id: 'q10_if_i_forget',
    titleKey: 'dbtFaq_q10_title',
    bodyKey: 'dbtFaq_q10_body',
  ),
  DbtFaqItem(
    id: 'q11_without_therapist',
    titleKey: 'dbtFaq_q11_title',
    bodyKey: 'dbtFaq_q11_body',
  ),
  DbtFaqItem(
    id: 'q12_how_app_works',
    titleKey: 'dbtFaq_q12_title',
    bodyKey: 'dbtFaq_q12_body',
  ),
];
