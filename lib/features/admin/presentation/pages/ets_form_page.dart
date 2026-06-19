import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';
import '../../../../core/theme/app_colors.dart';

class EtsFormPage extends ConsumerStatefulWidget {
  const EtsFormPage({super.key});

  @override
  ConsumerState<EtsFormPage> createState() => _EtsFormPageState();
}

class _EtsFormPageState extends ConsumerState<EtsFormPage> {
  final _profesorCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _salonCtrl = TextEditingController();
  final _cupoCtrl = TextEditingController();

  String? _carreraSeleccionada;
  int? _semestreSeleccionado;
  String? _materiaSeleccionada;

  // Para validar fecha y hora
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  bool get _esEdicion => _etsExistente != null;
  Map<String, dynamic>? _etsExistente;

  static const List<String> _carreras = [
    'ISC - Ingeniería en Sistemas Computacionales',
    'IA - Ingeniería en Inteligencia Artificial',
    'LCD - Licenciatura en Ciencia de Datos',
  ];

  static const Map<String, Map<int, List<String>>> _materias = {
    'ISC - Ingeniería en Sistemas Computacionales': {
      1: ['Cálculo', 'Análisis Vectorial', 'Matemáticas Discretas', 'Comunicación Oral y Escrita', 'Fundamentos de Programación'],
      2: ['Álgebra Lineal', 'Cálculo Aplicado', 'Mecánica y Electromagnetismo', 'Ingeniería, Ética y Sociedad', 'Fundamentos Económicos', 'Algoritmos y Estructuras de Datos'],
      3: ['Ecuaciones Diferenciales', 'Circuitos Eléctricos', 'Fundamentos de Diseño Digital', 'Bases de Datos', 'Finanzas Empresariales', 'Paradigmas de Programación', 'Análisis y Diseño de Algoritmos'],
      4: ['Probabilidad y Estadística', 'Matemáticas Avanzadas para la Ingeniería', 'Electrónica Analógica', 'Diseño de Sistemas Digitales', 'Tecnologías para el Desarrollo de Aplicaciones Web', 'Sistemas Operativos', 'Teoría de la Computación'],
      5: ['Procesamiento Digital de Señales', 'Instrumentación y Control', 'Arquitectura de Computadoras', 'Análisis y Diseño de Sistemas', 'Formulación y Evaluación de Proyectos Informáticos', 'Compiladores', 'Redes de Computadoras'],
      6: ['Sistemas en Chip', 'Optativa A1', 'Optativa B1', 'Métodos Cuantitativos para la Toma de Decisiones', 'Ingeniería de Software', 'Inteligencia Artificial', 'Aplicaciones para Comunicaciones en Red'],
      7: ['Desarrollo de Aplicaciones Móviles Nativas', 'Optativa A2', 'Optativa B2', 'Trabajo Terminal I', 'Sistemas Distribuidos', 'Administración de Servicios en Red'],
      8: ['Estancia Profesional', 'Desarrollo de Habilidades Sociales para la Alta Dirección', 'Trabajo Terminal II', 'Gestión Empresarial', 'Liderazgo Personal'],
    },
    'IA - Ingeniería en Inteligencia Artificial': {
      1: ['Fundamentos de Programación', 'Matemáticas Discretas', 'Cálculo', 'Comunicación Oral y Escrita', 'Mecánica y Electromagnetismo', 'Fundamentos Económicos'],
      2: ['Algoritmos y Estructuras de Datos', 'Fundamentos de Diseño Digital', 'Cálculo Multivariable', 'Ingeniería, Ética y Sociedad', 'Álgebra Lineal', 'Finanzas Empresariales'],
      3: ['Análisis y Diseño de Algoritmos', 'Paradigmas de Programación', 'Ecuaciones Diferenciales', 'Bases de Datos', 'Diseño de Sistemas Digitales', 'Liderazgo Personal'],
      4: ['Fundamentos de Inteligencia Artificial', 'Probabilidad y Estadística', 'Matemáticas Avanzadas para la Ingeniería', 'Tecnologías para el Desarrollo de Aplicaciones Web', 'Análisis y Diseño de Sistemas', 'Procesamiento Digital de Imágenes'],
      5: ['Aprendizaje de Máquina', 'Visión Artificial', 'Teoría de la Computación', 'Procesamiento de Señales', 'Algoritmos Bioinspirados', 'Tecnologías de Lenguaje Natural'],
      6: ['Cómputo Paralelo', 'Redes Neuronales y Aprendizaje Profundo', 'Ingeniería de Software para Sistemas Inteligentes', 'Optativa A', 'Optativa B', 'Metodología de la Investigación y Divulgación Científica'],
      7: ['Reconocimiento de Voz', 'Trabajo Terminal I', 'Formulación y Evaluación de Proyectos Informáticos', 'Optativa C', 'Optativa D'],
      8: ['Gestión Empresarial', 'Trabajo Terminal II', 'Estancia Profesional', 'Desarrollo de Habilidades Sociales para la Alta Dirección'],
    },
    'LCD - Licenciatura en Ciencia de Datos': {
      1: ['Fundamentos de Programación', 'Matemáticas Discretas', 'Cálculo', 'Comunicación Oral y Escrita', 'Introducción a la Ciencia de Datos'],
      2: ['Algoritmos y Estructuras de Datos', 'Fundamentos Económicos', 'Cálculo Multivariable', 'Ética y Legalidad', 'Álgebra Lineal'],
      3: ['Análisis y Diseño de Algoritmos', 'Programación para Ciencia de Datos', 'Probabilidad', 'Bases de Datos', 'Métodos Numéricos', 'Finanzas Empresariales'],
      4: ['Desarrollo de Aplicaciones Web', 'Cómputo de Alto Desempeño', 'Estadística', 'Bases de Datos Avanzadas', 'Desarrollo de Aplicaciones para Análisis de Datos', 'Liderazgo Personal'],
      5: ['Minería de Datos', 'Matemáticas Avanzadas para Ciencia de Datos', 'Procesos Estocásticos', 'Aprendizaje de Máquina e Inteligencia Artificial', 'Análisis y Visualización de Datos', 'Metodología de la Investigación y Divulgación Científica'],
      6: ['Modelado Predictivo', 'Procesamiento de Lenguaje Natural', 'Análisis de Series de Tiempo', 'Analítica Avanzada de Datos', 'Optativa A', 'Optativa B'],
      7: ['Big Data', 'Modelos Econométricos', 'Trabajo Terminal I', 'Administración de Proyectos de TI', 'Optativa C', 'Optativa D'],
      8: ['Desarrollo de Habilidades Sociales para la Alta Dirección', 'Gestión Empresarial', 'Trabajo Terminal II', 'Estancia Profesional'],
    },
  };

  List<int> get _semestresDisponibles {
    if (_carreraSeleccionada == null) return [];
    return (_materias[_carreraSeleccionada]?.keys.toList() ?? [])..sort();
  }

  List<String> get _materiasDisponibles {
    if (_carreraSeleccionada == null || _semestreSeleccionado == null) return [];
    return _materias[_carreraSeleccionada]?[_semestreSeleccionado] ?? [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic> && _etsExistente == null) {
      _etsExistente = args;
      _precargarDatos(args);
    }
  }

  void _precargarDatos(Map<String, dynamic> ets) {
    setState(() {
      _carreraSeleccionada = ets['carrera'] as String;
      _semestreSeleccionado = ets['semestre'] as int;
      _materiaSeleccionada = ets['materia'] as String;
      _profesorCtrl.text = ets['profesor'] as String;
      _fechaCtrl.text = ets['fecha'] as String;
      _horaCtrl.text = ets['hora'] as String;
      _salonCtrl.text = ets['salon'] as String;
      _cupoCtrl.text = ets['cupo_maximo'].toString();
    });
  }

  @override
  void dispose() {
    _profesorCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    _salonCtrl.dispose();
    _cupoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_carreraSeleccionada == null ||
        _semestreSeleccionado == null ||
        _materiaSeleccionada == null ||
        _profesorCtrl.text.isEmpty ||
        _fechaCtrl.text.isEmpty ||
        _horaCtrl.text.isEmpty ||
        _salonCtrl.text.isEmpty ||
        _cupoCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar que la fecha y hora sean futuras
    if (!_esEdicion && _fechaSeleccionada != null && _horaSeleccionada != null) {
      final fechaHoraSeleccionada = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );
      if (fechaHoraSeleccionada.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La fecha y hora deben ser posteriores a ahora'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final cupo = int.tryParse(_cupoCtrl.text) ?? 0;

    final datos = {
      if (_esEdicion) 'id': _etsExistente!['id'],
      'materia': _materiaSeleccionada!,
      'carrera': _carreraSeleccionada!,
      'semestre': _semestreSeleccionado!,
      'fecha': _fechaCtrl.text.trim(),
      'hora': _horaCtrl.text.trim(),
      'salon': _salonCtrl.text.trim(),
      'profesor': _profesorCtrl.text.trim(),
      // Al crear, lugares_disponibles = cupo_maximo
      'lugares_disponibles': _esEdicion
          ? (_etsExistente!['lugares_disponibles'] as int)
          : cupo,
      'cupo_maximo': cupo,
    };

    if (_esEdicion) {
      await ref.read(adminProvider.notifier).actualizarEts(datos);
    } else {
      await ref.read(adminProvider.notifier).crearEts(datos);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_esEdicion
              ? 'ETS actualizado correctamente'
              : 'ETS creado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
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
        title: Text(
          _esEdicion ? 'Editar ETS' : 'Nuevo ETS',
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: _guardar,
            icon: const Icon(Icons.save_rounded,
                color: AppColors.primary, size: 18),
            label: const Text('Guardar',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Clasificación ─────────────────────────
            _buildSeccion(
              titulo: 'Clasificación',
              children: [
                _buildLabel('Carrera'),
                const SizedBox(height: 8),
                _buildDropdown<String>(
                  hint: 'Selecciona una carrera',
                  value: _carreraSeleccionada,
                  items: _carreras,
                  displayText: (c) => c,
                  onChanged: (val) => setState(() {
                    _carreraSeleccionada = val;
                    _semestreSeleccionado = null;
                    _materiaSeleccionada = null;
                  }),
                ),
                const SizedBox(height: 16),
                _buildLabel('Semestre'),
                const SizedBox(height: 8),
                _buildDropdown<int>(
                  hint: 'Selecciona semestre',
                  value: _semestreSeleccionado,
                  items: _semestresDisponibles,
                  displayText: (s) => 'Semestre $s',
                  onChanged: (val) => setState(() {
                    _semestreSeleccionado = val;
                    _materiaSeleccionada = null;
                  }),
                  disabled: _carreraSeleccionada == null,
                ),
                const SizedBox(height: 16),
                _buildLabel('Materia'),
                const SizedBox(height: 8),
                _buildDropdown<String>(
                  hint: 'Selecciona materia',
                  value: _materiaSeleccionada,
                  items: _materiasDisponibles,
                  displayText: (m) => m,
                  onChanged: (val) =>
                      setState(() => _materiaSeleccionada = val),
                  disabled: _semestreSeleccionado == null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Detalles del Examen ───────────────────
            _buildSeccion(
              titulo: 'Detalles del Examen',
              children: [
                _buildLabel('Profesor evaluador'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _profesorCtrl,
                  hint: 'Ej: Dr. Ramírez Hernández',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Fecha'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _fechaCtrl,
                            hint: 'DD/MM/YYYY',
                            icon: Icons.calendar_today_rounded,
                            onTap: () async {
                              final fecha = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now()
                                    .add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                                builder: (ctx, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppColors.primary,
                                      surface: AppColors.cardBackground,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (fecha != null) {
                                setState(() => _fechaSeleccionada = fecha);
                                _fechaCtrl.text =
                                    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Hora'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _horaCtrl,
                            hint: 'HH:MM',
                            icon: Icons.access_time_rounded,
                            onTap: () async {
                              final hora = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (ctx, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppColors.primary,
                                      surface: AppColors.cardBackground,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (hora != null) {
                                setState(() => _horaSeleccionada = hora);
                                _horaCtrl.text =
                                    '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLabel('Salón'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _salonCtrl,
                  hint: 'Ej: Salón A-101',
                  icon: Icons.room_rounded,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Capacidad ─────────────────────────────
            _buildSeccion(
              titulo: 'Capacidad',
              children: [
                _buildLabel('Cupo máximo'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _cupoCtrl,
                  hint: 'Ej: 40',
                  icon: Icons.group_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                Text(
                  'Los lugares disponibles se asignarán automáticamente al cupo máximo al crear el ETS.',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardar,
                icon: Icon(
                  _esEdicion ? Icons.save_rounded : Icons.add_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  _esEdicion ? 'Guardar cambios' : 'Crear ETS',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion(
      {required String titulo, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: onTap != null,
        onTap: onTap,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    bool disabled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: disabled
            ? AppColors.background.withValues(alpha: 0.5)
            : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        onChanged: disabled ? null : onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        dropdownColor: AppColors.cardBackground,
        hint: Text(hint,
            style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 13)),
        isExpanded: true,
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(displayText(item),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ))
            .toList(),
      ),
    );
  }
}