import '../../domain/entities/ets_entity.dart';

class EtsModel extends EtsEntity {
  const EtsModel({
    required super.id,
    required super.materia,
    required super.carrera,
    required super.semestre,
    required super.fecha,
    required super.hora,
    required super.salon,
    required super.profesor,
    required super.lugaresDisponibles,
    required super.cupoMaximo,
  });

  // Para datos que vienen del mock (JSON con camelCase)
  factory EtsModel.fromJson(Map<String, dynamic> json) {
    return EtsModel(
      id: json['id'] as String,
      materia: json['materia'] as String,
      carrera: json['carrera'] as String,
      semestre: json['semestre'] as int,
      fecha: json['fecha'] as String,
      hora: json['hora'] as String,
      salon: json['salon'] as String,
      profesor: json['profesor'] as String,
      lugaresDisponibles: json['lugaresDisponibles'] as int,
      cupoMaximo: json['cupoMaximo'] as int,
    );
  }

  // Para datos que vienen de Supabase (snake_case)
  factory EtsModel.fromSupabase(Map<String, dynamic> json) {
    return EtsModel(
      id: json['id'] as String,
      materia: json['materia'] as String,
      carrera: json['carrera'] as String,
      semestre: json['semestre'] as int,
      fecha: json['fecha'] as String,
      hora: json['hora'] as String,
      salon: json['salon'] as String,
      profesor: json['profesor'] as String,
      lugaresDisponibles: json['lugares_disponibles'] as int,
      cupoMaximo: json['cupo_maximo'] as int,
    );
  }
}