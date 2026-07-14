/// Formatage de dates en relatif « human-readable » (français).
///
/// Exemples : « Il y a 5 min », « Dans 2 jours », « Dans 1 mois »,
/// « Demain à 10h00 », « Aujourd'hui à 10h00 », « Hier à 18h30 ».
library;

String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}h${d.minute.toString().padLeft(2, '0')}';

/// Décrit [target] relativement à [now]. Le passé donne « Il y a … » / « Hier »,
/// le futur « Dans … » / « Demain » / « Aujourd'hui à … ».
String humanRelative(DateTime target, DateTime now) {
  final past = target.isBefore(now);
  final diff = past ? now.difference(target) : target.difference(now);
  final mins = diff.inMinutes;
  final hours = diff.inHours;

  final targetDay = DateTime(target.year, target.month, target.day);
  final nowDay = DateTime(now.year, now.month, now.day);
  final dayDelta = targetDay.difference(nowDay).inDays; // 0 = aujourd'hui

  String years(int days) {
    final y = (days / 365).round();
    return '$y an${y > 1 ? 's' : ''}';
  }

  if (past) {
    if (mins < 1) return 'À l\'instant';
    if (mins < 60) return 'Il y a $mins min';
    if (dayDelta == 0) return 'Il y a $hours h';
    if (dayDelta == -1) return 'Hier à ${_hhmm(target)}';
    final days = -dayDelta;
    if (days < 30) return 'Il y a $days jours';
    if (days < 365) return 'Il y a ${(days / 30).round()} mois';
    return 'Il y a ${years(days)}';
  } else {
    if (mins < 1) return 'Maintenant';
    if (mins < 60) return 'Dans $mins min';
    if (dayDelta == 0) return 'Aujourd\'hui à ${_hhmm(target)}';
    if (dayDelta == 1) return 'Demain à ${_hhmm(target)}';
    if (dayDelta < 30) return 'Dans $dayDelta jours';
    if (dayDelta < 365) return 'Dans ${(dayDelta / 30).round()} mois';
    return 'Dans ${years(dayDelta)}';
  }
}
