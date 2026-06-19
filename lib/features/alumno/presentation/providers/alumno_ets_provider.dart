import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/alumno_provider.dart';
import '../../../admin/presentation/providers/admin_provider.dart';
import '../../../../core/services/notificaciones_locales_service.dart';
import '../../../../core/database/database_helper.dart';

class AlumnoEtsState {
  final List<Map<String, dynamic>> misEts;
  final List<Map<String, dynamic>> resultadosBusqueda;
  final List<Map<String, dynamic>> solicitudes;
  final Set<String> favoritosIds;
  final List<Map<String, dynamic>> favoritos;
  final bool cargandoMisEts;
  final bool cargandoBusqueda;
  final bool hayActividadNueva;
  final bool dialogMostrado;

  const AlumnoEtsState({
    this.misEts = const [],
    this.resultadosBusqueda = const [],
    this.solicitudes = const [],
    this.favoritosIds = const {},
    this.favoritos = const [],
    this.cargandoMisEts = false,
    this.cargandoBusqueda = false,
    this.hayActividadNueva = false,
    this.dialogMostrado = false,
  });

  // Mis ETS cuya fecha+hora aún no ha pasado
  List<Map<String, dynamic>> get misEtsProximos => misEts.where((item) {
        final ets = item['ets'] as Map<String, dynamic>;
        return !esEtsPasado(ets);
      }).toList();

  // Mis ETS cuya fecha+hora ya pasó (historial)
  List<Map<String, dynamic>> get misEtsHistorial => misEts.where((item) {
        final ets = item['ets'] as Map<String, dynamic>;
        return esEtsPasado(ets);
      }).toList();

  AlumnoEtsState copyWith({
    List<Map<String, dynamic>>? misEts,
    List<Map<String, dynamic>>? resultadosBusqueda,
    List<Map<String, dynamic>>? solicitudes,
    Set<String>? favoritosIds,
    List<Map<String, dynamic>>? favoritos,
    bool? cargandoMisEts,
    bool? cargandoBusqueda,
    bool? hayActividadNueva,
    bool? dialogMostrado,
  }) {
    return AlumnoEtsState(
      misEts: misEts ?? this.misEts,
      resultadosBusqueda: resultadosBusqueda ?? this.resultadosBusqueda,
      solicitudes: solicitudes ?? this.solicitudes,
      favoritosIds: favoritosIds ?? this.favoritosIds,
      favoritos: favoritos ?? this.favoritos,
      cargandoMisEts: cargandoMisEts ?? this.cargandoMisEts,
      cargandoBusqueda: cargandoBusqueda ?? this.cargandoBusqueda,
      hayActividadNueva: hayActividadNueva ?? this.hayActividadNueva,
      dialogMostrado: dialogMostrado ?? this.dialogMostrado,
    );
  }
}

class AlumnoEtsNotifier extends Notifier<AlumnoEtsState> {
  static SupabaseClient get _client => Supabase.instance.client;

  @override
  AlumnoEtsState build() {
    final alumno = ref.watch(alumnoProvider).alumno;
    if (alumno != null) {
      Future.microtask(() => _cargarTodo(alumno.id));
    }
    return const AlumnoEtsState();
  }

  Future<void> _cargarTodo(String alumnoId) async {
    await Future.wait([
      cargarMisEts(alumnoId),
      cargarSolicitudes(alumnoId),
      cargarFavoritos(),
    ]);
    await buscarEts('');
  }

  Future<void> cargarMisEts(String alumnoId) async {
    state = state.copyWith(cargandoMisEts: true);
    try {
      final response = await _client
          .from('ets_alumno')
          .select('*, ets(*)')
          .eq('alumno_id', alumnoId);

      final lista = List<Map<String, dynamic>>.from(response);

      state = state.copyWith(
        misEts: lista,
        cargandoMisEts: false,
      );

      // Programar recordatorios locales para los ETS próximos
      for (final item in lista) {
        final ets = item['ets'] as Map<String, dynamic>;
        if (!esEtsPasado(ets)) {
          await NotificacionesLocalesService.programarRecordatoriosEts(
            etsId: ets['id'] as String,
            materia: ets['materia'] as String,
            fecha: ets['fecha'] as String,
            hora: ets['hora'] as String,
            salon: ets['salon'] as String,
          );
        }
      }
    } catch (_) {
      state = state.copyWith(cargandoMisEts: false);
    }
  }

  Future<void> cargarSolicitudes(String alumnoId) async {
    try {
      final response = await _client
          .from('solicitudes')
          .select('*, ets(*)')
          .eq('alumno_id', alumnoId)
          .order('created_at', ascending: false);

      final lista = List<Map<String, dynamic>>.from(response);

      final prefs = await SharedPreferences.getInstance();
      final key = 'solicitudes_vistas_$alumnoId';
      final ultimaVezStr = prefs.getString(key);

      debugPrint('KEY USADA: $key');
      debugPrint('ULTIMA VEZ LEIDA: $ultimaVezStr');

      final ultimaVez = ultimaVezStr != null
          ? DateTime.tryParse(ultimaVezStr)
          : null;

      bool hayNueva = false;
      for (final s in lista) {
        final estado = s['estado'] as String;
        if (estado == 'aceptada' || estado == 'rechazada') {
          final updatedAt = DateTime.tryParse(
              s['updated_at'] as String? ?? s['created_at'] as String);
          if (updatedAt != null) {
            if (ultimaVez == null || updatedAt.isAfter(ultimaVez)) {
              hayNueva = true;
              break;
            }
          }
        }
      }

      state = state.copyWith(
        solicitudes: lista,
        hayActividadNueva: hayNueva,
      );
    } catch (e) {
      debugPrint('ERROR cargarSolicitudes: $e');
    }
  }

  Future<void> marcarSolicitudesComoVistas(String alumnoId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'solicitudes_vistas_$alumnoId';
    await prefs.setString(key, DateTime.now().toIso8601String());

    state = state.copyWith(
      hayActividadNueva: false,
      dialogMostrado: true,
    );
  }

  Future<void> buscarEts(String materia) async {
    final alumno = ref.read(alumnoProvider).alumno;
    if (alumno == null) return;

    state = state.copyWith(cargandoBusqueda: true);
    try {
      final semestreMin = (alumno.semestre - 2).clamp(1, 8);
      final semestreMax = (alumno.semestre + 2).clamp(1, 8);

      var query = _client
          .from('ets')
          .select()
          .eq('carrera', alumno.carrera)
          .gte('semestre', semestreMin)
          .lte('semestre', semestreMax)
          .gt('lugares_disponibles', 0);
      if (materia.isNotEmpty) {
        query = query.ilike('materia', '%$materia%');
      }

      final response = await query.order('semestre', ascending: true);

      final etsInscritos = state.misEts
          .map((e) => (e['ets'] as Map<String, dynamic>)['id'] as String)
          .toSet();

      final etsSolicitados = state.solicitudes
          .where((s) =>
              s['estado'] == 'pendiente' || s['estado'] == 'aceptada')
          .map((s) => s['ets_id'] as String)
          .toSet();

      final filtrados = (response as List)
          .map((e) => e as Map<String, dynamic>)
          .where((e) =>
              !etsInscritos.contains(e['id'] as String) &&
              !etsSolicitados.contains(e['id'] as String) &&
              !esEtsPasado(e)) // excluir ETS cuya fecha ya pasó
          .toList();

      state = state.copyWith(
        resultadosBusqueda: filtrados,
        cargandoBusqueda: false,
      );
    } catch (_) {
      state = state.copyWith(cargandoBusqueda: false);
    }
  }

  Future<void> crearSolicitud({
    required String alumnoId,
    required String etsId,
    String? mensaje,
  }) async {
    try {
      final etsData = await _client
          .from('ets')
          .select('lugares_disponibles, materia')
          .eq('id', etsId)
          .single();

      final lugaresDisponibles = etsData['lugares_disponibles'] as int;
      if (lugaresDisponibles <= 0) {
        throw Exception('No hay lugares disponibles para este ETS');
      }

      await _client.from('solicitudes').insert({
        'alumno_id': alumnoId,
        'ets_id': etsId,
        'estado': 'pendiente',
        'mensaje': mensaje ?? '',
      });
      await cargarSolicitudes(alumnoId);
    } catch (_) {
      rethrow;
    }
  }
  Future<void> cargarFavoritos() async {
    try {
      final lista = await DatabaseHelper().getFavoritos();
      final ids = lista.map((f) => f['ets_id'] as String).toSet();
      state = state.copyWith(favoritos: lista, favoritosIds: ids);
    } catch (_) {
      // Si falla la carga local, no rompemos el flujo principal
    }
  }

  Future<void> toggleFavorito(Map<String, dynamic> ets) async {
    final etsId = ets['id'] as String;
    final yaEsFavorito = state.favoritosIds.contains(etsId);

    try {
      if (yaEsFavorito) {
        await DatabaseHelper().deleteFavorito(etsId);
      } else {
        await DatabaseHelper().insertFavorito({
          'ets_id': etsId,
          'materia': ets['materia'] as String,
          'carrera': ets['carrera'] as String,
          'semestre': ets['semestre'] as int,
          'fecha': ets['fecha'] as String,
          'hora': ets['hora'] as String,
          'salon': ets['salon'] as String,
          'profesor': ets['profesor'] as String,
          'saved_at': DateTime.now().toIso8601String(),
        });
      }
      await cargarFavoritos();
    } catch (_) {
      // Si falla, el estado de favoritos simplemente no se actualiza
    }
  }

  bool esFavorito(String etsId) => state.favoritosIds.contains(etsId);
}

final alumnoEtsProvider =
    NotifierProvider<AlumnoEtsNotifier, AlumnoEtsState>(
  AlumnoEtsNotifier.new,
);