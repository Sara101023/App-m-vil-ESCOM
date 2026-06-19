import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminRepositoryImpl implements IAdminRepository {
  static SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<Map<String, dynamic>>> getEts({
    String? carrera,
    int? semestre,
    String? materia,
  }) async {
    var query = _client.from('ets').select();
    if (carrera != null) query = query.eq('carrera', carrera);
    if (semestre != null) query = query.eq('semestre', semestre);
    if (materia != null) query = query.eq('materia', materia);
    final response = await query.order('fecha', ascending: true);
    debugPrint('ETS OBTENIDOS: ${(response as List).length}');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> crearEts(Map<String, dynamic> datos) async {
    await _client.from('ets').insert({
      'id': 'ETS-${const Uuid().v4().substring(0, 8).toUpperCase()}',
      'materia': datos['materia'],
      'carrera': datos['carrera'],
      'semestre': datos['semestre'],
      'fecha': datos['fecha'],
      'hora': datos['hora'],
      'salon': datos['salon'],
      'profesor': datos['profesor'],
      'lugares_disponibles': datos['lugares_disponibles'],
      'cupo_maximo': datos['cupo_maximo'],
    });
  }

  @override
  Future<void> actualizarEts(Map<String, dynamic> datos) async {
    await _client.from('ets').update({
      'materia': datos['materia'],
      'carrera': datos['carrera'],
      'semestre': datos['semestre'],
      'fecha': datos['fecha'],
      'hora': datos['hora'],
      'salon': datos['salon'],
      'profesor': datos['profesor'],
      'lugares_disponibles': datos['lugares_disponibles'],
      'cupo_maximo': datos['cupo_maximo'],
    }).eq('id', datos['id'] as String);
  }

  @override
  Future<void> eliminarEts(String id) async {
    await _client.from('ets').delete().eq('id', id);
  }

  @override
  Future<Map<String, int>> getEstadisticas() async {
    return {};
  }
}