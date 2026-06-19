import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/admin_provider.dart';

final statsSupabaseProvider = FutureProvider<Map<String, int>>((ref) async {
  final client = Supabase.instance.client;

  final todosEts = await client.from('ets').select('id, fecha, hora, lugares_disponibles');
  final etsLista = List<Map<String, dynamic>>.from(todosEts);
  final etsProximos = etsLista.where((e) => !esEtsPasado(e)).toList();

  final conLugares = etsProximos.where((e) => (e['lugares_disponibles'] as int) > 0).length;

  final totalAlumnos = await client.from('alumnos').select('id');
  final solicitudesPendientes = await client
      .from('solicitudes')
      .select('id')
      .eq('estado', 'pendiente');

  return {
    'total_ets': etsProximos.length,
    'con_lugares': conLugares,
    'total_alumnos': (totalAlumnos as List).length,
    'solicitudes_pendientes': (solicitudesPendientes as List).length,
  };
});

final solicitudesPendientesRealtimeProvider = StreamProvider<int>((ref) {
  final client = Supabase.instance.client;
  final controller = StreamController<int>();

  client
      .from('solicitudes')
      .select('id')
      .eq('estado', 'pendiente')
      .then((data) => controller.add((data as List).length));

  client
      .channel('solicitudes_channel')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'solicitudes',
        callback: (payload) async {
          final data = await client
              .from('solicitudes')
              .select('id')
              .eq('estado', 'pendiente');
          if (!controller.isClosed) {
            controller.add((data as List).length);
          }
        },
      )
      .subscribe();

  ref.onDispose(() {
    controller.close();
    client.channel('solicitudes_channel').unsubscribe();
  });

  return controller.stream;
});

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.background,
              pinned: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panel Administrativo',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Bienvenido, ${authState.admin?.nombre ?? 'Admin'}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Cerrar sesión',
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionTitle('Estadísticas'),
                  const SizedBox(height: 12),
                  ref
                      .watch(statsSupabaseProvider)
                      .when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                        error: (e, _) => Text(
                          'Error: $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                        data: (stats) => _buildEstadisticasGrid(context, stats),
                      ),

                  const SizedBox(height: 28),

                  _buildSectionTitle('Gestión de ETS'),
                  const SizedBox(height: 12),
                  _buildAccionCard(
                    context,
                    icon: Icons.list_alt_rounded,
                    titulo: 'Ver todos los ETS',
                    subtitulo: 'Consultar, editar y eliminar exámenes',
                    color: AppColors.primary,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/admin/ets/list'),
                  ),
                  const SizedBox(height: 12),
                  _buildAccionCard(
                    context,
                    icon: Icons.add_circle_outline_rounded,
                    titulo: 'Agregar nuevo ETS',
                    subtitulo: 'Registrar un nuevo examen en el sistema',
                    color: AppColors.accent,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/admin/ets/form'),
                  ),
                  const SizedBox(height: 12),
                  _buildAccionCard(
                    context,
                    icon: Icons.pending_actions_rounded,
                    titulo: 'Solicitudes de alumnos',
                    subtitulo: 'Revisar y responder solicitudes pendientes',
                    color: Colors.orange,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/admin/solicitudes'),
                  ),
                  const SizedBox(height: 12),
                  _buildAccionCard(
                    context,
                    icon: Icons.category_rounded,
                    titulo: 'Gestión de catálogos',
                    subtitulo: 'Administrar carreras y salones',
                    color: Colors.purple,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/admin/catalogos'),
                  ),
                  const SizedBox(height: 12),
                  _buildAccionCard(
                    context,
                    icon: Icons.people_rounded,
                    titulo: 'Gestión de alumnos',
                    subtitulo: 'Registrar, editar y eliminar alumnos',
                    color: Colors.teal,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/admin/alumnos'),
                  ),
                  const SizedBox(height: 12),
                  _buildAccionCard(
                    context,
                    icon: Icons.refresh_rounded,
                    titulo: 'Actualizar datos',
                    subtitulo: 'Recargar estadísticas',
                    color: Colors.teal,
                    onTap: () => ref.invalidate(statsSupabaseProvider),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildEstadisticasGrid(BuildContext context, Map<String, int> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total ETS',
          '${stats['total_ets'] ?? 0}',
          Icons.assignment_rounded,
          AppColors.primary,
        ),
        _buildStatCard(
          'Con lugares',
          '${stats['con_lugares'] ?? 0}',
          Icons.check_circle_outline_rounded,
          Colors.green,
        ),
        _buildStatCard(
          'Alumnos',
          '${stats['total_alumnos'] ?? 0}',
          Icons.people_rounded,
          AppColors.accent,
        ),
        const _SolicitudesCard(),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String valor,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: TextStyle(
                  color: color,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccionCard(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta de solicitudes con parpadeo en tiempo real ─────
class _SolicitudesCard extends ConsumerStatefulWidget {
  const _SolicitudesCard();

  @override
  ConsumerState<_SolicitudesCard> createState() => _SolicitudesCardState();
}

class _SolicitudesCardState extends ConsumerState<_SolicitudesCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _blinkAnim;
  int _ultimoConteo = 0;
  bool _vistoPorAdmin = false;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _blinkAnim = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _manejarCambio(int conteo) {
    if (conteo > _ultimoConteo) {
      _vistoPorAdmin = false;
      _blinkController.repeat(reverse: true);
    } else if (conteo == 0 || _vistoPorAdmin) {
      _blinkController.stop();
      _blinkController.value = 1.0;
    }
    _ultimoConteo = conteo;
  }

  @override
  Widget build(BuildContext context) {
    final solicitudesAsync = ref.watch(solicitudesPendientesRealtimeProvider);

    return solicitudesAsync.when(
      loading: () => _buildTarjeta(0),
      error: (_, _) => _buildTarjeta(0),
      data: (conteo) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _manejarCambio(conteo);
        });
        return GestureDetector(
          onTap: () {
            setState(() => _vistoPorAdmin = true);
            _blinkController.stop();
            _blinkController.value = 1.0;
            Navigator.of(context).pushNamed('/admin/solicitudes');
          },
          child: _buildTarjeta(conteo),
        );
      },
    );
  }

  Widget _buildTarjeta(int conteo) {
    final hayNuevas = conteo > 0 && !_vistoPorAdmin;
    final color = hayNuevas ? Colors.orange : AppColors.textSecondary;

    return FadeTransition(
      opacity: hayNuevas ? _blinkAnim : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hayNuevas
                ? Colors.orange.withValues(alpha: 0.5)
                : Colors.orange.withValues(alpha: 0.2),
            width: hayNuevas ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pending_actions_rounded,
                  color: Colors.orange,
                  size: 24,
                ),
                if (hayNuevas) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$conteo',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  hayNuevas ? '¡Nuevas solicitudes!' : 'Solicitudes',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
