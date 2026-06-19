class EtsEntity {
  final String id;
  final String materia;
  final String carrera;
  final int semestre;
  final String fecha;
  final String hora;
  final String salon;
  final String profesor;
  final int lugaresDisponibles;
  final int cupoMaximo;

  const EtsEntity({
    required this.id,
    required this.materia,
    required this.carrera,
    required this.semestre,
    required this.fecha,
    required this.hora,
    required this.salon,
    required this.profesor,
    required this.lugaresDisponibles,
    required this.cupoMaximo,
  });

  bool get tieneDisponibilidad => lugaresDisponibles > 0;
  double get porcentajeOcupacion =>
      ((cupoMaximo - lugaresDisponibles) / cupoMaximo) * 100;
}