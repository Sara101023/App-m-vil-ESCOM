import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Página de gestión de catálogos: carreras y salones.
/// Los datos se guardan en SharedPreferences (simples listas de strings).
class CatalogosPage extends StatefulWidget {
  const CatalogosPage({super.key});

  @override
  State<CatalogosPage> createState() => _CatalogosPageState();
}

class _CatalogosPageState extends State<CatalogosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // En una app real vendrían de la BD; aquí los gestionamos localmente
  final List<String> _carreras = [
    'ISC - Ingeniería en Sistemas Computacionales',
    'IA - Ingeniería en Inteligencia Artificial',
    'LCD - Licenciatura en Ciencia de Datos',
  ];

  final List<String> _salones = [
    'Salón A-101', 'Salón A-105', 'Salón B-105', 'Salón B-202',
    'Salón C-102', 'Salón C-301', 'Salón D-401', 'Salón D-402',
    'Lab. Cómputo 1', 'Lab. Cómputo 2', 'Lab. Redes', 'Lab. IA',
    'Lab. Datos',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Gestión de Catálogos',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Carreras'),
            Tab(text: 'Salones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLista(
            items: _carreras,
            icono: Icons.school_rounded,
            onAgregar: () => _mostrarDialogoAgregar('Carrera', _carreras),
            onEliminar: (i) => setState(() => _carreras.removeAt(i)),
          ),
          _buildLista(
            items: _salones,
            icono: Icons.room_rounded,
            onAgregar: () => _mostrarDialogoAgregar('Salón', _salones),
            onEliminar: (i) => setState(() => _salones.removeAt(i)),
          ),
        ],
      ),
    );
  }

  Widget _buildLista({
    required List<String> items,
    required IconData icono,
    required VoidCallback onAgregar,
    required void Function(int) onEliminar,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Agregar nuevo',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icono,
                          size: 48,
                          color: AppColors.textSecondary.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const Text('No hay registros',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color:
                                AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      child: ListTile(
                        leading: Icon(icono,
                            color: AppColors.primary, size: 20),
                        title: Text(items[index],
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 14)),
                        trailing: IconButton(
                          onPressed: () => _confirmarEliminar(index, onEliminar),
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 20),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _mostrarDialogoAgregar(String tipo, List<String> lista) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Agregar $tipo',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2)),
          ),
          child: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Nombre del $tipo',
              hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final nombre = ctrl.text.trim();
              if (nombre.isNotEmpty) {
                setState(() => lista.add(nombre));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Agregar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(int index, void Function(int) onEliminar) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Esta acción no se puede deshacer.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onEliminar(index);
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
}