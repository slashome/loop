// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Loop';

  @override
  String get navActions => 'Actions';

  @override
  String get navRepeats => 'Repeats';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get calendarComingSoon => 'Calendar view — coming soon.';

  @override
  String get viewTodo => 'To do';

  @override
  String get viewOverdue => 'Overdue';

  @override
  String get viewUpcoming => 'Upcoming';

  @override
  String get viewUndated => 'No date';

  @override
  String get todoHint => 'overdue + today';

  @override
  String get emptyList => 'Nothing to show.';

  @override
  String get newTaskTooltip => 'New task';

  @override
  String get newRecurrenceTooltip => 'New recurrence';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDisplay => 'Display';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get newestAtBottomTitle => 'Top priority at the bottom';

  @override
  String get newestAtBottomSubtitle =>
      'The highest score shows at the bottom of the list, near your thumb. Turn off for a classic order (highest at the top).';

  @override
  String get languageSystem => 'System';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String desireShort(int count) {
    return 'desire $count/10';
  }

  @override
  String get relativeJustNow => 'Just now';

  @override
  String get relativeNow => 'Now';

  @override
  String relativeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String relativeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String relativeInMinutes(int count) {
    return 'In $count min';
  }

  @override
  String relativeYesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String relativeTodayAt(String time) {
    return 'Today at $time';
  }

  @override
  String relativeTomorrowAt(String time) {
    return 'Tomorrow at $time';
  }

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String relativeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'In $count day',
    );
    return '$_temp0';
  }

  @override
  String relativeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '$count month ago',
    );
    return '$_temp0';
  }

  @override
  String relativeInMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count months',
      one: 'In $count month',
    );
    return '$_temp0';
  }

  @override
  String relativeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '$count year ago',
    );
    return '$_temp0';
  }

  @override
  String relativeInYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count years',
      one: 'In $count year',
    );
    return '$_temp0';
  }
}
