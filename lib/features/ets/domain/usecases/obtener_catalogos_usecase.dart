import '../repositories/ets_repository.dart';

class ObtenerCatalogosUseCase {
  final EtsRepository repository;

  ObtenerCatalogosUseCase(this.repository);

  Future<List<String>> obtenerCarreras() {
    return repository.obtenerCarreras();
  }

  Future<List<String>> obtenerMaterias({
    required String carrera,
    required int semestre,
  }) {
    return repository.obtenerMaterias(carrera: carrera, semestre: semestre);
  }
}