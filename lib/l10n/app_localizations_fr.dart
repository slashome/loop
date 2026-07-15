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
}
