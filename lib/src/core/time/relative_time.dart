/// Formatage de dates en relatif « human-readable », localisé (fr/en).
library;

import '../../../l10n/app_localizations.dart';

/// Heure au format local : « 10h00 » en français, « 10:00 » sinon.
String _time(AppLocalizations l, DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return l.localeName.startsWith('fr') ? '${h}h$m' : '$h:$m';
}

/// Décrit [target] relativement à [now], dans la langue de [l].
String humanRelative(AppLocalizations l, DateTime target, DateTime now) {
  final past = target.isBefore(now);
  final diff = past ? now.difference(target) : target.difference(now);
  final mins = diff.inMinutes;
  final hours = diff.inHours;

  final targetDay = DateTime(target.year, target.month, target.day);
  final nowDay = DateTime(now.year, now.month, now.day);
  final dayDelta = targetDay.difference(nowDay).inDays;

  if (past) {
    if (mins < 1) return l.relativeJustNow;
    if (mins < 60) return l.relativeMinutesAgo(mins);
    if (dayDelta == 0) return l.relativeHoursAgo(hours);
    if (dayDelta == -1) return l.relativeYesterdayAt(_time(l, target));
    final days = -dayDelta;
    if (days < 30) return l.relativeDaysAgo(days);
    if (days < 365) return l.relativeMonthsAgo((days / 30).round());
    return l.relativeYearsAgo((days / 365).round());
  } else {
    if (mins < 1) return l.relativeNow;
    if (mins < 60) return l.relativeInMinutes(mins);
    if (dayDelta == 0) return l.relativeTodayAt(_time(l, target));
    if (dayDelta == 1) return l.relativeTomorrowAt(_time(l, target));
    if (dayDelta < 30) return l.relativeInDays(dayDelta);
    if (dayDelta < 365) return l.relativeInMonths((dayDelta / 30).round());
    return l.relativeInYears((dayDelta / 365).round());
  }
}
