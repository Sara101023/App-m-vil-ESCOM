import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/gestionar_ets_usecase.dart';

// Convierte "DD/MM/YYYY" + "HH:MM" a DateTime para poder comparar
DateTime? parseFechaHoraEts(String fecha, String hora) {
  try {
    final partesFecha = fecha.split('/');
    final partesHora = hora.split(':');
    if (partesFecha.length != 3 || partesHora.length != 2) return null;

    final dia = int.parse(partesFecha[0]);
    final mes = int.parse(partesFecha[1]);
    final anio = int.parse(partesFecha[2]);
    final h = int.parse(partesHora[0]);
    final m = int.parse(partesHora[1]);

    return DateTime(anio, mes, dia, h, m);
  } catch (_) {
    return null;
  }
}

bool esEtsPasado(Map<String, dynamic> ets) {
  final fechaHora = parseFechaHoraEts(
      ets['fecha'] as String, ets['hora'] as String);
  if (fechaHora == null) return false;
  return fechaHora.isBefore(DateTime.now());
}

class AdminState {
  final List<Map<String, dynamic>> etsList;
  final bool estaCargando;
  final String? error;
  final String? mensajeExito;

  const AdminState({
    this.etsList = const [],
    this.estaCargando = false,
    this.error,
    this.mensajeExito,
  });

  // Solo ETS cuya fecha+hora todavía no ha pasado
  List<Map<String, dynamic>> get etsProximos =>
      etsList.where((e) => !esEtsPasado(e)).toList();

  // Solo ETS cuya fecha+hora ya pasó
  List<Map<String, dynamic>> get etsPasados =>
      etsList.where((e) => esEtsPasado(e)).toList();

  AdminState copyWith({
    List<Map<String, dynamic>>? etsList,
    bool? estaCargando,
    String? error,
    String? mensajeExito,
    bool limpiarError = false,
    bool limpiarExito = false,
  }) {
    return AdminState(
      etsList: etsList ?? this.etsList,
      estaCargando: estaCargando ?? this.estaCargando,
      error: limpiarError ? null : (error ?? this.error),
      mensajeExito: limpiarExito ? null : (mensajeExito ?? this.mensajeExito),
    );
  }
}

class AdminNotifier extends Notifier<AdminState> {
  @override
  AdminState build() {
    Future.microtask(() => cargarDatos());
    return const AdminState();
  }

  GestionarEtsUseCase get _gestionarEts => getIt<GestionarEtsUseCase>();

  Future<void> cargarDatos() async {
    state = state.copyWith(estaCargando: true);
    try {
      final ets = await _gestionarEts.obtenerEts();
      state = state.copyWith(etsList: ets, estaCargando: false);
    } catch (e) {
      state = state.copyWith(
          estaCargando: false, error: 'Error al cargar datos: $e');
    }
  }

  Future<void> crearEts(Map<String, dynamic> datos) async {
    try {
      await _gestionarEts.crear(datos);
      await cargarDatos();
      state = state.copyWith(mensajeExito: 'ETS creado correctamente');
    } catch (e) {
      state = state.copyWith(error: 'Error al crear ETS: $e');
    }
  }

  Future<void> actualizarEts(Map<String, dynamic> datos) async {
    try {
      await _gestionarEts.actualizar(datos);
      await cargarDatos();
      state = state.copyWith(mensajeExito: 'ETS actualizado correctamente');
    } catch (e) {
      state = state.copyWith(error: 'Error al actualizar ETS: $e');
    }
  }

  Future<void> eliminarEts(String id) async {
    try {
      await _gestionarEts.eliminar(id);
      await cargarDatos();
      state = state.copyWith(mensajeExito: 'ETS eliminado correctamente');
    } catch (e) {
      state = state.copyWith(error: 'Error al eliminar ETS: $e');
    }
  }
}

final adminProvider =
    NotifierProvider<AdminNotifier, AdminState>(AdminNotifier.new);