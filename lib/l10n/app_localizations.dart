import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Wisemind'**
  String get appTitle;

  /// No description provided for @mainFabNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get mainFabNewEntry;

  /// No description provided for @mainNavState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get mainNavState;

  /// No description provided for @mainNavWorksheets.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get mainNavWorksheets;

  /// No description provided for @mainNavMeditations.
  ///
  /// In en, this message translates to:
  /// **'Meditations'**
  String get mainNavMeditations;

  /// No description provided for @mainNavSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get mainNavSkills;

  /// No description provided for @tabState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get tabState;

  /// No description provided for @tabWorksheets.
  ///
  /// In en, this message translates to:
  /// **'Worksheets'**
  String get tabWorksheets;

  /// No description provided for @tabMeditations.
  ///
  /// In en, this message translates to:
  /// **'Meditations'**
  String get tabMeditations;

  /// No description provided for @tabSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get tabSkills;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'My state'**
  String get homeTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @onboarding_page1_title.
  ///
  /// In en, this message translates to:
  /// **'Do you often do things you later regret?'**
  String get onboarding_page1_title;

  /// No description provided for @onboarding_page1_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You snap at loved ones, drink too much, overspend or eat to numb stress. In the moment it feels easier, but afterwards there is shame and heaviness — and the cycle repeats again and again.'**
  String get onboarding_page1_subtitle;

  /// No description provided for @onboarding_page2_title.
  ///
  /// In en, this message translates to:
  /// **'Wisemind helps break this cycle'**
  String get onboarding_page2_title;

  /// No description provided for @onboarding_page2_subtitle.
  ///
  /// In en, this message translates to:
  /// **'An app based on DBT — a psychotherapy approach that helps you notice what is happening to you and how you react to urges and impulses.'**
  String get onboarding_page2_subtitle;

  /// No description provided for @onboarding_page3_title.
  ///
  /// In en, this message translates to:
  /// **'Fewer breakdowns — more control over yourself'**
  String get onboarding_page3_title;

  /// No description provided for @onboarding_page3_subtitle.
  ///
  /// In en, this message translates to:
  /// **'You get a chance to consciously choose whether to act on an urge or not. Small steps every day gradually change your behaviour — and, over time, your life.'**
  String get onboarding_page3_subtitle;

  /// No description provided for @onboarding_skip_button.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip_button;

  /// No description provided for @onboarding_next_button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next_button;

  /// No description provided for @onboarding_start_button.
  ///
  /// In en, this message translates to:
  /// **'Start using the app'**
  String get onboarding_start_button;

  /// No description provided for @usageGuideAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use Wisemind'**
  String get usageGuideAppBarTitle;

  /// No description provided for @usageGuideTitle1.
  ///
  /// In en, this message translates to:
  /// **'How Wisemind actually helps'**
  String get usageGuideTitle1;

  /// No description provided for @usageGuideBody1.
  ///
  /// In en, this message translates to:
  /// **'Wisemind isn’t magic and it’s not about tracking everything just for the sake of it.\n\nThe free version already has everything you need to start changing your behavior: logging your state, breaking down difficult situations and trying new ways to respond.\n\nChange takes effort: the app can’t do the work for you, but it can support you step by step.'**
  String get usageGuideBody1;

  /// No description provided for @usageGuideTitle2.
  ///
  /// In en, this message translates to:
  /// **'Step 1. Notice what is happening to you'**
  String get usageGuideTitle2;

  /// No description provided for @usageGuideBody2.
  ///
  /// In en, this message translates to:
  /// **'You can’t change your behavior if you don’t notice what’s going on with you.\n\nThat’s why the first skills block — Mindfulness — is available for free. It helps you pay attention to:\n• your body and sensations\n• your thoughts and emotions\n• what is happening around you\n\nThis makes it easier to catch the moment when a lapse usually starts.'**
  String get usageGuideBody2;

  /// No description provided for @usageGuideTitle3.
  ///
  /// In en, this message translates to:
  /// **'Step 2. Define your problem behavior'**
  String get usageGuideTitle3;

  /// No description provided for @usageGuideBody3.
  ///
  /// In en, this message translates to:
  /// **'First be honest about what is a problem for you: alcohol, fights with loved ones, overeating, smoking, impulsive shopping and so on.\n\nThen fill in the Daily Card every evening. Over time you’ll see links between lack of sleep, stress, lack of rest and other triggers that push you towards lapses and your usual problem behavior.'**
  String get usageGuideBody3;

  /// No description provided for @usageGuideTitle4.
  ///
  /// In en, this message translates to:
  /// **'Step 3. Analyse lapses and train skills'**
  String get usageGuideTitle4;

  /// No description provided for @usageGuideBody4.
  ///
  /// In en, this message translates to:
  /// **'Lapses are inevitable — they are not failure, but material to work with.\n\nUse worksheets to go step by step through what happened before, during and after an episode. DBT skills are grouped into four modules:\n• mindfulness\n• distress tolerance\n• emotion regulation\n• interpersonal effectiveness\n\nTake them slowly — we recommend one skill per week — and keep the ones that work best for you.'**
  String get usageGuideBody4;

  /// No description provided for @usageGuideTitle5.
  ///
  /// In en, this message translates to:
  /// **'Ready to start?'**
  String get usageGuideTitle5;

  /// No description provided for @usageGuideBody5.
  ///
  /// In en, this message translates to:
  /// **'We’ll keep adding new tools, exercises and meditations to support you on your way.\n\nFor now, take the first step — fill in your first entry in the “My state” section.\n\nYou’ll answer a few simple questions about sleep, well-being and emotions. If you come back to it every day, a habit gradually forms — and habits change behavior over time.'**
  String get usageGuideBody5;

  /// No description provided for @usageGuideButtonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get usageGuideButtonNext;

  /// No description provided for @usageGuideButtonFillCard.
  ///
  /// In en, this message translates to:
  /// **'Fill in the Daily Card'**
  String get usageGuideButtonFillCard;

  /// No description provided for @settingsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAppBarTitle;

  /// No description provided for @settingsReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Card reminders'**
  String get settingsReminderTitle;

  /// No description provided for @settingsReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Evening reminder to fill in your Daily Card'**
  String get settingsReminderSubtitle;

  /// No description provided for @settingsGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use the app'**
  String get settingsGuideTitle;

  /// No description provided for @settingsGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short guide to Wisemind'**
  String get settingsGuideSubtitle;

  /// No description provided for @settingsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get settingsContactTitle;

  /// No description provided for @settingsContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Email for questions and suggestions'**
  String get settingsContactSubtitle;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get settingsAboutTitle;

  /// No description provided for @settingsMailError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the mail app'**
  String get settingsMailError;

  /// No description provided for @settingsFeedbackEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Feedback about the Wisemind app'**
  String get settingsFeedbackEmailSubject;

  /// No description provided for @homeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'My state'**
  String get homeAppBarTitle;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @homeExportMenu7Days.
  ///
  /// In en, this message translates to:
  /// **'Export last 7 days'**
  String get homeExportMenu7Days;

  /// No description provided for @homeExportMenuAll.
  ///
  /// In en, this message translates to:
  /// **'Export all entries'**
  String get homeExportMenuAll;

  /// No description provided for @homeExportNoEntries.
  ///
  /// In en, this message translates to:
  /// **'There are no entries to export.'**
  String get homeExportNoEntries;

  /// No description provided for @homeExportNoEntries7Days.
  ///
  /// In en, this message translates to:
  /// **'There are no entries to export for the last 7 days.'**
  String get homeExportNoEntries7Days;

  /// No description provided for @homeExportFileName.
  ///
  /// In en, this message translates to:
  /// **'State entries'**
  String get homeExportFileName;

  /// No description provided for @homeExportSubject7Days.
  ///
  /// In en, this message translates to:
  /// **'State entries for the last 7 days'**
  String get homeExportSubject7Days;

  /// No description provided for @homeExportSubjectAll.
  ///
  /// In en, this message translates to:
  /// **'All state entries'**
  String get homeExportSubjectAll;

  /// No description provided for @homeExportText7Days.
  ///
  /// In en, this message translates to:
  /// **'State entries for the last 7 days (CSV).'**
  String get homeExportText7Days;

  /// No description provided for @homeExportTextAll.
  ///
  /// In en, this message translates to:
  /// **'All state entries (CSV).'**
  String get homeExportTextAll;

  /// No description provided for @homeUsageGuideCardTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use the app'**
  String get homeUsageGuideCardTitle;

  /// No description provided for @homeUsageGuideCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A 2–3 minute guide to get the most out of Wisemind.'**
  String get homeUsageGuideCardSubtitle;

  /// No description provided for @homeUsageGuideHideDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide this guide from the home screen?'**
  String get homeUsageGuideHideDialogTitle;

  /// No description provided for @homeUsageGuideHideDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You can still view this guide later in the \"Settings\" section.'**
  String get homeUsageGuideHideDialogBody;

  /// No description provided for @homeUsageGuideHideDialogHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get homeUsageGuideHideDialogHide;

  /// No description provided for @homeUsageGuideHideDialogKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get homeUsageGuideHideDialogKeep;

  /// No description provided for @homeEmptyStateText.
  ///
  /// In en, this message translates to:
  /// **'🔍 You don’t have any entries here yet.\nTap “+ New entry” to add your first one.'**
  String get homeEmptyStateText;

  /// No description provided for @homeEntriesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'State entries'**
  String get homeEntriesSectionTitle;

  /// No description provided for @homeEntryGratefulPrefix.
  ///
  /// In en, this message translates to:
  /// **'I’m grateful for: {text}'**
  String homeEntryGratefulPrefix(String text);

  /// No description provided for @homeChartNoData.
  ///
  /// In en, this message translates to:
  /// **'There’s no data for the chart yet.\nAdd entries for the last few days.'**
  String get homeChartNoData;

  /// No description provided for @homeChartNoData14Days.
  ///
  /// In en, this message translates to:
  /// **'There’s no data for the last 14 days yet.'**
  String get homeChartNoData14Days;

  /// No description provided for @homeLegendSleep.
  ///
  /// In en, this message translates to:
  /// **'Hours of sleep'**
  String get homeLegendSleep;

  /// No description provided for @homeLegendRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get homeLegendRest;

  /// No description provided for @homeLegendActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get homeLegendActivity;

  /// No description provided for @homeEntryMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get homeEntryMenuEdit;

  /// No description provided for @homeEntryMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homeEntryMenuDelete;

  /// No description provided for @worksheetsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get worksheetsAppBarTitle;

  /// No description provided for @worksheetsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Skill worksheets'**
  String get worksheetsSectionTitle;

  /// No description provided for @worksheetsChainAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem behavior analysis'**
  String get worksheetsChainAnalysisTitle;

  /// No description provided for @worksheetsChainAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the unwanted behavior you want to change'**
  String get worksheetsChainAnalysisSubtitle;

  /// No description provided for @worksheetsProsConsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pros and cons'**
  String get worksheetsProsConsTitle;

  /// No description provided for @worksheetsProsConsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps you choose between problem behavior and a more mindful action'**
  String get worksheetsProsConsSubtitle;

  /// No description provided for @worksheetsFactCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Fact check'**
  String get worksheetsFactCheckTitle;

  /// No description provided for @worksheetsFactCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps you see whether your emotions or thoughts fit the facts'**
  String get worksheetsFactCheckSubtitle;

  /// No description provided for @chainAnalysisListAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Behavior analysis'**
  String get chainAnalysisListAppBarTitle;

  /// No description provided for @chainAnalysisLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load data.\nPlease try again later.'**
  String get chainAnalysisLoadError;

  /// No description provided for @chainAnalysisEmptyList.
  ///
  /// In en, this message translates to:
  /// **'🔍 There are no entries here yet.\nTap “+ New entry” to fill in your first worksheet.'**
  String get chainAnalysisEmptyList;

  /// No description provided for @chainAnalysisUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get chainAnalysisUntitled;

  /// No description provided for @chainAnalysisMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get chainAnalysisMenuEdit;

  /// No description provided for @chainAnalysisMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chainAnalysisMenuDelete;

  /// No description provided for @chainAnalysisDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get chainAnalysisDeleteDialogTitle;

  /// No description provided for @chainAnalysisDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This entry cannot be restored.'**
  String get chainAnalysisDeleteDialogBody;

  /// No description provided for @chainAnalysisDeleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chainAnalysisDeleteDialogCancel;

  /// No description provided for @chainAnalysisDeleteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chainAnalysisDeleteDialogConfirm;

  /// No description provided for @chainAnalysisDeleteSnack.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get chainAnalysisDeleteSnack;

  /// No description provided for @chainAnalysisFabNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get chainAnalysisFabNewEntry;

  /// No description provided for @chainAnalysisEditAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit analysis'**
  String get chainAnalysisEditAppBarTitle;

  /// No description provided for @chainAnalysisNewAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Behavior analysis'**
  String get chainAnalysisNewAppBarTitle;

  /// No description provided for @chainAnalysisProblemRequiredSnack.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem behavior'**
  String get chainAnalysisProblemRequiredSnack;

  /// No description provided for @chainAnalysisExampleCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Example worksheet\n\"Problem behavior analysis\"'**
  String get chainAnalysisExampleCardTitle;

  /// No description provided for @chainAnalysisSectionGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get chainAnalysisSectionGeneralTitle;

  /// No description provided for @chainAnalysisSectionMindfulnessLabel.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get chainAnalysisSectionMindfulnessLabel;

  /// No description provided for @chainAnalysisSectionWorksheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Behavior analysis'**
  String get chainAnalysisSectionWorksheetTitle;

  /// No description provided for @chainAnalysisFieldDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get chainAnalysisFieldDateLabel;

  /// No description provided for @chainAnalysisFieldProblemLabel.
  ///
  /// In en, this message translates to:
  /// **'Problem behavior'**
  String get chainAnalysisFieldProblemLabel;

  /// No description provided for @chainAnalysisFieldProblemHint.
  ///
  /// In en, this message translates to:
  /// **'For example: yelled at a colleague, binged on food'**
  String get chainAnalysisFieldProblemHint;

  /// No description provided for @chainAnalysisSectionChainTitle.
  ///
  /// In en, this message translates to:
  /// **'Chain of events'**
  String get chainAnalysisSectionChainTitle;

  /// No description provided for @chainAnalysisFieldChainLinksLabel.
  ///
  /// In en, this message translates to:
  /// **'What exactly happened (chain)'**
  String get chainAnalysisFieldChainLinksLabel;

  /// No description provided for @chainAnalysisFieldChainLinksHint.
  ///
  /// In en, this message translates to:
  /// **'Thoughts, emotions, body reactions and actions step by step'**
  String get chainAnalysisFieldChainLinksHint;

  /// No description provided for @chainAnalysisFieldPromptingEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompting event'**
  String get chainAnalysisFieldPromptingEventLabel;

  /// No description provided for @chainAnalysisFieldPromptingEventHint.
  ///
  /// In en, this message translates to:
  /// **'What exactly triggered this episode?'**
  String get chainAnalysisFieldPromptingEventHint;

  /// No description provided for @chainAnalysisFieldVulnerabilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Vulnerabilities'**
  String get chainAnalysisFieldVulnerabilitiesLabel;

  /// No description provided for @chainAnalysisFieldVulnerabilitiesHint.
  ///
  /// In en, this message translates to:
  /// **'For example: lack of sleep, hunger, stressful week, illness'**
  String get chainAnalysisFieldVulnerabilitiesHint;

  /// No description provided for @chainAnalysisSectionConsequencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Consequences'**
  String get chainAnalysisSectionConsequencesTitle;

  /// No description provided for @chainAnalysisFieldConsequencesOthersLabel.
  ///
  /// In en, this message translates to:
  /// **'Consequences for others'**
  String get chainAnalysisFieldConsequencesOthersLabel;

  /// No description provided for @chainAnalysisFieldConsequencesOthersHint.
  ///
  /// In en, this message translates to:
  /// **'How did this affect other people?'**
  String get chainAnalysisFieldConsequencesOthersHint;

  /// No description provided for @chainAnalysisFieldConsequencesMeLabel.
  ///
  /// In en, this message translates to:
  /// **'Consequences for me'**
  String get chainAnalysisFieldConsequencesMeLabel;

  /// No description provided for @chainAnalysisFieldConsequencesMeHint.
  ///
  /// In en, this message translates to:
  /// **'What happened to me after the episode — feelings, thoughts, state'**
  String get chainAnalysisFieldConsequencesMeHint;

  /// No description provided for @chainAnalysisFieldDamageLabel.
  ///
  /// In en, this message translates to:
  /// **'Harm done'**
  String get chainAnalysisFieldDamageLabel;

  /// No description provided for @chainAnalysisFieldDamageHint.
  ///
  /// In en, this message translates to:
  /// **'What was damaged or lost because of this behavior?'**
  String get chainAnalysisFieldDamageHint;

  /// No description provided for @chainAnalysisSectionPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get chainAnalysisSectionPlanTitle;

  /// No description provided for @chainAnalysisFieldAdaptiveBehaviourLabel.
  ///
  /// In en, this message translates to:
  /// **'What could you have done instead?'**
  String get chainAnalysisFieldAdaptiveBehaviourLabel;

  /// No description provided for @chainAnalysisFieldAdaptiveBehaviourHint.
  ///
  /// In en, this message translates to:
  /// **'Which healthier behavior could have taken this place?'**
  String get chainAnalysisFieldAdaptiveBehaviourHint;

  /// No description provided for @chainAnalysisFieldDecreaseVulnerabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'How to reduce vulnerability in the future?'**
  String get chainAnalysisFieldDecreaseVulnerabilityLabel;

  /// No description provided for @chainAnalysisFieldDecreaseVulnerabilityHint.
  ///
  /// In en, this message translates to:
  /// **'What in your routine and habits could you strengthen to make it easier?'**
  String get chainAnalysisFieldDecreaseVulnerabilityHint;

  /// No description provided for @chainAnalysisFieldPreventEventLabel.
  ///
  /// In en, this message translates to:
  /// **'How to prevent the prompting event?'**
  String get chainAnalysisFieldPreventEventLabel;

  /// No description provided for @chainAnalysisFieldPreventEventHint.
  ///
  /// In en, this message translates to:
  /// **'What can you do so that a similar situation is less likely to occur again?'**
  String get chainAnalysisFieldPreventEventHint;

  /// No description provided for @chainAnalysisFieldFixPlanLabel.
  ///
  /// In en, this message translates to:
  /// **'Repair plan'**
  String get chainAnalysisFieldFixPlanLabel;

  /// No description provided for @chainAnalysisFieldFixPlanHint.
  ///
  /// In en, this message translates to:
  /// **'Concrete steps to repair consequences and relationships'**
  String get chainAnalysisFieldFixPlanHint;

  /// No description provided for @chainAnalysisSaveButtonNew.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get chainAnalysisSaveButtonNew;

  /// No description provided for @chainAnalysisSaveButtonEdit.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get chainAnalysisSaveButtonEdit;

  /// No description provided for @chainAnalysisSaveSnackNew.
  ///
  /// In en, this message translates to:
  /// **'Entry added'**
  String get chainAnalysisSaveSnackNew;

  /// No description provided for @chainAnalysisSaveSnackEdit.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get chainAnalysisSaveSnackEdit;

  /// No description provided for @chainAnalysisExampleAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Example worksheet'**
  String get chainAnalysisExampleAppBarTitle;

  /// No description provided for @chainAnalysisDetailAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis details'**
  String get chainAnalysisDetailAppBarTitle;

  /// No description provided for @factCheckListAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Fact check'**
  String get factCheckListAppBarTitle;

  /// No description provided for @factCheckLoadErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load entries.'**
  String get factCheckLoadErrorGeneric;

  /// No description provided for @factCheckLoadErrorWithReason.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load entries.\n{error}'**
  String factCheckLoadErrorWithReason(String error);

  /// No description provided for @factCheckEmptyList.
  ///
  /// In en, this message translates to:
  /// **'🔍 There are no entries here yet.\nTap \"+ New entry\" to fill in your first worksheet.'**
  String get factCheckEmptyList;

  /// No description provided for @factCheckEmotionNone.
  ///
  /// In en, this message translates to:
  /// **'No emotion'**
  String get factCheckEmotionNone;

  /// No description provided for @factCheckMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get factCheckMenuEdit;

  /// No description provided for @factCheckMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get factCheckMenuDelete;

  /// No description provided for @factCheckDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get factCheckDeleteDialogTitle;

  /// No description provided for @factCheckDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This entry cannot be restored.'**
  String get factCheckDeleteDialogBody;

  /// No description provided for @factCheckDeleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get factCheckDeleteDialogCancel;

  /// No description provided for @factCheckDeleteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get factCheckDeleteDialogConfirm;

  /// No description provided for @factCheckDeleteSnack.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get factCheckDeleteSnack;

  /// No description provided for @factCheckFabNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get factCheckFabNewEntry;

  /// No description provided for @factCheckDetailAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'View entry'**
  String get factCheckDetailAppBarTitle;

  /// No description provided for @factCheckSectionGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General information'**
  String get factCheckSectionGeneralTitle;

  /// No description provided for @factCheckSectionEmotionRegulationLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotion regulation'**
  String get factCheckSectionEmotionRegulationLabel;

  /// No description provided for @factCheckSectionWorksheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Fact check'**
  String get factCheckSectionWorksheetTitle;

  /// No description provided for @factCheckSectionEmotionIntensityTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotion and intensity'**
  String get factCheckSectionEmotionIntensityTitle;

  /// No description provided for @factCheckSectionAfterTitle.
  ///
  /// In en, this message translates to:
  /// **'After the fact check'**
  String get factCheckSectionAfterTitle;

  /// No description provided for @factCheckFieldDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get factCheckFieldDateLabel;

  /// No description provided for @factCheckFieldEmotionLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotion'**
  String get factCheckFieldEmotionLabel;

  /// No description provided for @factCheckEmotionAnger.
  ///
  /// In en, this message translates to:
  /// **'😡 Anger'**
  String get factCheckEmotionAnger;

  /// No description provided for @factCheckEmotionFear.
  ///
  /// In en, this message translates to:
  /// **'😨 Fear'**
  String get factCheckEmotionFear;

  /// No description provided for @factCheckEmotionAnxiety.
  ///
  /// In en, this message translates to:
  /// **'😟 Anxiety'**
  String get factCheckEmotionAnxiety;

  /// No description provided for @factCheckEmotionSadness.
  ///
  /// In en, this message translates to:
  /// **'😢 Sadness'**
  String get factCheckEmotionSadness;

  /// No description provided for @factCheckEmotionGuilt.
  ///
  /// In en, this message translates to:
  /// **'😞 Guilt'**
  String get factCheckEmotionGuilt;

  /// No description provided for @factCheckEmotionShame.
  ///
  /// In en, this message translates to:
  /// **'😳 Shame'**
  String get factCheckEmotionShame;

  /// No description provided for @factCheckEmotionDisgust.
  ///
  /// In en, this message translates to:
  /// **'🤢 Disgust'**
  String get factCheckEmotionDisgust;

  /// No description provided for @factCheckEmotionDesire.
  ///
  /// In en, this message translates to:
  /// **'🤤 Desire'**
  String get factCheckEmotionDesire;

  /// No description provided for @factCheckEmotionJoy.
  ///
  /// In en, this message translates to:
  /// **'😄 Joy'**
  String get factCheckEmotionJoy;

  /// No description provided for @factCheckEmotionHurt.
  ///
  /// In en, this message translates to:
  /// **'😔 Hurt'**
  String get factCheckEmotionHurt;

  /// No description provided for @factCheckFieldInitialIntensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotion intensity (0–100)'**
  String get factCheckFieldInitialIntensityLabel;

  /// No description provided for @factCheckFieldInitialIntensityHint.
  ///
  /// In en, this message translates to:
  /// **'From 0 to 100'**
  String get factCheckFieldInitialIntensityHint;

  /// No description provided for @factCheckFieldPromptingEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Prompting event'**
  String get factCheckFieldPromptingEventLabel;

  /// No description provided for @factCheckFieldPromptingEventHint.
  ///
  /// In en, this message translates to:
  /// **'What happened that led to this emotion? Who did what to whom? What did it lead to? Is this a problem for you? Be as specific as possible.'**
  String get factCheckFieldPromptingEventHint;

  /// No description provided for @factCheckFieldFactsExtremesLabel.
  ///
  /// In en, this message translates to:
  /// **'Check the facts!'**
  String get factCheckFieldFactsExtremesLabel;

  /// No description provided for @factCheckFieldFactsExtremesHint.
  ///
  /// In en, this message translates to:
  /// **'Look for all-or-nothing thinking and judgments in your thoughts.'**
  String get factCheckFieldFactsExtremesHint;

  /// No description provided for @factCheckFieldMyInterpretationLabel.
  ///
  /// In en, this message translates to:
  /// **'My interpretation of the facts'**
  String get factCheckFieldMyInterpretationLabel;

  /// No description provided for @factCheckFieldMyInterpretationHint.
  ///
  /// In en, this message translates to:
  /// **'What am I assuming? Am I adding my own story on top of what actually happened?'**
  String get factCheckFieldMyInterpretationHint;

  /// No description provided for @factCheckFieldAltInterpretationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Check the facts (other interpretations)'**
  String get factCheckFieldAltInterpretationsLabel;

  /// No description provided for @factCheckFieldAltInterpretationsHint.
  ///
  /// In en, this message translates to:
  /// **'Write down as many alternative interpretations of these facts as you can.'**
  String get factCheckFieldAltInterpretationsHint;

  /// No description provided for @factCheckFieldPerceivedThreatLabel.
  ///
  /// In en, this message translates to:
  /// **'Is this a threat to me?'**
  String get factCheckFieldPerceivedThreatLabel;

  /// No description provided for @factCheckFieldPerceivedThreatHint.
  ///
  /// In en, this message translates to:
  /// **'What exactly feels threatened here? How could this event or situation harm me? What negative outcomes am I expecting?'**
  String get factCheckFieldPerceivedThreatHint;

  /// No description provided for @factCheckFieldAltOutcomesLabel.
  ///
  /// In en, this message translates to:
  /// **'Check the facts (other possible outcomes)'**
  String get factCheckFieldAltOutcomesLabel;

  /// No description provided for @factCheckFieldAltOutcomesHint.
  ///
  /// In en, this message translates to:
  /// **'Write down as many other possible outcomes of this situation as you can, based on the facts.'**
  String get factCheckFieldAltOutcomesHint;

  /// No description provided for @factCheckFieldCatastropheLabel.
  ///
  /// In en, this message translates to:
  /// **'Is it a catastrophe?'**
  String get factCheckFieldCatastropheLabel;

  /// No description provided for @factCheckFieldCatastropheHint.
  ///
  /// In en, this message translates to:
  /// **'Describe in detail the worst realistic consequences that could happen.'**
  String get factCheckFieldCatastropheHint;

  /// No description provided for @factCheckFieldCopingLabel.
  ///
  /// In en, this message translates to:
  /// **'How will I cope with the consequences?'**
  String get factCheckFieldCopingLabel;

  /// No description provided for @factCheckFieldCopingHint.
  ///
  /// In en, this message translates to:
  /// **'Describe how you would handle it if it did happen.'**
  String get factCheckFieldCopingHint;

  /// No description provided for @factCheckFieldEmotionMatchLabel.
  ///
  /// In en, this message translates to:
  /// **'Do my emotions fit the facts? (0–5)'**
  String get factCheckFieldEmotionMatchLabel;

  /// No description provided for @factCheckFieldCurrentIntensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Current emotion intensity (0–100)'**
  String get factCheckFieldCurrentIntensityLabel;

  /// No description provided for @factCheckFieldCurrentIntensityHint.
  ///
  /// In en, this message translates to:
  /// **'From 0 to 100'**
  String get factCheckFieldCurrentIntensityHint;

  /// No description provided for @factCheckSaveButtonNew.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get factCheckSaveButtonNew;

  /// No description provided for @factCheckSaveButtonEdit.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get factCheckSaveButtonEdit;

  /// No description provided for @factCheckSaveSnackNew.
  ///
  /// In en, this message translates to:
  /// **'Entry added'**
  String get factCheckSaveSnackNew;

  /// No description provided for @factCheckSaveSnackEdit.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get factCheckSaveSnackEdit;

  /// No description provided for @factCheckExamplePillTitle.
  ///
  /// In en, this message translates to:
  /// **'Example worksheet \"Fact check\"'**
  String get factCheckExamplePillTitle;

  /// No description provided for @factCheckExampleAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Example worksheet'**
  String get factCheckExampleAppBarTitle;

  /// No description provided for @prosConsListAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Pros and cons'**
  String get prosConsListAppBarTitle;

  /// No description provided for @prosConsEmptyList.
  ///
  /// In en, this message translates to:
  /// **'🔍 There are no entries here yet.\nTap \"+ New entry\" to fill in your first worksheet.'**
  String get prosConsEmptyList;

  /// No description provided for @prosConsMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get prosConsMenuEdit;

  /// No description provided for @prosConsMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get prosConsMenuDelete;

  /// No description provided for @prosConsDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get prosConsDeleteDialogTitle;

  /// No description provided for @prosConsDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This entry cannot be restored.'**
  String get prosConsDeleteDialogBody;

  /// No description provided for @prosConsDeleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get prosConsDeleteDialogCancel;

  /// No description provided for @prosConsDeleteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get prosConsDeleteDialogConfirm;

  /// No description provided for @prosConsDeleteSnack.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get prosConsDeleteSnack;

  /// No description provided for @prosConsFabNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get prosConsFabNewEntry;

  /// No description provided for @prosConsDetailAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'View entry'**
  String get prosConsDetailAppBarTitle;

  /// No description provided for @prosConsDetailSectionWorksheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Pros and cons worksheet'**
  String get prosConsDetailSectionWorksheetTitle;

  /// No description provided for @prosConsSectionDistressToleranceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distress tolerance'**
  String get prosConsSectionDistressToleranceLabel;

  /// No description provided for @prosConsSectionWorksheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Pros and cons'**
  String get prosConsSectionWorksheetTitle;

  /// No description provided for @prosConsFieldDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get prosConsFieldDateLabel;

  /// No description provided for @prosConsFieldProblemLabel.
  ///
  /// In en, this message translates to:
  /// **'Problem behavior'**
  String get prosConsFieldProblemLabel;

  /// No description provided for @prosConsFieldProsActImpulsivelyLabel.
  ///
  /// In en, this message translates to:
  /// **'Pros: act on the impulse'**
  String get prosConsFieldProsActImpulsivelyLabel;

  /// No description provided for @prosConsFieldProsResistImpulseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pros: resist the impulse'**
  String get prosConsFieldProsResistImpulseLabel;

  /// No description provided for @prosConsFieldConsActImpulsivelyLabel.
  ///
  /// In en, this message translates to:
  /// **'Cons: act on the impulse'**
  String get prosConsFieldConsActImpulsivelyLabel;

  /// No description provided for @prosConsFieldConsResistImpulseLabel.
  ///
  /// In en, this message translates to:
  /// **'Cons: resist the impulse'**
  String get prosConsFieldConsResistImpulseLabel;

  /// No description provided for @prosConsDecisionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'What did you decide?'**
  String get prosConsDecisionSectionTitle;

  /// No description provided for @prosConsDecisionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you decide?'**
  String get prosConsDecisionFieldLabel;

  /// No description provided for @prosConsDecisionFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Write down the decision you made. If you still can’t decide, go through the worksheet one more time.'**
  String get prosConsDecisionFieldHint;

  /// No description provided for @prosConsEditAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get prosConsEditAppBarTitle;

  /// No description provided for @prosConsNewAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get prosConsNewAppBarTitle;

  /// No description provided for @prosConsExamplePillTitle.
  ///
  /// In en, this message translates to:
  /// **'Example \"Pros and cons\" worksheet'**
  String get prosConsExamplePillTitle;

  /// No description provided for @prosConsEditSectionWorksheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Pros and cons worksheet'**
  String get prosConsEditSectionWorksheetTitle;

  /// No description provided for @prosConsFieldProblemHint.
  ///
  /// In en, this message translates to:
  /// **'Which problem behavior are you evaluating?'**
  String get prosConsFieldProblemHint;

  /// No description provided for @prosConsFieldProsActImpulsivelyHint.
  ///
  /// In en, this message translates to:
  /// **'List all the reasons in favor of acting on the problem behavior impulse.'**
  String get prosConsFieldProsActImpulsivelyHint;

  /// No description provided for @prosConsFieldProsResistImpulseHint.
  ///
  /// In en, this message translates to:
  /// **'List all the reasons in favor of resisting the problem behavior impulse.'**
  String get prosConsFieldProsResistImpulseHint;

  /// No description provided for @prosConsFieldConsActImpulsivelyHint.
  ///
  /// In en, this message translates to:
  /// **'List all the reasons against acting on the problem behavior impulse.'**
  String get prosConsFieldConsActImpulsivelyHint;

  /// No description provided for @prosConsFieldConsResistImpulseHint.
  ///
  /// In en, this message translates to:
  /// **'List all the reasons against resisting the problem behavior impulse.'**
  String get prosConsFieldConsResistImpulseHint;

  /// No description provided for @prosConsSaveButtonNew.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get prosConsSaveButtonNew;

  /// No description provided for @prosConsSaveButtonEdit.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get prosConsSaveButtonEdit;

  /// No description provided for @prosConsSaveSnackNew.
  ///
  /// In en, this message translates to:
  /// **'Entry added'**
  String get prosConsSaveSnackNew;

  /// No description provided for @prosConsSaveSnackEdit.
  ///
  /// In en, this message translates to:
  /// **'Entry updated'**
  String get prosConsSaveSnackEdit;

  /// No description provided for @prosConsExampleAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Example entry'**
  String get prosConsExampleAppBarTitle;

  /// No description provided for @meditationsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Meditations'**
  String get meditationsAppBarTitle;

  /// No description provided for @meditationsSectionMindfulness.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get meditationsSectionMindfulness;

  /// No description provided for @meditationsSectionDistressTolerance.
  ///
  /// In en, this message translates to:
  /// **'Distress tolerance'**
  String get meditationsSectionDistressTolerance;

  /// No description provided for @meditationsSectionEmotionRegulation.
  ///
  /// In en, this message translates to:
  /// **'Emotion regulation'**
  String get meditationsSectionEmotionRegulation;

  /// No description provided for @meditationsSectionInterpersonalEffectiveness.
  ///
  /// In en, this message translates to:
  /// **'Interpersonal effectiveness'**
  String get meditationsSectionInterpersonalEffectiveness;

  /// No description provided for @meditationsCategoryStressReductionRaw.
  ///
  /// In en, this message translates to:
  /// **'Stress reduction'**
  String get meditationsCategoryStressReductionRaw;

  /// No description provided for @meditationsSkillEmpathicPresenceShort.
  ///
  /// In en, this message translates to:
  /// **'Empathy'**
  String get meditationsSkillEmpathicPresenceShort;

  /// No description provided for @meditationHintCardText.
  ///
  /// In en, this message translates to:
  /// **'🌿 Find a quiet place where no one will disturb you, sit comfortably and begin.'**
  String get meditationHintCardText;

  /// No description provided for @meditationLoadErrorText.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load the meditation audio.\nThis is often related to your internet connection. Try again or switch tabs and come back.'**
  String get meditationLoadErrorText;

  /// No description provided for @meditationToggleWithVoice.
  ///
  /// In en, this message translates to:
  /// **'With voice'**
  String get meditationToggleWithVoice;

  /// No description provided for @meditationToggleMusicOnly.
  ///
  /// In en, this message translates to:
  /// **'Music only'**
  String get meditationToggleMusicOnly;

  /// No description provided for @meditationButtonPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get meditationButtonPause;

  /// No description provided for @meditationButtonPlay.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get meditationButtonPlay;

  /// No description provided for @meditationSubscriptionInfo.
  ///
  /// In en, this message translates to:
  /// **'Access to this meditation may require a subscription.'**
  String get meditationSubscriptionInfo;

  /// No description provided for @stateDashboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll see your state statistics.'**
  String get stateDashboardEmptyTitle;

  /// No description provided for @stateDashboardEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'There are no entries yet. Tap the button below to fill in today’s form.'**
  String get stateDashboardEmptyBody;

  /// No description provided for @stateDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'My state'**
  String get stateDashboardTitle;

  /// No description provided for @stateDashboardChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep, rest and activity over recent days'**
  String get stateDashboardChartTitle;

  /// No description provided for @stateDashboardLegendSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get stateDashboardLegendSleep;

  /// No description provided for @stateDashboardLegendRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get stateDashboardLegendRest;

  /// No description provided for @stateDashboardLegendActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get stateDashboardLegendActivity;

  /// No description provided for @stateDashboardHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry history'**
  String get stateDashboardHistoryTitle;

  /// No description provided for @stateDashboardHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent days'**
  String get stateDashboardHistorySubtitle;

  /// No description provided for @stateDashboardSleepText.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String stateDashboardSleepText(String hours);

  /// No description provided for @stateDashboardRestText.
  ///
  /// In en, this message translates to:
  /// **'{value}/5 rest'**
  String stateDashboardRestText(int value);

  /// No description provided for @stateDashboardActivityText.
  ///
  /// In en, this message translates to:
  /// **'{value}/5 activity'**
  String stateDashboardActivityText(int value);

  /// No description provided for @entryFormEditAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get entryFormEditAppBarTitle;

  /// No description provided for @entryFormNewAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get entryFormNewAppBarTitle;

  /// No description provided for @entryFormSectionGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'Overall state'**
  String get entryFormSectionGeneralTitle;

  /// No description provided for @entryFormFieldDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get entryFormFieldDateLabel;

  /// No description provided for @entryFormMoodQuestion.
  ///
  /// In en, this message translates to:
  /// **'How are you today?'**
  String get entryFormMoodQuestion;

  /// No description provided for @entryFormFieldGratefulLabel.
  ///
  /// In en, this message translates to:
  /// **'What do I thank myself for today?'**
  String get entryFormFieldGratefulLabel;

  /// No description provided for @entryFormFieldGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'What did I do toward my goal?'**
  String get entryFormFieldGoalLabel;

  /// No description provided for @entryFormSectionSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get entryFormSectionSleepTitle;

  /// No description provided for @entryFormFieldRestLabel.
  ///
  /// In en, this message translates to:
  /// **'How rested do you feel?'**
  String get entryFormFieldRestLabel;

  /// No description provided for @entryFormFieldSleepHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'How many hours did you sleep?'**
  String get entryFormFieldSleepHoursLabel;

  /// No description provided for @entryFormFieldWakeTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'What time did you wake up?'**
  String get entryFormFieldWakeTimeLabel;

  /// No description provided for @entryFormFieldNightWakeupsLabel.
  ///
  /// In en, this message translates to:
  /// **'How many times did you wake up at night?'**
  String get entryFormFieldNightWakeupsLabel;

  /// No description provided for @entryFormSectionDiscomfortTitle.
  ///
  /// In en, this message translates to:
  /// **'Discomfort'**
  String get entryFormSectionDiscomfortTitle;

  /// No description provided for @entryFormFieldPhysicalDiscomfortLabel.
  ///
  /// In en, this message translates to:
  /// **'Physical discomfort'**
  String get entryFormFieldPhysicalDiscomfortLabel;

  /// No description provided for @entryFormFieldEmotionalDiscomfortLabel.
  ///
  /// In en, this message translates to:
  /// **'Emotional discomfort'**
  String get entryFormFieldEmotionalDiscomfortLabel;

  /// No description provided for @entryFormSectionEmotionalStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Emotional state'**
  String get entryFormSectionEmotionalStateTitle;

  /// No description provided for @entryFormFieldDissociationLabel.
  ///
  /// In en, this message translates to:
  /// **'Feeling unreal / detached'**
  String get entryFormFieldDissociationLabel;

  /// No description provided for @entryFormFieldRuminationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ruminations and intrusive thoughts'**
  String get entryFormFieldRuminationsLabel;

  /// No description provided for @entryFormFieldSelfBlameLabel.
  ///
  /// In en, this message translates to:
  /// **'Self-blame'**
  String get entryFormFieldSelfBlameLabel;

  /// No description provided for @entryFormFieldSuicidalThoughtsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suicidal thoughts'**
  String get entryFormFieldSuicidalThoughtsLabel;

  /// No description provided for @entryFormSectionProblemBehaviorTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem behavior'**
  String get entryFormSectionProblemBehaviorTitle;

  /// No description provided for @entryFormProblemBehaviorHint.
  ///
  /// In en, this message translates to:
  /// **'Fill this in if you’re tracking a specific problem behavior.'**
  String get entryFormProblemBehaviorHint;

  /// No description provided for @entryFormFieldUrgesLabel.
  ///
  /// In en, this message translates to:
  /// **'How strong was the urge?'**
  String get entryFormFieldUrgesLabel;

  /// No description provided for @entryFormFieldActionLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you do?'**
  String get entryFormFieldActionLabel;

  /// No description provided for @entryFormSectionSelfCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Self-care'**
  String get entryFormSectionSelfCareTitle;

  /// No description provided for @entryFormFieldPhysicalActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Physical activity'**
  String get entryFormFieldPhysicalActivityLabel;

  /// No description provided for @entryFormFieldPleasureLabel.
  ///
  /// In en, this message translates to:
  /// **'How much pleasure did you have?'**
  String get entryFormFieldPleasureLabel;

  /// No description provided for @entryFormFieldWaterLabel.
  ///
  /// In en, this message translates to:
  /// **'How much liquid did you drink?'**
  String get entryFormFieldWaterLabel;

  /// No description provided for @entryFormFieldMealsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'How many times did you eat?'**
  String get entryFormFieldMealsCountLabel;

  /// No description provided for @entryFormSectionSkillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Skills used'**
  String get entryFormSectionSkillsTitle;

  /// No description provided for @entryFormSkillsHint.
  ///
  /// In en, this message translates to:
  /// **'You can select several.'**
  String get entryFormSkillsHint;

  /// No description provided for @entryFormSkillsButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose skills'**
  String get entryFormSkillsButtonLabel;

  /// No description provided for @entryFormSkillsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose skills'**
  String get entryFormSkillsDialogTitle;

  /// No description provided for @entryFormDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get entryFormDialogCancel;

  /// No description provided for @entryFormDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get entryFormDialogConfirm;

  /// No description provided for @entryFormButtonSaveNew.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get entryFormButtonSaveNew;

  /// No description provided for @entryFormButtonSaveEdit.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get entryFormButtonSaveEdit;

  /// No description provided for @entryFormWakeOptionBefore4.
  ///
  /// In en, this message translates to:
  /// **'Before 4:00'**
  String get entryFormWakeOptionBefore4;

  /// No description provided for @entryFormWakeOptionAfter13.
  ///
  /// In en, this message translates to:
  /// **'After 13:00'**
  String get entryFormWakeOptionAfter13;

  /// No description provided for @entryFormWaterOptionMoreThan4.
  ///
  /// In en, this message translates to:
  /// **'More than 4 L'**
  String get entryFormWaterOptionMoreThan4;

  /// No description provided for @entryFormWaterOptionLiters.
  ///
  /// In en, this message translates to:
  /// **'{liters} L'**
  String entryFormWaterOptionLiters(String liters);

  /// No description provided for @stateEntryDetailAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily state'**
  String get stateEntryDetailAppBarTitle;

  /// No description provided for @stateEntryDetailSectionSkillsTitle.
  ///
  /// In en, this message translates to:
  /// **'🧩 Skills used'**
  String get stateEntryDetailSectionSkillsTitle;

  /// No description provided for @stateEntryDetailSectionGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'🎯 Actions toward your goal'**
  String get stateEntryDetailSectionGoalTitle;

  /// No description provided for @stateEntryDetailSectionSleepTitle.
  ///
  /// In en, this message translates to:
  /// **'😴 Sleep quality'**
  String get stateEntryDetailSectionSleepTitle;

  /// No description provided for @stateEntryDetailSectionDiscomfortTitle.
  ///
  /// In en, this message translates to:
  /// **'😣 Discomfort'**
  String get stateEntryDetailSectionDiscomfortTitle;

  /// No description provided for @stateEntryDetailSectionEmotionalStateTitle.
  ///
  /// In en, this message translates to:
  /// **'💭 Emotional state'**
  String get stateEntryDetailSectionEmotionalStateTitle;

  /// No description provided for @stateEntryDetailSectionProblemBehaviorTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Problem behavior'**
  String get stateEntryDetailSectionProblemBehaviorTitle;

  /// No description provided for @stateEntryDetailSectionSelfCareTitle.
  ///
  /// In en, this message translates to:
  /// **'💗 Self-care'**
  String get stateEntryDetailSectionSelfCareTitle;

  /// No description provided for @stateEntryDetailHeaderGratefulLabel.
  ///
  /// In en, this message translates to:
  /// **'What I thank myself for'**
  String get stateEntryDetailHeaderGratefulLabel;

  /// No description provided for @stateEntryDetailMetricSleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get stateEntryDetailMetricSleepLabel;

  /// No description provided for @stateEntryDetailMetricRestLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get stateEntryDetailMetricRestLabel;

  /// No description provided for @stateEntryDetailMetricActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get stateEntryDetailMetricActivityLabel;

  /// No description provided for @stateEntryDetailMetricSleepUnitHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get stateEntryDetailMetricSleepUnitHours;

  /// No description provided for @stateEntryDetailMetricScoreUnitOutOfFive.
  ///
  /// In en, this message translates to:
  /// **'out of 5'**
  String get stateEntryDetailMetricScoreUnitOutOfFive;

  /// No description provided for @stateEntryDetailSleepWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake-up time: {time}'**
  String stateEntryDetailSleepWakeUp(String time);

  /// No description provided for @stateEntryDetailSleepNightWakeups.
  ///
  /// In en, this message translates to:
  /// **'Night awakenings: {count}'**
  String stateEntryDetailSleepNightWakeups(int count);

  /// No description provided for @stateEntryDetailDiscomfortPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical: {value}/5'**
  String stateEntryDetailDiscomfortPhysical(int value);

  /// No description provided for @stateEntryDetailDiscomfortEmotional.
  ///
  /// In en, this message translates to:
  /// **'Emotional: {value}/5'**
  String stateEntryDetailDiscomfortEmotional(int value);

  /// No description provided for @stateEntryDetailEmotionalDissociation.
  ///
  /// In en, this message translates to:
  /// **'Dissociation: {value}/5'**
  String stateEntryDetailEmotionalDissociation(int value);

  /// No description provided for @stateEntryDetailEmotionalRuminations.
  ///
  /// In en, this message translates to:
  /// **'Ruminations: {value}/5'**
  String stateEntryDetailEmotionalRuminations(int value);

  /// No description provided for @stateEntryDetailEmotionalSelfBlame.
  ///
  /// In en, this message translates to:
  /// **'Self-blame: {value}/5'**
  String stateEntryDetailEmotionalSelfBlame(int value);

  /// No description provided for @stateEntryDetailEmotionalSuicidalThoughts.
  ///
  /// In en, this message translates to:
  /// **'Suicidal thoughts: {value}/5'**
  String stateEntryDetailEmotionalSuicidalThoughts(int value);

  /// No description provided for @stateEntryDetailProblemUrge.
  ///
  /// In en, this message translates to:
  /// **'Urge strength: {value}/5'**
  String stateEntryDetailProblemUrge(int value);

  /// No description provided for @stateEntryDetailProblemAction.
  ///
  /// In en, this message translates to:
  /// **'What happened: {text}'**
  String stateEntryDetailProblemAction(String text);

  /// No description provided for @stateEntryDetailSelfCarePhysicalActivity.
  ///
  /// In en, this message translates to:
  /// **'Physical activity: {value}/5'**
  String stateEntryDetailSelfCarePhysicalActivity(int value);

  /// No description provided for @stateEntryDetailSelfCarePleasure.
  ///
  /// In en, this message translates to:
  /// **'Pleasure: {value}/5'**
  String stateEntryDetailSelfCarePleasure(int value);

  /// No description provided for @stateEntryDetailSelfCareWater.
  ///
  /// In en, this message translates to:
  /// **'Amount of liquid: {liters} L'**
  String stateEntryDetailSelfCareWater(String liters);

  /// No description provided for @stateEntryDetailSelfCareFood.
  ///
  /// In en, this message translates to:
  /// **'Number of meals: {count}'**
  String stateEntryDetailSelfCareFood(int count);

  /// No description provided for @stateEntryDetailNoData.
  ///
  /// In en, this message translates to:
  /// **'No entries'**
  String get stateEntryDetailNoData;

  /// No description provided for @aboutAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutAppBarTitle;

  /// No description provided for @aboutPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacyPolicyTitle;

  /// No description provided for @aboutPersonalDataPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Data Policy'**
  String get aboutPersonalDataPolicyTitle;

  /// No description provided for @aboutPrivacyPolicyUrl.
  ///
  /// In en, this message translates to:
  /// **'https://tyronel183.github.io/wisemind-legal/privacy-policy-en.html'**
  String get aboutPrivacyPolicyUrl;

  /// No description provided for @aboutPersonalDataPolicyUrl.
  ///
  /// In en, this message translates to:
  /// **'https://tyronel183.github.io/wisemind-legal/personal-data-policy-en.html'**
  String get aboutPersonalDataPolicyUrl;

  /// No description provided for @aboutAppVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutAppVersionLabel(String version);

  /// Title of the root skills screen
  ///
  /// In en, this message translates to:
  /// **'DBT skills'**
  String get skillsRoot_title;

  /// Title of the DBT intro card
  ///
  /// In en, this message translates to:
  /// **'Dialectical Behavior Therapy'**
  String get skillsRoot_dbtIntro_title;

  /// Subtitle of the DBT intro card
  ///
  /// In en, this message translates to:
  /// **'What DBT is, what it consists of, and how to work with it in this app.'**
  String get skillsRoot_dbtIntro_subtitle;

  /// Module name Mindfulness
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get dbtModule_mindfulness;

  /// Module name Distress tolerance
  ///
  /// In en, this message translates to:
  /// **'Distress tolerance'**
  String get dbtModule_distressTolerance;

  /// Module name Emotion regulation
  ///
  /// In en, this message translates to:
  /// **'Emotion regulation'**
  String get dbtModule_emotionRegulation;

  /// Module name Interpersonal effectiveness
  ///
  /// In en, this message translates to:
  /// **'Interpersonal effectiveness'**
  String get dbtModule_interpersonalEffectiveness;

  /// App bar title of the DBT intro screen
  ///
  /// In en, this message translates to:
  /// **'What is DBT'**
  String get dbtIntro_appBar_title;

  /// Header text on the DBT intro screen
  ///
  /// In en, this message translates to:
  /// **'Dialectical Behavior Therapy'**
  String get dbtIntro_header;

  /// Placeholder text about DBT
  ///
  /// In en, this message translates to:
  /// **'Later here you will see a full text about what DBT is, which modules it includes, and how to use this app as a companion to therapy.'**
  String get dbtIntro_body;

  /// Subheading for the 'Where to start' section on the intro screen
  ///
  /// In en, this message translates to:
  /// **'Where to start'**
  String get dbtIntro_section_start;

  /// Instructions on where to start with DBT
  ///
  /// In en, this message translates to:
  /// **'Usually DBT starts with Mindfulness: the “what” and “how” skills of being in the moment. Tap the button below to go to the Mindfulness module and start exploring the skills step by step.'**
  String get dbtIntro_howToStart;

  /// Button text to navigate to the Mindfulness module
  ///
  /// In en, this message translates to:
  /// **'Start with mindfulness'**
  String get dbtIntro_startMindfulness_button;

  /// Error text prefix before the exception message when loading skills fails
  ///
  /// In en, this message translates to:
  /// **'Error loading skills:'**
  String get skillsList_error_prefix;

  /// Placeholder text when a module has no skills
  ///
  /// In en, this message translates to:
  /// **'There are no skills in this section yet.'**
  String get skillsList_empty;

  /// Section title for basic description of the skill
  ///
  /// In en, this message translates to:
  /// **'What it is'**
  String get skillOverview_section_what;

  /// Placeholder when there is no textWhat
  ///
  /// In en, this message translates to:
  /// **'A description of what this skill is will appear here — we’ll add it from your materials later.'**
  String get skillOverview_section_what_placeholder;

  /// Label of the button that opens full skill description
  ///
  /// In en, this message translates to:
  /// **'Full info about the skill'**
  String get skillOverview_fullInfo_button;

  /// Placeholder for full skill description
  ///
  /// In en, this message translates to:
  /// **'A full text description of the skill “{skillName}” will appear here. For now, this is a placeholder.'**
  String skillOverview_fullInfo_placeholder(String skillName);

  /// Section title 'Why it matters'
  ///
  /// In en, this message translates to:
  /// **'Why it matters'**
  String get skillOverview_section_why;

  /// Placeholder when there is no textWhy
  ///
  /// In en, this message translates to:
  /// **'Later you’ll see here when this skill is especially useful and how it helps.'**
  String get skillOverview_section_why_placeholder;

  /// Section title 'How to practice'
  ///
  /// In en, this message translates to:
  /// **'How to practice'**
  String get skillOverview_section_practice;

  /// Placeholder when there is no textPractice
  ///
  /// In en, this message translates to:
  /// **'This section will describe practice steps: what to do first, what next, and how to apply the skill in real life.'**
  String get skillOverview_section_practice_placeholder;

  /// Button label to open full practice description
  ///
  /// In en, this message translates to:
  /// **'More about practice'**
  String get skillOverview_morePractice_button;

  /// Placeholder for full practice description
  ///
  /// In en, this message translates to:
  /// **'A detailed practice description for the skill “{skillName}” and worksheets will appear here. For now, this is a placeholder.'**
  String skillOverview_fullPractice_placeholder(String skillName);

  /// Separator between module name and section; may differ per locale
  ///
  /// In en, this message translates to:
  /// **' · '**
  String get skillOverview_meta_separator;

  /// Title of the full skill info screen
  ///
  /// In en, this message translates to:
  /// **'Full information about the skill'**
  String get skillFullInfo_title;

  /// Title pattern for the skill practice screen
  ///
  /// In en, this message translates to:
  /// **'Practice: {skillName}'**
  String skillPractice_titlePattern(String skillName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
