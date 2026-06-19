class TurnoHelper {
  // Calcula el turno a partir de la hora en formato "HH:MM"
  static String calcularTurno(String hora) {
    try {
      final partes = hora.split(':');
      final horas = int.parse(partes[0]);
      return horas < 13 ? 'Matutino' : 'Vespertino';
    } catch (_) {
      return 'No definido';
    }
  }
}