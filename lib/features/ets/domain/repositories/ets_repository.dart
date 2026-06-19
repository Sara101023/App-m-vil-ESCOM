import '../entities/ets_entity.dart';

abstract class EtsRepository {
  Future<List<EtsEntity>> buscarEts({
    String? carrera,
    int? semestre,
    String? materia,
  });
  Future<List<String>> obtenerCarreras();
  Future<List<String>> obtenerMaterias({
    required String carrera,
    required int semestre,
  });
}