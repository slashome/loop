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
}
