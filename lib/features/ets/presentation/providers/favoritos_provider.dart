import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/ets_entity.dart';

class FavoritosNotifier extends AsyncNotifier<List<String>> {
  DatabaseHelper get _db => getIt<DatabaseHelper>();
  NotificationService get _notif => getIt<NotificationService>();

  @override
  Future<List<String>> build() async {
    final favs = await _db.getFavoritos();
    return favs.map((f) => f['ets_id'] as String).toList();
  }

  Future<void> toggleFavorito(EtsEntity ets) async {
    final ids = state.value ?? [];
    if (ids.contains(ets.id)) {
      await _db.deleteFavorito(ets.id);
    } else {
      await _db.insertFavorito({
        'ets_id': ets.id,
        'materia': ets.materia,
        'carrera': ets.carrera,
        'semestre': ets.semestre,
        'fecha': ets.fecha,
        'hora': ets.hora,
        'salon': ets.salon,
        'profesor': ets.profesor,
        'saved_at': DateTime.now().toIso8601String(),
      });
    }
    ref.invalidateSelf();
  }

  Future<void> programarNotificacion(EtsEntity ets) async {
    // Usa el hashCode del id como ID único de notificación
    final notifId = ets.id.hashCode.abs();
    await _notif.programarRecordatorio(
      id: notifId,
      materia: ets.materia,
      fecha: ets.fecha,
      hora: ets.hora,
      salon: ets.salon,
    );
  }
}

// Necesitamos el BuildContext para el Snackbar, así que lo manejamos
// desde la UI. El provider solo expone los IDs guardados.
final favoritosProvider =
    AsyncNotifierProvider<FavoritosNotifier, List<String>>(
  FavoritosNotifier.new,
);