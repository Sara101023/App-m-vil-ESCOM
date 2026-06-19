import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  Future<void> programarRecordatorio({
    required int id,
    required String materia,
    required String fecha,
    required String hora,
    required String salon,
  }) async {
    final partesFecha = fecha.split('/');
    final partesHora = hora.split(':');
    final fechaEts = DateTime(
      int.parse(partesFecha[2]),
      int.parse(partesFecha[1]),
      int.parse(partesFecha[0]),
      int.parse(partesHora[0]),
      int.parse(partesHora[1]),
    );
    final fechaNotif = fechaEts.subtract(const Duration(days: 1));
    final fechaNotifConHora = DateTime(
      fechaNotif.year, fechaNotif.month, fechaNotif.day, 18, 0,
    );
    if (fechaNotifConHora.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id,
      'Recordatorio ETS',
      'Manana tienes ETS de $materia a las $hora en $salon',
      tz.TZDateTime.from(fechaNotifConHora, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ets_channel',
          'Recordatorios ETS',
          channelDescription: 'Alertas de examenes proximos',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelarRecordatorio(int id) async => _plugin.cancel(id);
  Future<void> cancelarTodos() async => _plugin.cancelAll();
}