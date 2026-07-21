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

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonTitle => 'Titre';

  @override
  String get commonDescriptionOptional => 'Description (optionnel)';

  @override
  String get commonNotSet => 'non défini';

  @override
  String get commonClear => 'Effacer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonPriority => 'Priorité';

  @override
  String get titleRequired => 'Le titre est obligatoire.';

  @override
  String get taskEditNewTitle => 'Nouvelle tâche';

  @override
  String get taskEditEditTitle => 'Modifier la tâche';

  @override
  String taskOccurrenceOf(String title) {
    return 'Occurrence de « $title »';
  }

  @override
  String get taskEditRecurrence => 'Modifier la récurrence';

  @override
  String get taskDesire => 'Envie';

  @override
  String get taskImpactSelf => 'Impact sur moi';

  @override
  String get taskImpactOthers => 'Impact sur les autres';

  @override
  String get taskRepeatThis => 'Répéter cette tâche…';

  @override
  String get taskDueNone => 'Échéance : aucune';

  @override
  String taskDueOn(String date) {
    return 'Échéance : $date';
  }

  @override
  String priorityFull(int level) {
    return 'P$level (complet)';
  }

  @override
  String priorityLabel(int level) {
    return 'P$level';
  }

  @override
  String get recurrenceNewTitle => 'Nouvelle récurrence';

  @override
  String get recurrenceEditTitle => 'Modifier la récurrence';

  @override
  String get recurrenceFrequency => 'Fréquence';

  @override
  String get recurrenceFreqDaily => 'Chaque jour';

  @override
  String get recurrenceFreqWeekly => 'Semaine';

  @override
  String get recurrenceFreqMonthly => 'Mois';

  @override
  String get recurrenceWeekdays => 'Jours de la semaine';

  @override
  String get recurrenceMonthDays => 'Jours du mois';

  @override
  String get recurrenceHours => 'Heures';

  @override
  String get recurrenceDefaultPriority => 'Priorité par défaut';

  @override
  String get recurrenceActive => 'Active';

  @override
  String get recurrenceActiveSubtitle => 'Génère des occurrences dans Actions';

  @override
  String get recurrenceAutoClean => 'Nettoyer les occurrences manquées';

  @override
  String get recurrenceAutoCleanSubtitle =>
      'Les occurrences non faites d\'avant aujourd\'hui sont retirées. Désactive pour les garder « en retard ».';

  @override
  String get recurrencePickHour => 'Choisis au moins une heure.';

  @override
  String get recurrencePickWeekday => 'Choisis au moins un jour de la semaine.';

  @override
  String get recurrencePickMonthDay => 'Choisis au moins un jour du mois.';

  @override
  String recurrenceNowRecurring(String title, String suffix) {
    return '« $title » est maintenant récurrente$suffix';
  }

  @override
  String recurrenceNextSuffix(String when) {
    return ' · prochaine : $when';
  }

  @override
  String get repeatsTitle => 'Repeats';

  @override
  String get repeatsEmpty => 'Aucune récurrence.';

  @override
  String repeatsError(String message) {
    return 'Erreur : $message';
  }

  @override
  String get cadenceDaily => 'Chaque jour';

  @override
  String cadenceWeekly(String days) {
    return 'Chaque $days';
  }

  @override
  String cadenceMonthly(String days) {
    return 'Le $days du mois';
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
  String get weekdayMon => 'Lun';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mer';

  @override
  String get weekdayThu => 'Jeu';

  @override
  String get weekdayFri => 'Ven';

  @override
  String get weekdaySat => 'Sam';

  @override
  String get weekdaySun => 'Dim';
}
