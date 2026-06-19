import '../../domain/entities/ets_entity.dart';
import '../../domain/repositories/ets_repository.dart';
import '../datasources/ets_mock_datasource.dart';
import '../../../../core/network/api_client.dart';

class EtsRepositoryImpl implements EtsRepository {
  final EtsMockDatasource _datasource;
  const EtsRepositoryImpl(this._datasource);

  @override
  Future<List<EtsEntity>> buscarEts({
    String? carrera,
    int? semestre,
    String? materia,
  }) async {
    try {
      // Intenta Supabase primero
      return await ApiClient.buscarEts(
        carrera: carrera,
        semestre: semestre,
        materia: materia,
      );
    } catch (_) {
      // Fallback al mock si no hay internet
      return _datasource.buscarEts(
        carrera: carrera,
        semestre: semestre,
        materia: materia,
      );
    }
  }

  @override
  Future<List<String>> obtenerCarreras() async {
    return _datasource.obtenerCarreras();
  }

  @override
  Future<List<String>> obtenerMaterias({
    required String carrera,
    required int semestre,
  }) async {
    return _datasource.obtenerMaterias(carrera: carrera, semestre: semestre);
  }

  List<int> obtenerSemestres({required String carrera}) {
    return _datasource.obtenerSemestres(carrera: carrera);
  }
}