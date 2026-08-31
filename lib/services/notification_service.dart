import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_car_manager/theme/app_colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String channelId = 'scadenze_channel_v2';
  static const String channelName = 'Avvisi Scadenze';

  Future<void> init() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,

      );
    } catch (e) {
      print("Errore durante l'inizializzazione delle notifiche: $e");
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String message,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Notifiche per scadenze lavori e obblighi auto',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      color: AppColors.azzurroChiaro,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: message,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
