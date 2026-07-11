/// Modèle métier d'une définition de récurrence — PUR (aucune dépendance
/// Flutter/Drift), comme [Task].
///
/// Cadence structurée façon RRULE (« rrule ou équivalent », décision de
/// design), toutes les dimensions multiples :
///   - [byWeekdays] : jours de semaine (BYDAY) pour [RecurrenceFreq.weekly] ;
///   - [byMonthDays] : jours du mois (BYMONTHDAY) pour [RecurrenceFreq.monthly] ;
///   - [byHours] : heures dans la journée (BYHOUR), toutes fréquences.
/// [rrule] garde la chaîne équivalente pour le futur parseur complet.
library;

enum RecurrenceFreq { daily, weekly, monthly }

class Recurrence {
  const Recurrence({
    required this.id,
    required this.title,
    required this.freq,
    required this.dtstart,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId = 'local',
    this.description,
    this.byWeekdays = const [],
    this.byMonthDays = const [],
    this.byHours = const [9],
    this.byMinute = 0,
    this.rrule,
    this.timezone = 'Europe/Paris',
    this.nextOccurrence,
    this.defPriority = 3,
    this.active = true,
    this.deletedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final RecurrenceFreq freq;

  /// Jours de semaine 1..7 (lun..dim), pour [RecurrenceFreq.weekly].
  final List<int> byWeekdays;

  /// Jours du mois 1..31, pour [RecurrenceFreq.monthly].
  final List<int> byMonthDays;

  /// Heures d'occurrence dans la journée (ex: [10, 22] = deux fois par jour).
  final List<int> byHours;
  final int byMinute;

  final String? rrule;
  final DateTime dtstart;
  final String timezone;
  final DateTime? nextOccurrence;
  final int defPriority;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Occurrences de ce modèle pour le jour de [day] (heure ignorée en entrée).
  ///
  /// Générateur minimal (daily/weekly/monthly) — sera remplacé par un vrai
  /// moteur RRULE quand on construira l'onglet Repeats.
  List<DateTime> occurrencesOn(DateTime day) {
    final matches = switch (freq) {
      RecurrenceFreq.daily => true,
      RecurrenceFreq.weekly => byWeekdays.contains(day.weekday),
      RecurrenceFreq.monthly => byMonthDays.contains(day.day),
    };
    if (!matches) return const [];
    return [
      for (final h in byHours)
        DateTime(day.year, day.month, day.day, h, byMinute),
    ];
  }

  /// Prochaine occurrence à partir de [from] (incluse), ou `null` si aucune
  /// dans l'année à venir. Utile pour informer « prochaine : … » après création.
  DateTime? nextOccurrenceFrom(DateTime from) {
    final start = DateTime(from.year, from.month, from.day);
    for (var i = 0; i < 400; i++) {
      final day = start.add(Duration(days: i));
      for (final o in occurrencesOn(day)) {
        if (!o.isBefore(from)) return o;
      }
    }
    return null;
  }
}
