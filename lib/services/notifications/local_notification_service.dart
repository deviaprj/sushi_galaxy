import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const int _fullLivesNotificationId = 1001;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleLivesRefilledNotification(Duration delay) async {
    if (delay.isNegative || delay.inSeconds <= 0) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'lives_channel',
      'Lives',
      channelDescription: 'Notifie lorsque les vies sont pleines',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      _fullLivesNotificationId,
      'Vies pleines !',
      'Tes vies sont rechargées, reviens jouer à Sushi Galaxy.',
      tz.TZDateTime.now(tz.local).add(delay),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'lives_full',
    );
  }

  Future<void> cancelLivesRefilledNotification() async {
    await _plugin.cancel(_fullLivesNotificationId);
  }
}
