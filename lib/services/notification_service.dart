import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'http_service.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Demande de permission (iOS surtout)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialisation notifications locales
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifs.initialize(initSettings);

    // Création du canal Android
    const AndroidNotificationChannel channel =
        AndroidNotificationChannel(
      'immofaso_channel',
      'ImmoFaso Notifications',
      description: 'Notifications de la plateforme ImmoFaso',
      importance: Importance.high,
    );

    final androidImplementation =
        _localNotifs.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(channel);

    // Écoute des messages en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        _afficherNotifLocale(
          title: notification.title ?? 'ImmoFaso',
          body: notification.body ?? '',
        );
      }
    });

    // Récupération du token FCM
    final String? token = await _fcm.getToken();
    if (token != null) {
      await _envoyerTokenAuBackend(token);
    }

    // Rafraîchissement du token
    _fcm.onTokenRefresh.listen(_envoyerTokenAuBackend);
  }

  static Future<void> _envoyerTokenAuBackend(String token) async {
    try {
      await HttpService.post(
        '/notifications/token',
        body: {'fcm_token': token},
      );
    } catch (_) {
      // silencieux volontairement
    }
  }

  static Future<void> _afficherNotifLocale({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'immofaso_channel',
      'ImmoFaso Notifications',
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

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