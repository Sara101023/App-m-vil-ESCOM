class AlumnoEntity {
  final String id;
  final String boleta;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String carrera;
  final int semestre;

  const AlumnoEntity({
    required this.id,
    required this.boleta,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.carrera,
    required this.semestre,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}