import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../core/theme/app_colors.dart';

final alumnosAdminProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('alumnos')
      .select(
          'id, boleta, nombre, apellido_paterno, apellido_materno, carrera, semestre')
      .order('apellido_paterno', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

class AlumnosAdminPage extends ConsumerWidget {
  const AlumnosAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alumnosAsync = ref.watch(alumnosAdminProvider);

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
        title: const Text('Gestión de Alumnos',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(alumnosAdminProvider),
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.primary),
          ),
          IconButton(
            onPressed: () => _mostrarFormAlumno(context, ref, null),
            icon: const Icon(Icons.person_add_rounded,
                color: AppColors.primary),
            tooltip: 'Registrar alumno',
          ),
        ],
      ),
      body: alumnosAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
        data: (alumnos) {
          if (alumnos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 64,
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('No hay alumnos registrados',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Presiona + para registrar uno',
                      style: TextStyle(
                          color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alumnos.length,
            itemBuilder: (context, index) {
              final alumno = alumnos[index];
              return _buildAlumnoCard(context, ref, alumno);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlumnoCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> alumno,
  ) {
    final carreraCorta =
        (alumno['carrera'] as String).split(' - ').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (alumno['nombre'] as String)[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${alumno['nombre']} ${alumno['apellido_paterno']} ${alumno['apellido_materno']}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Boleta: ${alumno['boleta']}',
                  style: const TextStyle(
                      color: AppColors.accent, fontSize: 12),
                ),
                Text(
                  '$carreraCorta · Semestre ${alumno['semestre']}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.cardBackground,
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'ets') {
                _mostrarEtsAlumno(context, alumno);
              } else if (value == 'editar') {
                _mostrarFormAlumno(context, ref, alumno);
              } else if (value == 'password') {
                _mostrarCambiarPassword(context, ref, alumno);
              } else if (value == 'eliminar') {
                _confirmarEliminar(context, ref, alumno);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ets',
                child: Row(
                  children: [
                    Icon(Icons.assignment_rounded,
                        color: AppColors.accent, size: 18),
                    SizedBox(width: 10),
                    Text('Ver ETS inscritos',
                        style: TextStyle(
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded,
                        color: AppColors.primary, size: 18),
                    SizedBox(width: 10),
                    Text('Editar datos',
                        style: TextStyle(
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'password',
                child: Row(
                  children: [
                    Icon(Icons.lock_reset_rounded,
                        color: Colors.orange, size: 18),
                    SizedBox(width: 10),
                    Text('Cambiar contraseña',
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
    );
  }

  void _mostrarEtsAlumno(
    BuildContext context,
    Map<String, dynamic> alumno,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _EtsAlumnoSheet(alumno: alumno),
    );
  }

  void _mostrarFormAlumno(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? alumnoExistente,
  ) {
    final esEdicion = alumnoExistente != null;
    final nombreCtrl = TextEditingController(
        text: esEdicion ? alumnoExistente['nombre'] as String : '');
    final apPaternoCtrl = TextEditingController(
        text: esEdicion
            ? alumnoExistente['apellido_paterno'] as String
            : '');
    final apMaternoCtrl = TextEditingController(
        text: esEdicion
            ? alumnoExistente['apellido_materno'] as String
            : '');
    final boletaCtrl = TextEditingController(
        text: esEdicion ? alumnoExistente['boleta'] as String : '');
    final passCtrl = TextEditingController();

    String? carreraSeleccionada =
        esEdicion ? alumnoExistente['carrera'] as String : null;
    int? semestreSeleccionado =
        esEdicion ? alumnoExistente['semestre'] as int : null;

    const carreras = [
      'ISC - Ingeniería en Sistemas Computacionales',
      'IA - Ingeniería en Inteligencia Artificial',
      'LCD - Licenciatura en Ciencia de Datos',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            esEdicion ? 'Editar Alumno' : 'Registrar Alumno',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campoTexto(
                    nombreCtrl, 'Nombre', Icons.person_rounded),
                const SizedBox(height: 12),
                _campoTexto(apPaternoCtrl, 'Apellido paterno',
                    Icons.person_rounded),
                const SizedBox(height: 12),
                _campoTexto(apMaternoCtrl, 'Apellido materno',
                    Icons.person_rounded),
                const SizedBox(height: 12),
                _campoTexto(
                  boletaCtrl,
                  'Boleta (10 dígitos)',
                  Icons.badge_outlined,
                  tipo: TextInputType.number,
                  maxLength: 10,
                  enabled: !esEdicion,
                ),
                if (!esEdicion) ...[
                  const SizedBox(height: 12),
_CampoPasswordGenerico(
                    controller: passCtrl,
                    hint: 'Contraseña inicial',
                  ),                ],
                const SizedBox(height: 12),
                _dropdownField(
                  hint: 'Carrera',
                  value: carreraSeleccionada,
                  items: carreras,
                  onChanged: (val) => setStateDialog(
                      () => carreraSeleccionada = val),
                ),
                const SizedBox(height: 12),
                _dropdownField(
                  hint: 'Semestre',
                  value: semestreSeleccionado?.toString(),
                  items: List.generate(8, (i) => '${i + 1}'),
                  onChanged: (val) => setStateDialog(
                      () => semestreSeleccionado =
                          int.tryParse(val ?? '')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(
                      color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreCtrl.text.isEmpty ||
                    apPaternoCtrl.text.isEmpty ||
                    boletaCtrl.text.isEmpty ||
                    carreraSeleccionada == null ||
                    semestreSeleccionado == null ||
                    (!esEdicion && passCtrl.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Completa todos los campos'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  final client = Supabase.instance.client;
                  if (esEdicion) {
                    await client.from('alumnos').update({
                      'nombre': nombreCtrl.text.trim(),
                      'apellido_paterno':
                          apPaternoCtrl.text.trim(),
                      'apellido_materno':
                          apMaternoCtrl.text.trim(),
                      'carrera': carreraSeleccionada,
                      'semestre': semestreSeleccionado,
                    }).eq('id',
                        alumnoExistente['id'] as String);
                  } else {
                    final hash = _hashPassword(passCtrl.text);
                    await client.from('alumnos').insert({
                      'boleta': boletaCtrl.text.trim(),
                      'nombre': nombreCtrl.text.trim(),
                      'apellido_paterno':
                          apPaternoCtrl.text.trim(),
                      'apellido_materno':
                          apMaternoCtrl.text.trim(),
                      'carrera': carreraSeleccionada,
                      'semestre': semestreSeleccionado,
                      'password_hash': hash,
                    });
                  }

                  ref.invalidate(alumnosAdminProvider);
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(esEdicion
                          ? '✅ Alumno actualizado'
                          : '✅ Alumno registrado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              child: Text(
                esEdicion ? 'Guardar' : 'Registrar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarCambiarPassword(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> alumno,
  ) {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Cambiar Contraseña',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${alumno['nombre']} ${alumno['apellido_paterno']}',
              style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _CampoPasswordGenerico(
              controller: passCtrl,
              hint: 'Nueva contraseña',
            ),
            const SizedBox(height: 12),
            _CampoPasswordGenerico(
              controller: confirmCtrl,
              hint: 'Confirmar contraseña',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ingresa la nueva contraseña'),
                      backgroundColor: Colors.orange),
                );
                return;
              }
              if (passCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Las contraseñas no coinciden'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              try {
                await Supabase.instance.client
                    .from('alumnos')
                    .update({
                  'password_hash': _hashPassword(passCtrl.text)
                }).eq('id', alumno['id'] as String);

                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Contraseña actualizada'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Cambiar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> alumno,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar alumno?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Se eliminará a ${alumno['nombre']} ${alumno['apellido_paterno']} (${alumno['boleta']}). Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Supabase.instance.client
                    .from('alumnos')
                    .delete()
                    .eq('id', alumno['id'] as String);
                ref.invalidate(alumnosAdminProvider);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alumno eliminado'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Widget _campoTexto(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType? tipo,
    int? maxLength,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.background
            : AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: tipo,
        maxLength: maxLength,
        enabled: enabled,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 13),
          prefixIcon:
              Icon(icon, color: AppColors.textSecondary, size: 18),
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        dropdownColor: AppColors.cardBackground,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        hint: Text(hint,
            style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 13)),
        isExpanded: true,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ))
            .toList(),
      ),
    );
  }
}

// ══ CAMPO CONTRASEÑA GENÉRICO CON VER/OCULTAR ══════════════
class _CampoPasswordGenerico extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  const _CampoPasswordGenerico({
    required this.controller,
    required this.hint,
  });

  @override
  State<_CampoPasswordGenerico> createState() =>
      _CampoPasswordGenericoState();
}

class _CampoPasswordGenericoState extends State<_CampoPasswordGenerico> {
  bool _verPass = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: !_verPass,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 13),
          prefixIcon: const Icon(Icons.lock_outline_rounded,
              color: AppColors.textSecondary, size: 18),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _verPass = !_verPass),
            icon: Icon(
              _verPass
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ══ SHEET DE ETS DEL ALUMNO ═════════════════════════════════
class _EtsAlumnoSheet extends StatefulWidget {
  final Map<String, dynamic> alumno;
  const _EtsAlumnoSheet({required this.alumno});

  @override
  State<_EtsAlumnoSheet> createState() => _EtsAlumnoSheetState();
}

class _EtsAlumnoSheetState extends State<_EtsAlumnoSheet> {
  List<Map<String, dynamic>> _etsList = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEts();
  }

  Future<void> _cargarEts() async {
    try {
      final response = await Supabase.instance.client
          .from('ets_alumno')
          .select('*, ets(*)')
          .eq('alumno_id', widget.alumno['id'] as String);
      setState(() {
        _etsList = List<Map<String, dynamic>>.from(response);
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarEts(String etsAlumnoId) async {
    try {
      await Supabase.instance.client
          .from('ets_alumno')
          .delete()
          .eq('id', etsAlumnoId);
      await _cargarEts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ETS removido del alumno'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.alumno['nombre']} ${widget.alumno['apellido_paterno']}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Boleta: ${widget.alumno['boleta']}',
                        style: const TextStyle(
                            color: AppColors.accent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
onPressed: () => _mostrarAsignarEts(),
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: Colors.white),
                  label: const Text('Asignar ETS',
                      style:
                          TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : _etsList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined,
                                size: 48,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            const Text('Sin ETS inscritos',
                                style: TextStyle(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _etsList.length,
                        itemBuilder: (context, index) {
                          final item = _etsList[index];
                          final ets =
                              item['ets'] as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ets['materia'] as String,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${ets['fecha']} · ${ets['hora']} · ${ets['salon']}',
                                        style: const TextStyle(
                                            color:
                                                AppColors.textSecondary,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _eliminarEts(
                                      item['id'] as String),
                                  icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      color: Colors.red,
                                      size: 20),
                                  tooltip: 'Remover ETS',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

Future<void> _mostrarAsignarEts() async {
      final response = await Supabase.instance.client
        .from('ets')
        .select()
        .order('materia', ascending: true);

    final todosEts = List<Map<String, dynamic>>.from(response);

    final etsYaInscritos = _etsList
        .map((e) =>
            (e['ets'] as Map<String, dynamic>)['id'] as String)
        .toSet();

    final disponibles = todosEts
        .where((e) => !etsYaInscritos.contains(e['id'] as String))
        .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Asignar ETS',
            style: TextStyle(color: AppColors.textPrimary)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: disponibles.isEmpty
              ? const Center(
                  child: Text('No hay ETS disponibles para asignar',
                      style:
                          TextStyle(color: AppColors.textSecondary)))
               : ListView.builder(
                  itemCount: disponibles.length,
                  itemBuilder: (itemContext, index) {
                    final ets = disponibles[index];
                    return ListTile(
                      title: Text(ets['materia'] as String,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13)),
                      subtitle: Text(
                          '${ets['fecha']} · ${ets['salon']}',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11)),
                      trailing: const Icon(Icons.add_circle_rounded,
                          color: AppColors.primary),
                      onTap: () async {
                        try {
                          await Supabase.instance.client
                              .from('ets_alumno')
                              .insert({
                            'alumno_id':
                                widget.alumno['id'] as String,
                            'ets_id': ets['id'] as String,
                            'estado': 'inscrito',
                          });
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          await _cargarEts();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ ETS asignado al alumno'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}