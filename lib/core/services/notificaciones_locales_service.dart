import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificacionesLocalesService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _inicializado = false;

  static Future<void> inicializar() async {
    if (_inicializado) return;

    tzdata.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    await _solicitarPermisos();

    const channel = AndroidNotificationChannel(
      'ets_recordatorios_channel',
      'Recordatorios de ETS',
      description: 'Recordatorios de exámenes próximos',
      importance: Importance.high,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

    _inicializado = true;
  }

  static Future<void> _solicitarPermisos() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  // Convierte un DateTime local a un TZDateTime en UTC equivalente,
  // evitando depender de bases de datos de zonas horarias con nombre.
  static tz.TZDateTime _aTzUtc(DateTime local) {
    final utc = local.toUtc();
    return tz.TZDateTime.utc(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
    );
  }

  // Convierte "DD/MM/YYYY" + "HH:MM" a DateTime
  static DateTime? _parseFechaHora(String fecha, String hora) {
    try {
      final partesFecha = fecha.split('/');
      final partesHora = hora.split(':');
      if (partesFecha.length != 3 || partesHora.length != 2) return null;

      return DateTime(
        int.parse(partesFecha[2]),
        int.parse(partesFecha[1]),
        int.parse(partesFecha[0]),
        int.parse(partesHora[0]),
        int.parse(partesHora[1]),
      );
    } catch (_) {
      return null;
    }
  }

  // Genera un ID numérico único y estable a partir del id del ETS
  static int _idNotificacion(String etsId, int sufijo) {
    return (etsId.hashCode.abs() % 1000000) * 10 + sufijo;
  }

  // Programa los recordatorios: 1 día antes a las 8pm, y 2 horas antes
  static Future<void> programarRecordatoriosEts({
    required String etsId,
    required String materia,
    required String fecha,
    required String hora,
    required String salon,
  }) async {
    await inicializar();

    final fechaHoraExamen = _parseFechaHora(fecha, hora);
    if (fechaHoraExamen == null) return;

    final ahora = DateTime.now();

    // Recordatorio 1: un día antes a las 20:00
    final unDiaAntes = DateTime(
      fechaHoraExamen.year,
      fechaHoraExamen.month,
      fechaHoraExamen.day - 1,
      20,
      0,
    );

    // Recordatorio 2: dos horas antes del examen
    final dosHorasAntes = fechaHoraExamen.subtract(const Duration(hours: 2));

    const androidDetails = AndroidNotificationDetails(
      'ets_recordatorios_channel',
      'Recordatorios de ETS',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    if (unDiaAntes.isAfter(ahora)) {
      await _plugin.zonedSchedule(
        _idNotificacion(etsId, 1),
        '📚 Examen mañana',
        'Tu ETS de $materia es mañana a las $hora en $salon',
        _aTzUtc(unDiaAntes),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (dosHorasAntes.isAfter(ahora)) {
      await _plugin.zonedSchedule(
        _idNotificacion(etsId, 2),
        '⏰ Tu examen es en 2 horas',
        'Tu ETS de $materia es a las $hora en $salon',
        _aTzUtc(dosHorasAntes),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Cancela los recordatorios de un ETS (por si el alumno se da de baja)
  static Future<void> cancelarRecordatoriosEts(String etsId) async {
    await _plugin.cancel(_idNotificacion(etsId, 1));
    await _plugin.cancel(_idNotificacion(etsId, 2));
  }
}