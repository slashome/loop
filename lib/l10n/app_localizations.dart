import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get appTitle;

  /// No description provided for @navActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get navActions;

  /// No description provided for @navRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get navRepeats;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @calendarComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Calendar view — coming soon.'**
  String get calendarComingSoon;

  /// No description provided for @viewTodo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get viewTodo;

  /// No description provided for @viewOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get viewOverdue;

  /// No description provided for @viewUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get viewUpcoming;

  /// No description provided for @viewUndated.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get viewUndated;

  /// No description provided for @todoHint.
  ///
  /// In en, this message translates to:
  /// **'overdue + today'**
  String get todoHint;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show.'**
  String get emptyList;

  /// No description provided for @newTaskTooltip.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskTooltip;

  /// No description provided for @newRecurrenceTooltip.
  ///
  /// In en, this message translates to:
  /// **'New recurrence'**
  String get newRecurrenceTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplay;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @newestAtBottomTitle.
  ///
  /// In en, this message translates to:
  /// **'Top priority at the bottom'**
  String get newestAtBottomTitle;

  /// No description provided for @newestAtBottomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The highest score shows at the bottom of the list, near your thumb. Turn off for a classic order (highest at the top).'**
  String get newestAtBottomSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @desireShort.
  ///
  /// In en, this message translates to:
  /// **'desire {count}/10'**
  String desireShort(int count);

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeJustNow;

  /// No description provided for @relativeNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get relativeNow;

  /// No description provided for @relativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String relativeMinutesAgo(int count);

  /// No description provided for @relativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String relativeHoursAgo(int count);

  /// No description provided for @relativeInMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {count} min'**
  String relativeInMinutes(int count);

  /// No description provided for @relativeYesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String relativeYesterdayAt(String time);

  /// No description provided for @relativeTodayAt.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String relativeTodayAt(String time);

  /// No description provided for @relativeTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow at {time}'**
  String relativeTomorrowAt(String time);

  /// No description provided for @relativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day ago} other{{count} days ago}}'**
  String relativeDaysAgo(int count);

  /// No description provided for @relativeInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{In {count} day} other{In {count} days}}'**
  String relativeInDays(int count);

  /// No description provided for @relativeMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} month ago} other{{count} months ago}}'**
  String relativeMonthsAgo(int count);

  /// No description provided for @relativeInMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{In {count} month} other{In {count} months}}'**
  String relativeInMonths(int count);

  /// No description provided for @relativeYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} year ago} other{{count} years ago}}'**
  String relativeYearsAgo(int count);

  /// No description provided for @relativeInYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{In {count} year} other{In {count} years}}'**
  String relativeInYears(int count);
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
