import '../../domain/entities/alumno_entity.dart';

class AlumnoModel extends AlumnoEntity {
  const AlumnoModel({
    required super.id,
    required super.boleta,
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.carrera,
    required super.semestre,
  });

  factory AlumnoModel.fromSupabase(Map<String, dynamic> json) {
    return AlumnoModel(
      id: json['id'] as String,
      boleta: json['boleta'] as String,
      nombre: json['nombre'] as String,
      apellidoPaterno: json['apellido_paterno'] as String,
      apellidoMaterno: json['apellido_materno'] as String,
      carrera: json['carrera'] as String,
      semestre: json['semestre'] as int,
    );
  }
}