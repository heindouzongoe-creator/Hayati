import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class NotificationService {
  static FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await Firebase.initializeApp();

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifs.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'herresso_channel',
      'Herresso Notifications',
      description: 'Notifications de la plateforme Herresso',
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _localNotifs.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _afficherNotifLocale(
          title: notification.title ?? 'Herresso',
          body: notification.body ?? '',
        );
      }
    });

    final String? token = await _fcm.getToken();
    if (token != null) {
      await _envoyerTokenAuBackend(token);
    }

    _fcm.onTokenRefresh.listen(_envoyerTokenAuBackend);
  }

  static Future<void> _envoyerTokenAuBackend(String token) async {
    try {
      await ApiService.saveFcmToken(token);
    } catch (_) {}
  }

  static Future<void> _afficherNotifLocale({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'herresso_channel',
      'Herresso Notifications',
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifs.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}

