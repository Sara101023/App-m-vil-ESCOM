import '../repositories/i_admin_repository.dart';

class GestionarEtsUseCase {
  final IAdminRepository repository;

  GestionarEtsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> obtenerEts({
    String? carrera,
    int? semestre,
    String? materia,
  }) {
    return repository.getEts(
      carrera: carrera,
      semestre: semestre,
      materia: materia,
    );
  }

  Future<void> crear(Map<String, dynamic> datos) {
    return repository.crearEts(datos);
  }

  Future<void> actualizar(Map<String, dynamic> datos) {
    return repository.actualizarEts(datos);
  }

  Future<void> eliminar(String id) {
    return repository.eliminarEts(id);
  }
}