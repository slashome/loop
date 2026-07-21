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

  @override
  String get commonSave => 'Save';

  @override
  String get commonTitle => 'Title';

  @override
  String get commonDescriptionOptional => 'Description (optional)';

  @override
  String get commonNotSet => 'Not set';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonPriority => 'Priority';

  @override
  String get titleRequired => 'Title is required.';

  @override
  String get taskEditNewTitle => 'New task';

  @override
  String get taskEditEditTitle => 'Edit task';

  @override
  String taskOccurrenceOf(String title) {
    return 'Occurrence of “$title”';
  }

  @override
  String get taskEditRecurrence => 'Edit recurrence';

  @override
  String get taskDesire => 'Desire';

  @override
  String get taskImpactSelf => 'Impact on me';

  @override
  String get taskImpactOthers => 'Impact on others';

  @override
  String get taskRepeatThis => 'Repeat this task…';

  @override
  String get taskDueNone => 'Due: none';

  @override
  String taskDueOn(String date) {
    return 'Due: $date';
  }

  @override
  String priorityFull(int level) {
    return 'P$level (full)';
  }

  @override
  String priorityLabel(int level) {
    return 'P$level';
  }

  @override
  String get recurrenceNewTitle => 'New recurrence';

  @override
  String get recurrenceEditTitle => 'Edit recurrence';

  @override
  String get recurrenceFrequency => 'Frequency';

  @override
  String get recurrenceFreqDaily => 'Every day';

  @override
  String get recurrenceFreqWeekly => 'Week';

  @override
  String get recurrenceFreqMonthly => 'Month';

  @override
  String get recurrenceWeekdays => 'Days of the week';

  @override
  String get recurrenceMonthDays => 'Days of the month';

  @override
  String get recurrenceHours => 'Hours';

  @override
  String get recurrenceDefaultPriority => 'Default priority';

  @override
  String get recurrenceActive => 'Active';

  @override
  String get recurrenceActiveSubtitle => 'Generates occurrences in Actions';

  @override
  String get recurrenceAutoClean => 'Clean up missed occurrences';

  @override
  String get recurrenceAutoCleanSubtitle =>
      'Undone occurrences from before today are removed. Turn off to keep them “overdue”.';

  @override
  String get recurrencePickHour => 'Pick at least one hour.';

  @override
  String get recurrencePickWeekday => 'Pick at least one day of the week.';

  @override
  String get recurrencePickMonthDay => 'Pick at least one day of the month.';

  @override
  String recurrenceNowRecurring(String title, String suffix) {
    return '“$title” is now recurring$suffix';
  }

  @override
  String recurrenceNextSuffix(String when) {
    return ' · next: $when';
  }

  @override
  String get repeatsTitle => 'Repeats';

  @override
  String get repeatsEmpty => 'No recurrence.';

  @override
  String repeatsError(String message) {
    return 'Error: $message';
  }

  @override
  String get cadenceDaily => 'Every day';

  @override
  String cadenceWeekly(String days) {
    return 'Every $days';
  }

  @override
  String cadenceMonthly(String days) {
    return 'On the $days of the month';
  }

  @override
  String cadenceSummary(String cadence, String hours) {
    return '$cadence · $hours';
  }

  @override
  String hourShort(int hour) {
    return '${hour}h';
  }

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';
}
