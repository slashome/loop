/// Business model of a recurrence definition — PURE (no Flutter/Drift
/// dependency), like [Task].
///
/// RRULE-style structured cadence ("rrule or equivalent", a design
/// decision), all dimensions being multiple:
///   - [byWeekdays]: weekdays (BYDAY) for [RecurrenceFreq.weekly];
///   - [byMonthDays]: days of the month (BYMONTHDAY) for [RecurrenceFreq.monthly];
///   - [byHours]: hours within the day (BYHOUR), all frequencies.
/// [rrule] keeps the equivalent string for the future full parser.
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
    this.autoCleanMissed = true,
    this.deletedAt,
  });

  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final RecurrenceFreq freq;

  /// Weekdays 1..7 (Mon..Sun), for [RecurrenceFreq.weekly].
  final List<int> byWeekdays;

  /// Days of the month 1..31, for [RecurrenceFreq.monthly].
  final List<int> byMonthDays;

  /// Occurrence hours within the day (e.g. [10, 22] = twice a day).
  final List<int> byHours;
  final int byMinute;

  final String? rrule;
  final DateTime dtstart;
  final String timezone;
  final DateTime? nextOccurrence;
  final int defPriority;
  final bool active;

  /// If true, missed occurrences (due before today, not done) are
  /// auto-deleted at startup. Otherwise they remain "overdue".
  final bool autoCleanMissed;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Occurrences of this model for the day of [day] (time ignored in input).
  ///
  /// Minimal generator (daily/weekly/monthly) — will be replaced by a real
  /// RRULE engine when we build the Repeats tab.
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

  /// Next occurrence from [from] (inclusive), or `null` if none in the
  /// coming year. Useful to show "next: …" after creation.
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
