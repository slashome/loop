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

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commonTitle;

  /// No description provided for @commonDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get commonDescriptionOptional;

  /// No description provided for @commonNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get commonNotSet;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get commonPriority;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required.'**
  String get titleRequired;

  /// No description provided for @taskEditNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get taskEditNewTitle;

  /// No description provided for @taskEditEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get taskEditEditTitle;

  /// No description provided for @taskOccurrenceOf.
  ///
  /// In en, this message translates to:
  /// **'Occurrence of “{title}”'**
  String taskOccurrenceOf(String title);

  /// No description provided for @taskEditRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Edit recurrence'**
  String get taskEditRecurrence;

  /// No description provided for @taskDesire.
  ///
  /// In en, this message translates to:
  /// **'Desire'**
  String get taskDesire;

  /// No description provided for @taskImpactSelf.
  ///
  /// In en, this message translates to:
  /// **'Impact on me'**
  String get taskImpactSelf;

  /// No description provided for @taskImpactOthers.
  ///
  /// In en, this message translates to:
  /// **'Impact on others'**
  String get taskImpactOthers;

  /// No description provided for @taskRepeatThis.
  ///
  /// In en, this message translates to:
  /// **'Repeat this task…'**
  String get taskRepeatThis;

  /// No description provided for @taskDueNone.
  ///
  /// In en, this message translates to:
  /// **'Due: none'**
  String get taskDueNone;

  /// No description provided for @taskDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String taskDueOn(String date);

  /// No description provided for @priorityFull.
  ///
  /// In en, this message translates to:
  /// **'P{level} (full)'**
  String priorityFull(int level);

  /// No description provided for @priorityLabel.
  ///
  /// In en, this message translates to:
  /// **'P{level}'**
  String priorityLabel(int level);

  /// No description provided for @recurrenceNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New recurrence'**
  String get recurrenceNewTitle;

  /// No description provided for @recurrenceEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit recurrence'**
  String get recurrenceEditTitle;

  /// No description provided for @recurrenceFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurrenceFrequency;

  /// No description provided for @recurrenceFreqDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get recurrenceFreqDaily;

  /// No description provided for @recurrenceFreqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get recurrenceFreqWeekly;

  /// No description provided for @recurrenceFreqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get recurrenceFreqMonthly;

  /// No description provided for @recurrenceWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get recurrenceWeekdays;

  /// No description provided for @recurrenceMonthDays.
  ///
  /// In en, this message translates to:
  /// **'Days of the month'**
  String get recurrenceMonthDays;

  /// No description provided for @recurrenceHours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get recurrenceHours;

  /// No description provided for @recurrenceDefaultPriority.
  ///
  /// In en, this message translates to:
  /// **'Default priority'**
  String get recurrenceDefaultPriority;

  /// No description provided for @recurrenceActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get recurrenceActive;

  /// No description provided for @recurrenceActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generates occurrences in Actions'**
  String get recurrenceActiveSubtitle;

  /// No description provided for @recurrenceAutoClean.
  ///
  /// In en, this message translates to:
  /// **'Clean up missed occurrences'**
  String get recurrenceAutoClean;

  /// No description provided for @recurrenceAutoCleanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Undone occurrences from before today are removed. Turn off to keep them “overdue”.'**
  String get recurrenceAutoCleanSubtitle;

  /// No description provided for @recurrencePickHour.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one hour.'**
  String get recurrencePickHour;

  /// No description provided for @recurrencePickWeekday.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day of the week.'**
  String get recurrencePickWeekday;

  /// No description provided for @recurrencePickMonthDay.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day of the month.'**
  String get recurrencePickMonthDay;

  /// No description provided for @recurrenceNowRecurring.
  ///
  /// In en, this message translates to:
  /// **'“{title}” is now recurring{suffix}'**
  String recurrenceNowRecurring(String title, String suffix);

  /// No description provided for @recurrenceNextSuffix.
  ///
  /// In en, this message translates to:
  /// **' · next: {when}'**
  String recurrenceNextSuffix(String when);

  /// No description provided for @repeatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeatsTitle;

  /// No description provided for @repeatsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recurrence.'**
  String get repeatsEmpty;

  /// No description provided for @repeatsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String repeatsError(String message);

  /// No description provided for @cadenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get cadenceDaily;

  /// No description provided for @cadenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every {days}'**
  String cadenceWeekly(String days);

  /// No description provided for @cadenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'On the {days} of the month'**
  String cadenceMonthly(String days);

  /// No description provided for @cadenceSummary.
  ///
  /// In en, this message translates to:
  /// **'{cadence} · {hours}'**
  String cadenceSummary(String cadence, String hours);

  /// No description provided for @hourShort.
  ///
  /// In en, this message translates to:
  /// **'{hour}h'**
  String hourShort(int hour);

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;
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
