import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// True only on platforms where flutter_local_notifications works.
  static bool get _supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<void> init() async {
    if (!_supported) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_supported) return;
    const androidDetails = AndroidNotificationDetails(
      'agentry_channel',
      'Agentry Notifications',
      channelDescription: 'Payment and status notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(id, title, body, details);
  }

  static Future<void> showStatusNotification({
    required String maidName,
  }) async {
    await showNotification(
      id: maidName.hashCode,
      title: '🎉 Status Updated',
      body: '$maidName\'s status has been marked as Completed!',
    );
  }

  static Future<void> showPaymentNotification({
    required String maidName,
  }) async {
    await showNotification(
      id: 'paid_$maidName'.hashCode,
      title: '✅ Commission Settled',
      body: '$maidName\'s commission is fully paid off!',
    );
  }
}
