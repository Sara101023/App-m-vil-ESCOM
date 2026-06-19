import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';

final solicitudesAdminProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('solicitudes')
      .select('*, ets(*), alumnos(nombre, apellido_paterno, boleta)')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

class SolicitudesAdminPage extends ConsumerWidget {
  const SolicitudesAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solicitudesAsync = ref.watch(solicitudesAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary, size: 20),
        ),
        title: const Text('Solicitudes de Alumnos',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(solicitudesAdminProvider),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: solicitudesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
        data: (solicitudes) {
          final pendientes =
              solicitudes.where((s) => s['estado'] == 'pendiente').toList();
          final resueltas =
              solicitudes.where((s) => s['estado'] != 'pendiente').toList();

          if (solicitudes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('No hay solicitudes',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendientes.isNotEmpty) ...[
                _buildSectionTitle('Pendientes (${pendientes.length})'),
                const SizedBox(height: 8),
                ...pendientes.map((s) =>
                    _buildSolicitudCard(context, ref, s, true)),
                const SizedBox(height: 20),
              ],
              if (resueltas.isNotEmpty) ...[
                _buildSectionTitle('Resueltas'),
                const SizedBox(height: 8),
                ...resueltas.map((s) =>
                    _buildSolicitudCard(context, ref, s, false)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String titulo) {
    return Text(titulo,
        style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1));
  }

  Widget _buildSolicitudCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> solicitud,
    bool mostrarAcciones,
  ) {
    final ets = solicitud['ets'] as Map<String, dynamic>;
    final alumno = solicitud['alumnos'] as Map<String, dynamic>;
    final estado = solicitud['estado'] as String;
    final mensaje = solicitud['mensaje'] as String? ?? '';

    Color estadoColor;
    switch (estado) {
      case 'aceptada':
        estadoColor = Colors.green;
        break;
      case 'rechazada':
        estadoColor = Colors.red;
        break;
      default:
        estadoColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ets['materia'] as String,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '${alumno['nombre']} ${alumno['apellido_paterno']} · ${alumno['boleta']}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  estado[0].toUpperCase() + estado.substring(1),
                  style: TextStyle(
                      color: estadoColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${ets['fecha']} · ${ets['hora']} · ${ets['salon']}',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          if (mensaje.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(mensaje,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ),
          ],
          if (mostrarAcciones) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _responderSolicitud(
                        context, ref, solicitud, 'aceptada'),
                    icon: const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white),
                    label: const Text('Aceptar',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _responderSolicitud(
                        context, ref, solicitud, 'rechazada'),
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.white),
                    label: const Text('Rechazar',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _enviarNotificacion(
    SupabaseClient client, {
    required String alumnoId,
    required String titulo,
    required String cuerpo,
  }) async {
    final alumnoData = await client
        .from('alumnos')
        .select('fcm_token')
        .eq('id', alumnoId)
        .maybeSingle();

    final fcmToken = alumnoData?['fcm_token'] as String?;
    if (fcmToken != null) {
      await client.functions.invoke(
        'enviar-notificacion',
        body: {
          'fcm_token': fcmToken,
          'titulo': titulo,
          'cuerpo': cuerpo,
        },
      );
    }
  }

  // Rechaza automáticamente las demás solicitudes pendientes de un ETS
  // que ya no tiene cupo, y les notifica a esos alumnos.
  Future<void> _autoRechazarPorFaltaDeCupo(
    SupabaseClient client,
    String etsId,
    String materia,
  ) async {
    final pendientesDelEts = await client
        .from('solicitudes')
        .select('*, alumnos(nombre)')
        .eq('ets_id', etsId)
        .eq('estado', 'pendiente');

    final lista = List<Map<String, dynamic>>.from(pendientesDelEts);

    for (final sol in lista) {
      await client
          .from('solicitudes')
          .update({'estado': 'rechazada'})
          .eq('id', sol['id'] as String);

      final alumno = sol['alumnos'] as Map<String, dynamic>?;
      final nombreAlumno = alumno?['nombre'] as String? ?? 'Alumno';

      await _enviarNotificacion(
        client,
        alumnoId: sol['alumno_id'] as String,
        titulo: '❌ ETS sin cupo disponible',
        cuerpo:
            '$nombreAlumno, disculpa, no alcanzaste cupo para $materia. Ya fue ocupado por otro alumno.',
      );
    }
  }

  Future<void> _responderSolicitud(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> solicitud,
    String nuevoEstado,
  ) async {
    final client = Supabase.instance.client;
    try {
      await client
          .from('solicitudes')
          .update({'estado': nuevoEstado})
          .eq('id', solicitud['id'] as String);

      if (nuevoEstado == 'aceptada') {
        // Verificar cupo disponible
        final etsData = await client
            .from('ets')
            .select('lugares_disponibles, cupo_maximo, materia')
            .eq('id', solicitud['ets_id'] as String)
            .single();

        final lugaresDisponibles = etsData['lugares_disponibles'] as int;
        final materia = etsData['materia'] as String;

        if (lugaresDisponibles <= 0) {
          // Revertir el estado, ya no hay cupo
          await client
              .from('solicitudes')
              .update({'estado': 'pendiente'})
              .eq('id', solicitud['id'] as String);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ No hay lugares disponibles en este ETS'),
                backgroundColor: Colors.red,
              ),
            );
          }
          ref.invalidate(solicitudesAdminProvider);
          return;
        }

        // Verificar si ya está inscrito
        final yaInscrito = await client
            .from('ets_alumno')
            .select('id')
            .eq('alumno_id', solicitud['alumno_id'] as String)
            .eq('ets_id', solicitud['ets_id'] as String)
            .maybeSingle();

        if (yaInscrito == null) {
          await client.from('ets_alumno').insert({
            'alumno_id': solicitud['alumno_id'] as String,
            'ets_id': solicitud['ets_id'] as String,
            'estado': 'inscrito',
          });

          final nuevosLugares = lugaresDisponibles - 1;

          // Decrementar lugares disponibles
          await client.from('ets').update({
            'lugares_disponibles': nuevosLugares,
          }).eq('id', solicitud['ets_id'] as String);

          // Si ya no quedan lugares, auto-rechazar las demás pendientes
          if (nuevosLugares <= 0) {
            await _autoRechazarPorFaltaDeCupo(
              client,
              solicitud['ets_id'] as String,
              materia,
            );
          }
        }
      }

      // Notificación al alumno de esta solicitud
      final alumnoData = await client
          .from('alumnos')
          .select('fcm_token, nombre')
          .eq('id', solicitud['alumno_id'] as String)
          .maybeSingle();

      final fcmToken = alumnoData?['fcm_token'] as String?;
      final nombreAlumno = alumnoData?['nombre'] as String? ?? 'Alumno';
      final ets = solicitud['ets'] as Map<String, dynamic>;
      final materiaSolicitud = ets['materia'] as String;

      if (fcmToken != null) {
        final titulo = nuevoEstado == 'aceptada'
            ? '✅ ETS Aceptado'
            : '❌ ETS Rechazado';
        final cuerpo = nuevoEstado == 'aceptada'
            ? '¡$nombreAlumno, tu solicitud de $materiaSolicitud fue aceptada!'
            : '$nombreAlumno, tu solicitud de $materiaSolicitud fue rechazada.';

        debugPrint('🔔 Invocando enviar-notificacion con token: $fcmToken');

        final resultado = await client.functions.invoke(
          'enviar-notificacion',
          body: {
            'fcm_token': fcmToken,
            'titulo': titulo,
            'cuerpo': cuerpo,
          },
        );

        debugPrint('🔔 STATUS: ${resultado.status}');
        debugPrint('🔔 DATA: ${resultado.data}');
      } else {
        debugPrint('⚠️ No hay fcmToken para este alumno, no se envía notificación');
      }

      ref.invalidate(solicitudesAdminProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nuevoEstado == 'aceptada'
                ? '✅ Solicitud aceptada y notificación enviada'
                : '❌ Solicitud rechazada y notificación enviada'),
            backgroundColor:
                nuevoEstado == 'aceptada' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}