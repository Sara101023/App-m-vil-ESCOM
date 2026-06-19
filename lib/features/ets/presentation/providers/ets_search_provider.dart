import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_ets/features/ets/data/datasources/ets_mock_datasource.dart';
import 'package:app_ets/features/ets/data/repositories/ets_repository_impl.dart';
import 'package:app_ets/features/ets/domain/entities/ets_entity.dart';
import 'package:app_ets/features/ets/domain/repositories/ets_repository.dart';
import 'package:app_ets/features/ets/domain/usecases/buscar_ets_usecase.dart';
import 'package:app_ets/features/ets/domain/usecases/obtener_catalogos_usecase.dart';

// ─── ESTADO ──────────────────────────────────────────────────
class EtsSearchState {
  final String? carreraSeleccionada;
  final int? semestreSeleccionado;
  final String? materiaSeleccionada;
  final List<String> carreras;
  final List<int> semestres;
  final List<String> materias;
  final List<EtsEntity> resultados;
  final bool estaCargando;
  final String? mensajeError;
  final bool busquedaRealizada;

  const EtsSearchState({
    this.carreraSeleccionada,
    this.semestreSeleccionado,
    this.materiaSeleccionada,
    this.carreras = const [],
    this.semestres = const [],
    this.materias = const [],
    this.resultados = const [],
    this.estaCargando = false,
    this.mensajeError,
    this.busquedaRealizada = false,
  });

  EtsSearchState copyWith({
    String? carreraSeleccionada,
    int? semestreSeleccionado,
    String? materiaSeleccionada,
    List<String>? carreras,
    List<int>? semestres,
    List<String>? materias,
    List<EtsEntity>? resultados,
    bool? estaCargando,
    String? mensajeError,
    bool? busquedaRealizada,
    bool limpiarCarrera = false,
    bool limpiarSemestre = false,
    bool limpiarMateria = false,
    bool limpiarError = false,
  }) {
    return EtsSearchState(
      carreraSeleccionada: limpiarCarrera
          ? null
          : (carreraSeleccionada ?? this.carreraSeleccionada),
      semestreSeleccionado: limpiarSemestre
          ? null
          : (semestreSeleccionado ?? this.semestreSeleccionado),
      materiaSeleccionada: limpiarMateria
          ? null
          : (materiaSeleccionada ?? this.materiaSeleccionada),
      carreras: carreras ?? this.carreras,
      semestres: semestres ?? this.semestres,
      materias: materias ?? this.materias,
      resultados: resultados ?? this.resultados,
      estaCargando: estaCargando ?? this.estaCargando,
      mensajeError: limpiarError ? null : (mensajeError ?? this.mensajeError),
      busquedaRealizada: busquedaRealizada ?? this.busquedaRealizada,
    );
  }
}

// ─── NOTIFIER ─────────────────────────────────────────────────
class EtsSearchNotifier extends Notifier<EtsSearchState> {
  @override
  EtsSearchState build() {
    _cargarCarreras();
    return const EtsSearchState();
  }

  EtsRepositoryImpl get _repoImpl => ref.read(etsRepositoryProvider);
  BuscarEtsUseCase get _buscarEtsUseCase =>
      ref.read(buscarEtsUseCaseProvider);
  ObtenerCatalogosUseCase get _catalogosUseCase =>
      ref.read(obtenerCatalogosUseCaseProvider);

  Future<void> _cargarCarreras() async {
    final carreras = await _catalogosUseCase.obtenerCarreras();
    state = state.copyWith(carreras: carreras);
  }

  void seleccionarCarrera(String carrera) {
    // obtenerSemestres es síncrono y específico del datasource mock,
    // no forma parte de la interfaz EtsRepository, así que se mantiene
    // accediendo directamente a la implementación concreta.
    final semestres = _repoImpl.obtenerSemestres(carrera: carrera);
    state = state.copyWith(
      carreraSeleccionada: carrera,
      semestres: semestres,
      materias: [],
      limpiarSemestre: true,
      limpiarMateria: true,
      limpiarError: true,
    );
  }

  Future<void> seleccionarSemestre(int semestre) async {
    if (state.carreraSeleccionada == null) return;
    final materias = await _catalogosUseCase.obtenerMaterias(
      carrera: state.carreraSeleccionada!,
      semestre: semestre,
    );
    state = state.copyWith(
      semestreSeleccionado: semestre,
      materias: materias,
      limpiarMateria: true,
      limpiarError: true,
    );
  }

  void seleccionarMateria(String materia) {
    state = state.copyWith(materiaSeleccionada: materia, limpiarError: true);
  }

  Future<void> buscar() async {
    if (state.carreraSeleccionada == null) {
      state = state.copyWith(
          mensajeError: 'Por favor selecciona al menos una carrera');
      return;
    }
    state = state.copyWith(estaCargando: true, limpiarError: true);
    try {
      final resultados = await _buscarEtsUseCase.ejecutar(
        carrera: state.carreraSeleccionada,
        semestre: state.semestreSeleccionado,
        materia: state.materiaSeleccionada,
      );
      state = state.copyWith(
        resultados: resultados,
        estaCargando: false,
        busquedaRealizada: true,
      );
    } catch (e) {
      state = state.copyWith(
        estaCargando: false,
        mensajeError: e.toString().contains('internet')
            ? 'Sin conexión. Mostrando datos guardados.'
            : 'Error al buscar ETS: $e',
      );
    }
  }

  void limpiarBusqueda() {
    state = const EtsSearchState();
    _cargarCarreras();
  }
}

// ─── PROVIDERS ────────────────────────────────────────────────
final etsDatasourceProvider = Provider<EtsMockDatasource>(
  (ref) => EtsMockDatasource(),
);

final etsRepositoryProvider = Provider<EtsRepositoryImpl>(
  (ref) => EtsRepositoryImpl(ref.watch(etsDatasourceProvider)),
);

// Expone la implementación bajo el tipo de la interfaz abstracta,
// para que los casos de uso dependan solo del contrato, no del detalle.
final etsRepositoryInterfaceProvider = Provider<EtsRepository>(
  (ref) => ref.watch(etsRepositoryProvider),
);

final buscarEtsUseCaseProvider = Provider<BuscarEtsUseCase>(
  (ref) => BuscarEtsUseCase(ref.watch(etsRepositoryInterfaceProvider)),
);

final obtenerCatalogosUseCaseProvider = Provider<ObtenerCatalogosUseCase>(
  (ref) => ObtenerCatalogosUseCase(ref.watch(etsRepositoryInterfaceProvider)),
);

final etsSearchProvider =
    NotifierProvider<EtsSearchNotifier, EtsSearchState>(EtsSearchNotifier.new);