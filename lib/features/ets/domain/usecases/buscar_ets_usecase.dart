import '../entities/ets_entity.dart';
import '../repositories/ets_repository.dart';

class BuscarEtsUseCase {
  final EtsRepository repository;

  BuscarEtsUseCase(this.repository);

  Future<List<EtsEntity>> ejecutar({
    String? carrera,
    int? semestre,
    String? materia,
  }) {
    return repository.buscarEts(
      carrera: carrera,
      semestre: semestre,
      materia: materia,
    );
  }
}