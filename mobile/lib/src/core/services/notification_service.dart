import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> showRobotAlert(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'robot_alerts',
        'Robot alerts',
        channelDescription: 'Battery, AQI, obstacle and connection alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(DateTime.now().millisecondsSinceEpoch ~/ 1000, title, body, details);
  }
}
