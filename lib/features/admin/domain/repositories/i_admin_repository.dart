abstract class IAdminRepository {
  Future<List<Map<String, dynamic>>> getEts({
    String? carrera,
    int? semestre,
    String? materia,
  });

  Future<void> crearEts(Map<String, dynamic> datos);

  Future<void> actualizarEts(Map<String, dynamic> datos);

  Future<void> eliminarEts(String id);

  Future<Map<String, int>> getEstadisticas();
}