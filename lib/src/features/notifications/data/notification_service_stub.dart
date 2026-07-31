import '../domain/reminder.dart';
import 'notification_service.dart';

/// No-op backend for platforms without a notification implementation. Keeps the
/// rest of the app oblivious to platform support.
class StubNotificationService implements NotificationService {
  @override
  bool get isSupported => false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> sync(List<Reminder> reminders) async {}

  @override
  Future<void> cancelAll() async {}
}

NotificationService createNotificationService() => StubNotificationService();
