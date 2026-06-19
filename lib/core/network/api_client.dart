import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/ets/data/models/ets_model.dart';

class ApiClient {
  ApiClient._();

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<List<EtsModel>> buscarEts({
    String? carrera,
    int? semestre,
    String? materia,
  }) async {
    try {
      var query = _client
          .from('ets')
          .select();

      if (carrera != null && carrera.isNotEmpty) {
        query = query.eq('carrera', carrera);
      }
      if (semestre != null) {
        query = query.eq('semestre', semestre);
      }
      if (materia != null && materia.isNotEmpty) {
        query = query.eq('materia', materia);
      }

      final response = await query
          .order('fecha', ascending: true)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw Exception('Sin conexión. Mostrando datos guardados.'),
          );

      return (response as List)
          .map((e) => EtsModel.fromSupabase(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}