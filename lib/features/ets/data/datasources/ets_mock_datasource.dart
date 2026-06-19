import '../models/ets_model.dart';

class EtsMockDatasource {
  // ─── CARRERAS ─────────────────────────────────────────────
  static const List<String> _carreras = [
    'ISC - Ingeniería en Sistemas Computacionales',
    'IA - Ingeniería en Inteligencia Artificial',
    'LCD - Licenciatura en Ciencia de Datos',
  ];

  // ─── MATERIAS REALES POR CARRERA Y SEMESTRE ──────────────
  static const Map<String, Map<int, List<String>>> _materias = {
    // ══════════════════════════════════════════
    // ISC — Ingeniería en Sistemas Computacionales
    // ══════════════════════════════════════════
    'ISC - Ingeniería en Sistemas Computacionales': {
      1: [
        'Cálculo',
        'Análisis Vectorial',
        'Matemáticas Discretas',
        'Comunicación Oral y Escrita',
        'Fundamentos de Programación',
      ],
      2: [
        'Álgebra Lineal',
        'Cálculo Aplicado',
        'Mecánica y Electromagnetismo',
        'Ingeniería, Ética y Sociedad',
        'Fundamentos Económicos',
        'Algoritmos y Estructuras de Datos',
      ],
      3: [
        'Ecuaciones Diferenciales',
        'Circuitos Eléctricos',
        'Fundamentos de Diseño Digital',
        'Bases de Datos',
        'Finanzas Empresariales',
        'Paradigmas de Programación',
        'Análisis y Diseño de Algoritmos',
      ],
      4: [
        'Probabilidad y Estadística',
        'Matemáticas Avanzadas para la Ingeniería',
        'Electrónica Analógica',
        'Diseño de Sistemas Digitales',
        'Tecnologías para el Desarrollo de Aplicaciones Web',
        'Sistemas Operativos',
        'Teoría de la Computación',
      ],
      5: [
        'Procesamiento Digital de Señales',
        'Instrumentación y Control',
        'Arquitectura de Computadoras',
        'Análisis y Diseño de Sistemas',
        'Formulación y Evaluación de Proyectos Informáticos',
        'Compiladores',
        'Redes de Computadoras',
      ],
      6: [
        'Sistemas en Chip',
        'Optativa A1',
        'Optativa B1',
        'Métodos Cuantitativos para la Toma de Decisiones',
        'Ingeniería de Software',
        'Inteligencia Artificial',
        'Aplicaciones para Comunicaciones en Red',
      ],
      7: [
        'Desarrollo de Aplicaciones Móviles Nativas',
        'Optativa A2',
        'Optativa B2',
        'Trabajo Terminal I',
        'Sistemas Distribuidos',
        'Administración de Servicios en Red',
      ],
      8: [
        'Estancia Profesional',
        'Desarrollo de Habilidades Sociales para la Alta Dirección',
        'Trabajo Terminal II',
        'Gestión Empresarial',
        'Liderazgo Personal',
      ],
    },

    // ══════════════════════════════════════════
    // IA — Ingeniería en Inteligencia Artificial
    // ══════════════════════════════════════════
    'IA - Ingeniería en Inteligencia Artificial': {
      1: [
        'Fundamentos de Programación',
        'Matemáticas Discretas',
        'Cálculo',
        'Comunicación Oral y Escrita',
        'Mecánica y Electromagnetismo',
        'Fundamentos Económicos',
      ],
      2: [
        'Algoritmos y Estructuras de Datos',
        'Fundamentos de Diseño Digital',
        'Cálculo Multivariable',
        'Ingeniería, Ética y Sociedad',
        'Álgebra Lineal',
        'Finanzas Empresariales',
      ],
      3: [
        'Análisis y Diseño de Algoritmos',
        'Paradigmas de Programación',
        'Ecuaciones Diferenciales',
        'Bases de Datos',
        'Diseño de Sistemas Digitales',
        'Liderazgo Personal',
      ],
      4: [
        'Fundamentos de Inteligencia Artificial',
        'Probabilidad y Estadística',
        'Matemáticas Avanzadas para la Ingeniería',
        'Tecnologías para el Desarrollo de Aplicaciones Web',
        'Análisis y Diseño de Sistemas',
        'Procesamiento Digital de Imágenes',
      ],
      5: [
        'Aprendizaje de Máquina',
        'Visión Artificial',
        'Teoría de la Computación',
        'Procesamiento de Señales',
        'Algoritmos Bioinspirados',
        'Tecnologías de Lenguaje Natural',
      ],
      6: [
        'Cómputo Paralelo',
        'Redes Neuronales y Aprendizaje Profundo',
        'Ingeniería de Software para Sistemas Inteligentes',
        'Optativa A',
        'Optativa B',
        'Metodología de la Investigación y Divulgación Científica',
      ],
      7: [
        'Reconocimiento de Voz',
        'Trabajo Terminal I',
        'Formulación y Evaluación de Proyectos Informáticos',
        'Optativa C',
        'Optativa D',
      ],
      8: [
        'Gestión Empresarial',
        'Trabajo Terminal II',
        'Estancia Profesional',
        'Desarrollo de Habilidades Sociales para la Alta Dirección',
      ],
    },

    // ══════════════════════════════════════════
    // LCD — Licenciatura en Ciencia de Datos
    // ══════════════════════════════════════════
    'LCD - Licenciatura en Ciencia de Datos': {
      1: [
        'Fundamentos de Programación',
        'Matemáticas Discretas',
        'Cálculo',
        'Comunicación Oral y Escrita',
        'Introducción a la Ciencia de Datos',
      ],
      2: [
        'Algoritmos y Estructuras de Datos',
        'Fundamentos Económicos',
        'Cálculo Multivariable',
        'Ética y Legalidad',
        'Álgebra Lineal',
      ],
      3: [
        'Análisis y Diseño de Algoritmos',
        'Programación para Ciencia de Datos',
        'Probabilidad',
        'Bases de Datos',
        'Métodos Numéricos',
        'Finanzas Empresariales',
      ],
      4: [
        'Desarrollo de Aplicaciones Web',
        'Cómputo de Alto Desempeño',
        'Estadística',
        'Bases de Datos Avanzadas',
        'Desarrollo de Aplicaciones para Análisis de Datos',
        'Liderazgo Personal',
      ],
      5: [
        'Minería de Datos',
        'Matemáticas Avanzadas para Ciencia de Datos',
        'Procesos Estocásticos',
        'Aprendizaje de Máquina e Inteligencia Artificial',
        'Análisis y Visualización de Datos',
        'Metodología de la Investigación y Divulgación Científica',
      ],
      6: [
        'Modelado Predictivo',
        'Procesamiento de Lenguaje Natural',
        'Análisis de Series de Tiempo',
        'Analítica Avanzada de Datos',
        'Optativa A',
        'Optativa B',
      ],
      7: [
        'Big Data',
        'Modelos Econométricos',
        'Trabajo Terminal I',
        'Administración de Proyectos de TI',
        'Optativa C',
        'Optativa D',
      ],
      8: [
        'Desarrollo de Habilidades Sociales para la Alta Dirección',
        'Gestión Empresarial',
        'Trabajo Terminal II',
        'Estancia Profesional',
      ],
    },
  };

  // ─── DATOS MOCK DE ETS ────────────────────────────────────
  // Los ETS de ejemplo. Las materias ahora coinciden con el catálogo real.
  static final List<EtsModel> _ets = [
    // ── ISC Semestre 1 ──
    EtsModel.fromJson({'id': 'ETS-001', 'materia': 'Cálculo', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 1, 'fecha': '12/07/2025', 'hora': '07:00', 'salon': 'Salón A-101', 'profesor': 'Dr. Ramírez Hernández', 'lugaresDisponibles': 15, 'cupoMaximo': 40}),
    EtsModel.fromJson({'id': 'ETS-002', 'materia': 'Fundamentos de Programación', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 1, 'fecha': '14/07/2025', 'hora': '09:00', 'salon': 'Lab. Cómputo 1', 'profesor': 'M.C. Torres Gutiérrez', 'lugaresDisponibles': 0, 'cupoMaximo': 35}),
    EtsModel.fromJson({'id': 'ETS-003', 'materia': 'Matemáticas Discretas', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 1, 'fecha': '16/07/2025', 'hora': '11:00', 'salon': 'Salón B-105', 'profesor': 'Dra. Vega Morales', 'lugaresDisponibles': 20, 'cupoMaximo': 40}),
    // ── ISC Semestre 2 ──
    EtsModel.fromJson({'id': 'ETS-004', 'materia': 'Algoritmos y Estructuras de Datos', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 2, 'fecha': '13/07/2025', 'hora': '07:00', 'salon': 'Lab. Cómputo 2', 'profesor': 'M.C. Sánchez Pérez', 'lugaresDisponibles': 12, 'cupoMaximo': 35}),
    EtsModel.fromJson({'id': 'ETS-005', 'materia': 'Álgebra Lineal', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 2, 'fecha': '15/07/2025', 'hora': '13:00', 'salon': 'Salón A-105', 'profesor': 'Dr. Mendoza Ruiz', 'lugaresDisponibles': 5, 'cupoMaximo': 40}),
    // ── ISC Semestre 5 ──
    EtsModel.fromJson({'id': 'ETS-006', 'materia': 'Compiladores', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 5, 'fecha': '17/07/2025', 'hora': '09:00', 'salon': 'Salón C-301', 'profesor': 'Dr. Vega Morales', 'lugaresDisponibles': 18, 'cupoMaximo': 30}),
    EtsModel.fromJson({'id': 'ETS-007', 'materia': 'Redes de Computadoras', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 5, 'fecha': '18/07/2025', 'hora': '11:00', 'salon': 'Lab. Redes', 'profesor': 'Dra. Flores Castillo', 'lugaresDisponibles': 25, 'cupoMaximo': 40}),
    // ── ISC Semestre 6 ──
    EtsModel.fromJson({'id': 'ETS-008', 'materia': 'Inteligencia Artificial', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 6, 'fecha': '19/07/2025', 'hora': '07:00', 'salon': 'Salón B-202', 'profesor': 'Dr. Cruz Jiménez', 'lugaresDisponibles': 10, 'cupoMaximo': 35}),
    // ── IA Semestre 2 ──
    EtsModel.fromJson({'id': 'ETS-009', 'materia': 'Álgebra Lineal', 'carrera': 'IA - Ingeniería en Inteligencia Artificial', 'semestre': 2, 'fecha': '12/07/2025', 'hora': '13:00', 'salon': 'Salón A-201', 'profesor': 'Dra. López Martínez', 'lugaresDisponibles': 8, 'cupoMaximo': 25}),
    EtsModel.fromJson({'id': 'ETS-010', 'materia': 'Cálculo Multivariable', 'carrera': 'IA - Ingeniería en Inteligencia Artificial', 'semestre': 2, 'fecha': '14/07/2025', 'hora': '09:00', 'salon': 'Salón C-102', 'profesor': 'M.C. Ortega Luna', 'lugaresDisponibles': 0, 'cupoMaximo': 30}),
    // ── IA Semestre 5 ──
    EtsModel.fromJson({'id': 'ETS-011', 'materia': 'Aprendizaje de Máquina', 'carrera': 'IA - Ingeniería en Inteligencia Artificial', 'semestre': 5, 'fecha': '15/07/2025', 'hora': '15:00', 'salon': 'Lab. IA', 'profesor': 'Dra. Reyes Vargas', 'lugaresDisponibles': 6, 'cupoMaximo': 20}),
    EtsModel.fromJson({'id': 'ETS-012', 'materia': 'Visión Artificial', 'carrera': 'IA - Ingeniería en Inteligencia Artificial', 'semestre': 5, 'fecha': '16/07/2025', 'hora': '11:00', 'salon': 'Lab. IA', 'profesor': 'Dr. Navarro Ibarra', 'lugaresDisponibles': 14, 'cupoMaximo': 20}),
    // ── LCD Semestre 1 ──
    EtsModel.fromJson({'id': 'ETS-013', 'materia': 'Introducción a la Ciencia de Datos', 'carrera': 'LCD - Licenciatura en Ciencia de Datos', 'semestre': 1, 'fecha': '13/07/2025', 'hora': '09:00', 'salon': 'Salón D-401', 'profesor': 'Dr. Hernández Vidal', 'lugaresDisponibles': 30, 'cupoMaximo': 45}),
    EtsModel.fromJson({'id': 'ETS-014', 'materia': 'Cálculo', 'carrera': 'LCD - Licenciatura en Ciencia de Datos', 'semestre': 1, 'fecha': '14/07/2025', 'hora': '07:00', 'salon': 'Salón D-402', 'profesor': 'M.C. Ramos Torres', 'lugaresDisponibles': 11, 'cupoMaximo': 40}),
    // ── LCD Semestre 5 ──
    EtsModel.fromJson({'id': 'ETS-015', 'materia': 'Minería de Datos', 'carrera': 'LCD - Licenciatura en Ciencia de Datos', 'semestre': 5, 'fecha': '17/07/2025', 'hora': '13:00', 'salon': 'Lab. Datos', 'profesor': 'Dra. Castro Medina', 'lugaresDisponibles': 4, 'cupoMaximo': 25}),
  ];

  // ─── MÉTODOS PÚBLICOS ─────────────────────────────────────

  List<String> obtenerCarreras() => List.unmodifiable(_carreras);

  List<String> obtenerMaterias({
    required String carrera,
    required int semestre,
  }) {
    return _materias[carrera]?[semestre] ?? [];
  }

  List<int> obtenerSemestres({required String carrera}) {
    final mapa = _materias[carrera];
    if (mapa == null) return [];
    return mapa.keys.toList()..sort();
  }

  Future<List<EtsModel>> buscarEts({
    String? carrera,
    int? semestre,
    String? materia,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _ets.where((e) {
      final okCarrera = carrera == null || e.carrera == carrera;
      final okSemestre = semestre == null || e.semestre == semestre;
      final okMateria = materia == null || e.materia == materia;
      return okCarrera && okSemestre && okMateria;
    }).toList();
  }
}
