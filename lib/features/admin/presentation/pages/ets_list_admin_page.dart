import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/turno_helper.dart';

class EtsListAdminPage extends ConsumerStatefulWidget {
  const EtsListAdminPage({super.key});

  @override
  ConsumerState<EtsListAdminPage> createState() => _EtsListAdminPageState();
}

class _EtsListAdminPageState extends ConsumerState<EtsListAdminPage> {
  bool _mostrarPasados = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final lista = _mostrarPasados ? state.etsPasados : state.etsProximos;

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
        title: const Text('Gestión de ETS',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed('/admin/ets/form'),
            icon: const Icon(Icons.add_rounded,
                color: AppColors.primary),
            tooltip: 'Agregar ETS',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleBtn(
                    titulo: 'Próximos',
                    seleccionado: !_mostrarPasados,
                    onTap: () => setState(() => _mostrarPasados = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildToggleBtn(
                    titulo: 'Exámenes pasados',
                    seleccionado: _mostrarPasados,
                    onTap: () => setState(() => _mostrarPasados = true),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.estaCargando
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : lista.isEmpty
                    ? _buildEstadoVacio(context)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.cardBackground,
                        onRefresh: () =>
                            ref.read(adminProvider.notifier).cargarDatos(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: lista.length,
                          itemBuilder: (context, index) {
                            final ets = lista[index];
                            return _buildEtsAdminCard(context, ref, ets);
                          },
                        ),
                      ),
          ),
        ],
      ),
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
            color: seleccionado
                ? AppColors.primary
                : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEtsAdminCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> ets,
  ) {
    final tieneDisponibilidad =
        (ets['lugares_disponibles'] as int) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tieneDisponibilidad
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ets['materia'] as String,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(ets['carrera'] as String).split(' - ').first} · Sem. ${ets['semestre']}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.cardBackground,
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppColors.textSecondary),
                  onSelected: (value) {
                    if (value == 'editar') {
                      Navigator.of(context).pushNamed(
                        '/admin/ets/form',
                        arguments: ets,
                      );
                    } else if (value == 'eliminar') {
                      _confirmarEliminar(context, ref, ets);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              color: AppColors.primary, size: 18),
                          SizedBox(width: 10),
                          Text('Editar',
                              style: TextStyle(
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 18),
                          SizedBox(width: 10),
                          Text('Eliminar',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _buildChipDetalle(
                    Icons.calendar_today_rounded,
                    ets['fecha'] as String),
                const SizedBox(width: 8),
                _buildChipDetalle(
                    Icons.access_time_rounded,
                    ets['hora'] as String),
                const SizedBox(width: 8),
                _buildChipDetalle(
                    Icons.wb_sunny_rounded,
                    TurnoHelper.calcularTurno(ets['hora'] as String)),
                const SizedBox(width: 8),
                _buildChipDetalle(
                  Icons.people_rounded,
                  '${ets['lugares_disponibles']}/${ets['cupo_maximo']}',
                  color: tieneDisponibilidad
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipDetalle(IconData icon, String texto,
      {Color? color}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            (color ?? AppColors.textSecondary).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              color: color ?? AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> ets,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar ETS?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Se eliminará "${ets['materia']}" del ${(ets['carrera'] as String).split(' - ').first}. Esta acción no se puede deshacer.',
          style:
              const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style:
                    TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(adminProvider.notifier)
                  .eliminarEts(ets['id'] as String);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ETS eliminado correctamente'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            _mostrarPasados
                ? 'No hay exámenes pasados'
                : 'No hay ETS próximos registrados',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          if (!_mostrarPasados) ...[
            const SizedBox(height: 8),
            const Text('Presiona + para agregar el primero',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}