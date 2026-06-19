import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../../../features/ets/domain/entities/ets_entity.dart';
import '../../../auth/presentation/providers/alumno_provider.dart';
import '../providers/alumno_ets_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/turno_helper.dart';
import '../../../../core/services/connectivity_service.dart';

class AlumnoHomePage extends ConsumerStatefulWidget {
  const AlumnoHomePage({super.key});

  @override
  ConsumerState<AlumnoHomePage> createState() => _AlumnoHomePageState();
}

class _AlumnoHomePageState extends ConsumerState<AlumnoHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _contactarSoporte(BuildContext context) async {
    final alumno = ref.read(alumnoProvider).alumno;
    final uri = Uri(
      scheme: 'mailto',
      path: 'soporte.ets@escom.ipn.mx',
      query:
          'subject=Soporte ETS - Boleta ${alumno?.boleta ?? ''}&body=Hola, necesito ayuda con...',
    );

    try {
      final lanzado = await launchUrl(uri);
      if (!lanzado && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró una app de correo instalada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir correo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumno = ref.watch(alumnoProvider).alumno!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${alumno.nombre}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Boleta: ${alumno.boleta}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _contactarSoporte(context),
                    icon: const Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Contactar soporte',
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(alumnoProvider.notifier).logout();
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
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${alumno.carrera.split(' - ').first} · Semestre ${alumno.semestre}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Consumer(
              builder: (context, ref, _) {
                final conectado = ref.watch(conectividadProvider);
                if (conectado) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sin conexión a internet. Mostrando la última información disponible.',
                          style: TextStyle(
                              color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

          
              TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                const Tab(text: 'Mis ETS'),
                const Tab(text: 'Buscar'),
                const Tab(text: 'Favoritos'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Solicitudes'),
                      const SizedBox(width: 4),
                      Consumer(
                        builder: (context, ref, _) {
                          final hayNueva = ref
                              .watch(alumnoEtsProvider)
                              .hayActividadNueva;
                          if (!hayNueva) return const SizedBox.shrink();
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MisEtsTab(alumnoId: alumno.id),
                  _BuscarEtsTab(alumnoId: alumno.id),
                  const _FavoritosTab(),
                  _SolicitudesTab(alumnoId: alumno.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══ TAB 1: MIS ETS ══════════════════════════════════════════
// ══ TAB 1: MIS ETS ══════════════════════════════════════════
class _MisEtsTab extends ConsumerStatefulWidget {
  final String alumnoId;
  const _MisEtsTab({required this.alumnoId});

  @override
  ConsumerState<_MisEtsTab> createState() => _MisEtsTabState();
}

class _MisEtsTabState extends ConsumerState<_MisEtsTab> {
  bool _mostrarHistorial = false;

  @override
  Widget build(BuildContext context) {
    final etsState = ref.watch(alumnoEtsProvider);
    final alumno = ref.watch(alumnoProvider).alumno;

    if (etsState.cargandoMisEts) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final lista = _mostrarHistorial
        ? etsState.misEtsHistorial
        : etsState.misEtsProximos;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: _buildToggleBtn(
                  titulo: 'Próximos',
                  seleccionado: !_mostrarHistorial,
                  onTap: () => setState(() => _mostrarHistorial = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildToggleBtn(
                  titulo: 'Historial',
                  seleccionado: _mostrarHistorial,
                  onTap: () => setState(() => _mostrarHistorial = true),
                ),
              ),
            ],
          ),
        ),
        if (!_mostrarHistorial && etsState.misEtsProximos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final listaParaPdf = etsState.misEtsProximos.map((item) {
                      final ets = item['ets'] as Map<String, dynamic>;
                      return EtsEntity(
                        id: ets['id'] as String,
                        materia: ets['materia'] as String,
                        carrera: ets['carrera'] as String,
                        semestre: ets['semestre'] as int,
                        fecha: ets['fecha'] as String,
                        hora: ets['hora'] as String,
                        salon: ets['salon'] as String,
                        profesor: ets['profesor'] as String,
                        lugaresDisponibles: ets['lugares_disponibles'] as int,
                        cupoMaximo: ets['cupo_maximo'] as int,
                      );
                    }).toList();

                    await PdfGenerator.generarYMostrarPdf(
                      listaParaPdf,
                      nombreAlumno: alumno != null
                          ? '${alumno.nombre} ${alumno.apellidoPaterno} ${alumno.apellidoMaterno}'
                          : null,
                      boleta: alumno?.boleta,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al generar PDF: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Exportar mis ETS en PDF',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        Expanded(
          child: lista.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _mostrarHistorial
                            ? 'Sin exámenes en tu historial'
                            : 'No tienes ETS próximos',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!_mostrarHistorial) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Ve a "Buscar" para solicitar uno',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    final ets = item['ets'] as Map<String, dynamic>;
                    return _EtsAlumnoCard(ets: ets);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildToggleBtn({
    required String titulo,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          titulo,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: seleccionado ? AppColors.primary : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ══ TAB 2: BUSCAR ETS ═══════════════════════════════════════
class _BuscarEtsTab extends ConsumerStatefulWidget {
  final String alumnoId;
  const _BuscarEtsTab({required this.alumnoId});

  @override
  ConsumerState<_BuscarEtsTab> createState() => _BuscarEtsTabState();
}

class _BuscarEtsTabState extends ConsumerState<_BuscarEtsTab> {
  final _buscarCtrl = TextEditingController();

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final etsState = ref.watch(alumnoEtsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _buscarCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar por materia...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: IconButton(
                  onPressed: () {
                    ref
                        .read(alumnoEtsProvider.notifier)
                        .buscarEts(_buscarCtrl.text.trim());
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              onSubmitted: (val) {
                ref.read(alumnoEtsProvider.notifier).buscarEts(val.trim());
              },
            ),
          ),
        ),
        Expanded(
          child: etsState.cargandoBusqueda
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : etsState.resultadosBusqueda.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 48,
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No hay ETS disponibles',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: etsState.resultadosBusqueda.length,
                  itemBuilder: (context, index) {
                    final ets = etsState.resultadosBusqueda[index];
                    return _EtsDisponibleCard(
                      ets: ets,
                      onSolicitar: () =>
                          _mostrarDialogoSolicitud(context, ref, ets),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _mostrarDialogoSolicitud(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> ets,
  ) {
    final mensajeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Solicitar ETS',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ets['materia'] as String,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mensaje (opcional):',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: mensajeCtrl,
                maxLines: 3,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: const InputDecoration(
                  hintText: 'Explica por qué necesitas este ETS...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(alumnoEtsProvider.notifier)
                    .crearSolicitud(
                      alumnoId: widget.alumnoId,
                      etsId: ets['id'] as String,
                      mensaje: mensajeCtrl.text.trim(),
                    );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Solicitud enviada al administrador'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Solicitar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ══ TAB: FAVORITOS ══════════════════════════════════════════
class _FavoritosTab extends ConsumerWidget {
  const _FavoritosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritos = ref.watch(alumnoEtsProvider).favoritos;

    if (favoritos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin ETS favoritos',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Marca con ⭐ los ETS que te interesen en "Buscar"',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final fav = favoritos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fav['materia'] as String,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fav['fecha']} · ${fav['hora']} · ${fav['salon']}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(alumnoEtsProvider.notifier).toggleFavorito(fav),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 20,
                ),
                tooltip: 'Quitar de favoritos',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══ TAB 3: SOLICITUDES ══════════════════════════════════════
class _SolicitudesTab extends ConsumerStatefulWidget {
  final String alumnoId;
  const _SolicitudesTab({required this.alumnoId});

  @override
  ConsumerState<_SolicitudesTab> createState() => _SolicitudesTabState();
}

class _SolicitudesTabState extends ConsumerState<_SolicitudesTab> {
  @override
  Widget build(BuildContext context) {
    final etsState = ref.watch(alumnoEtsProvider);

    if (etsState.hayActividadNueva &&
        !etsState.dialogMostrado &&
        etsState.solicitudes.isNotEmpty) {
      final respuestas = etsState.solicitudes
          .where((s) => s['estado'] == 'aceptada' || s['estado'] == 'rechazada')
          .toList();

      if (respuestas.isNotEmpty) {
        final ultima = respuestas.first;
        final esAceptada = ultima['estado'] == 'aceptada';
        final materia =
            (ultima['ets'] as Map<String, dynamic>)['materia'] as String;

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!context.mounted) return;
          ref
              .read(alumnoEtsProvider.notifier)
              .marcarSolicitudesComoVistas(widget.alumnoId);
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.7),
            builder: (_) =>
                _SharkResultDialog(esAceptado: esAceptada, materia: materia),
          );
        });
      }
    }

    if (etsState.solicitudes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin solicitudes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tus solicitudes aparecerán aquí',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: etsState.solicitudes.length,
      itemBuilder: (context, index) {
        final solicitud = etsState.solicitudes[index];
        final ets = solicitud['ets'] as Map<String, dynamic>;
        final estado = solicitud['estado'] as String;

        Color estadoColor;
        IconData estadoIcon;
        switch (estado) {
          case 'aceptada':
            estadoColor = Colors.green;
            estadoIcon = Icons.check_circle_rounded;
            break;
          case 'rechazada':
            estadoColor = Colors.red;
            estadoIcon = Icons.cancel_rounded;
            break;
          default:
            estadoColor = Colors.orange;
            estadoIcon = Icons.hourglass_empty_rounded;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(estadoIcon, color: estadoColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ets['materia'] as String,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${ets['fecha']} · ${ets['hora']}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  estado[0].toUpperCase() + estado.substring(1),
                  style: TextStyle(
                    color: estadoColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══ TARJETA ETS INSCRITO ════════════════════════════════════
class _EtsAlumnoCard extends StatelessWidget {
  final Map<String, dynamic> ets;
  const _EtsAlumnoCard({required this.ets});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.school_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ets['materia'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoChip(Icons.calendar_today_rounded,
                  ets['fecha'] as String),
              const SizedBox(width: 8),
              _infoChip(Icons.access_time_rounded,
                  '${ets['hora']} · ${TurnoHelper.calcularTurno(ets['hora'] as String)}'),
              const SizedBox(width: 8),
              _infoChip(
                  Icons.room_rounded, ets['salon'] as String),
            ],
          ),
          const SizedBox(height: 8),
          _infoChip(Icons.person_rounded, ets['profesor'] as String),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

// ══ TARJETA ETS DISPONIBLE ══════════════════════════════════
// ══ TARJETA ETS DISPONIBLE ══════════════════════════════════
class _EtsDisponibleCard extends ConsumerWidget {
  final Map<String, dynamic> ets;
  final VoidCallback onSolicitar;
  const _EtsDisponibleCard({required this.ets, required this.onSolicitar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lugares = ets['lugares_disponibles'] as int;
    final disponible = lugares > 0;
    final etsId = (ets['id'] ?? ets['ets_id']) as String;
    final esFavorito = ref
        .watch(alumnoEtsProvider)
        .favoritosIds
        .contains(etsId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: disponible
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ets['materia'] as String,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    ref.read(alumnoEtsProvider.notifier).toggleFavorito(ets),
                icon: Icon(
                  esFavorito ? Icons.star_rounded : Icons.star_border_rounded,
                  color: esFavorito ? Colors.amber : AppColors.textSecondary,
                  size: 22,
                ),
                tooltip: esFavorito
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: disponible
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  disponible ? '$lugares lugares' : 'Sin lugar',
                  style: TextStyle(
                    color: disponible ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${ets['fecha']} · ${ets['hora']} (${TurnoHelper.calcularTurno(ets['hora'] as String)}) · ${ets['salon']}',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          Text(
            ets['profesor'] as String,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSolicitar,
              icon: const Icon(
                Icons.send_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'Solicitar al administrador',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══ TIBURÓN PAINTER ═════════════════════════════════════════
class _SharkDialogPainter extends CustomPainter {
  final double animValue;
  final bool esAceptado;

  const _SharkDialogPainter({
    required this.animValue,
    required this.esAceptado,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFF4A90A4);
    final bellyPaint = Paint()..color = const Color(0xFFB8D4DC);
    final finPaint = Paint()..color = const Color(0xFF3A7A8A);
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1A1A2E);
    final toothPaint = Paint()..color = Colors.white;

    double offsetX = 0;
    double offsetY = 0;
    double rotation = 0;

    if (esAceptado) {
      offsetX = (animValue * 20) - 10;
      offsetY = (animValue * 10) - 5;
      rotation = (animValue - 0.5) * 0.3;
    } else {
      offsetY = animValue * 8;
      rotation = 0.15;
    }

    canvas.save();
    canvas.translate(size.width / 2 + offsetX, size.height / 2 + offsetY);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);

    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final w = size.width;
    final h = size.height;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.7, height: h * 0.5),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + w * 0.05, cy + h * 0.1),
        width: w * 0.5,
        height: h * 0.3,
      ),
      bellyPaint,
    );

    final tail = Path()
      ..moveTo(cx - w * 0.35, cy)
      ..lineTo(cx - w * 0.5, cy - h * 0.25)
      ..lineTo(cx - w * 0.3, cy - h * 0.05)
      ..close();
    canvas.drawPath(tail, finPaint);

    final tail2 = Path()
      ..moveTo(cx - w * 0.35, cy)
      ..lineTo(cx - w * 0.5, cy + h * 0.25)
      ..lineTo(cx - w * 0.3, cy + h * 0.05)
      ..close();
    canvas.drawPath(tail2, finPaint);

    final fin = Path()
      ..moveTo(cx - w * 0.05, cy - h * 0.25)
      ..lineTo(cx, cy - h * 0.5)
      ..lineTo(cx + w * 0.1, cy - h * 0.25)
      ..close();
    canvas.drawPath(fin, finPaint);

    canvas.drawCircle(Offset(cx + w * 0.38, cy), h * 0.28, bodyPaint);
    canvas.drawCircle(Offset(cx + w * 0.35, cy - h * 0.1), 5, eyePaint);
    canvas.drawCircle(
      Offset(cx + w * 0.36, cy - h * 0.1),
      esAceptado ? 3 : 2,
      pupilPaint,
    );

    if (!esAceptado) {
      final sadEye = Paint()
        ..color = const Color(0xFF2A5A6A)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx + w * 0.35, cy - h * 0.08),
          width: 8,
          height: 6,
        ),
        0,
        3.14,
        false,
        sadEye,
      );
    }

    for (int i = 0; i < 3; i++) {
      final tx = cx + w * 0.22 + i * 6.0;
      final tooth = Path()
        ..moveTo(tx, cy + h * 0.08)
        ..lineTo(tx + 3, cy + h * 0.2)
        ..lineTo(tx + 6, cy + h * 0.08)
        ..close();
      canvas.drawPath(tooth, toothPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_SharkDialogPainter old) =>
      old.animValue != animValue || old.esAceptado != esAceptado;
}

// ══ DIALOG DEL TIBURÓN ══════════════════════════════════════
class _SharkResultDialog extends StatefulWidget {
  final bool esAceptado;
  final String materia;

  const _SharkResultDialog({required this.esAceptado, required this.materia});

  @override
  State<_SharkResultDialog> createState() => _SharkResultDialogState();
}

class _SharkResultDialogState extends State<_SharkResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.esAceptado ? 400 : 2000),
    );
    _anim = CurvedAnimation(
      parent: _ctrl,
      curve: widget.esAceptado ? Curves.elasticOut : Curves.easeInOut,
    );
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 100,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) => CustomPaint(
                  painter: _SharkDialogPainter(
                    animValue: _anim.value,
                    esAceptado: widget.esAceptado,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.esAceptado ? '¡Prepárate!' : 'Bueno...',
              style: TextStyle(
                color: widget.esAceptado
                    ? AppColors.accent
                    : AppColors.textSecondary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.esAceptado
                  ? 'Tu ETS de ${widget.materia} ha sido aceptado '
                  : 'Un pendiente menos.\nTu solicitud de ${widget.materia} fue rechazada.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.esAceptado
                      ? AppColors.primary
                      : Colors.grey.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.esAceptado ? '¡A estudiar!' : 'Entendido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
