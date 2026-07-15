// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Loop';

  @override
  String get navActions => 'Actions';

  @override
  String get navRepeats => 'Repeats';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get calendarComingSoon => 'Vue calendrier — à venir.';

  @override
  String get viewTodo => 'À faire';

  @override
  String get viewOverdue => 'En retard';

  @override
  String get viewUpcoming => 'À venir';

  @override
  String get viewUndated => 'Non datées';

  @override
  String get todoHint => 'en retard + aujourd\'hui';

  @override
  String get emptyList => 'Rien à afficher.';

  @override
  String get newTaskTooltip => 'Nouvelle tâche';

  @override
  String get newRecurrenceTooltip => 'Nouvelle récurrence';

  @override
  String get settingsTooltip => 'Réglages';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsDisplay => 'Affichage';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get newestAtBottomTitle => 'Prioritaire en bas';

  @override
  String get newestAtBottomSubtitle =>
      'Le plus haut score s\'affiche en bas de la liste, près du pouce. Désactive pour un ordre classique (le plus haut en haut).';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String desireShort(int count) {
    return 'envie $count/10';
  }

  @override
  String get relativeJustNow => 'À l\'instant';

  @override
  String get relativeNow => 'Maintenant';

  @override
  String relativeMinutesAgo(int count) {
    return 'Il y a $count min';
  }

  @override
  String relativeHoursAgo(int count) {
    return 'Il y a $count h';
  }

  @override
  String relativeInMinutes(int count) {
    return 'Dans $count min';
  }

  @override
  String relativeYesterdayAt(String time) {
    return 'Hier à $time';
  }

  @override
  String relativeTodayAt(String time) {
    return 'Aujourd\'hui à $time';
  }

  @override
  String relativeTomorrowAt(String time) {
    return 'Demain à $time';
  }

  @override
  String relativeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a $count jour',
    );
    return '$_temp0';
  }

  @override
  String relativeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dans $count jours',
      one: 'Dans $count jour',
    );
    return '$_temp0';
  }

  @override
  String relativeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count mois',
      one: 'Il y a $count mois',
    );
    return '$_temp0';
  }

  @override
  String relativeInMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dans $count mois',
      one: 'Dans $count mois',
    );
    return '$_temp0';
  }

  @override
  String relativeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count ans',
      one: 'Il y a $count an',
    );
    return '$_temp0';
  }

  @override
  String relativeInYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dans $count ans',
      one: 'Dans $count an',
    );
    return '$_temp0';
  }
}
