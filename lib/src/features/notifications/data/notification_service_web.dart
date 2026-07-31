import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../domain/reminder.dart';
import 'notification_service.dart';

/// Web backend using the browser Notification API. Reminders are held as
/// in-memory timers, so they fire only while the Loop tab is open — a browser
/// cannot deliver a local notification for a closed tab without a service
/// worker + push server, which would no longer be "local". Callers therefore
/// pass a short horizon.
class WebNotificationService implements NotificationService {
  final Map<int, _Scheduled> _timers = {};

  @override
  bool get isSupported => true;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async {
    final result = (await web.Notification.requestPermission().toDart).toDart;
    return result == 'granted';
  }

  @override
  Future<void> sync(List<Reminder> reminders) async {
    final desired = {for (final r in reminders) r.notificationId: r};

    // Drop timers no longer wanted.
    for (final id in _timers.keys.toList()) {
      if (!desired.containsKey(id)) {
        _timers.remove(id)!.timer.cancel();
      }
    }

    // (Re)arm new or changed reminders.
    final now = DateTime.now();
    for (final r in desired.values) {
      final existing = _timers[r.notificationId];
      if (existing != null && existing.reminder.sameSchedule(r)) continue;
      existing?.timer.cancel();
      final delay = r.when.difference(now);
      final timer = Timer(delay.isNegative ? Duration.zero : delay, () {
        _timers.remove(r.notificationId);
        _fire(r);
      });
      _timers[r.notificationId] = _Scheduled(timer, r);
    }
  }

  void _fire(Reminder r) {
    if (web.Notification.permission != 'granted') return;
    web.Notification(
      r.title,
      web.NotificationOptions(
        body: r.body,
        tag: 'loop-${r.notificationId}',
      ),
    );
  }

  @override
  Future<void> cancelAll() async {
    for (final s in _timers.values) {
      s.timer.cancel();
    }
    _timers.clear();
  }
}

class _Scheduled {
  _Scheduled(this.timer, this.reminder);
  final Timer timer;
  final Reminder reminder;
}

NotificationService createNotificationService() => WebNotificationService();
