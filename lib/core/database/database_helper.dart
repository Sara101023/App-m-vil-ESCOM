// ============================================================
// DATABASE HELPER — Gestión de SQLite con sqflite
// ============================================================
// Esta clase es un Singleton: solo existe UNA instancia en toda la app.
// Maneja la creación, migración y acceso a la base de datos local.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/crypto_helper.dart';

class DatabaseHelper {
  // ── Singleton pattern ─────────────────────────────────────
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  // Getter: si la DB ya existe, la retorna; si no, la inicializa.
  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // Obtiene la ruta de la carpeta de bases de datos del dispositivo
    final dbPath = await getDatabasesPath();
    // Construye la ruta completa: /data/.../databases/ets_escom.db
    final path = join(dbPath, 'ets_escom.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,      // Se llama solo la primera vez
      onUpgrade: _onUpgrade,    // Se llama cuando cambia la versión
    );
  }

  // Crea todas las tablas al instalar la app por primera vez
  Future<void> _onCreate(Database db, int version) async {
    // ── Tabla de administradores ──────────────────────────
    await db.execute('''
      CREATE TABLE admins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        nombre TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // ── Tabla de ETS (para el módulo admin) ───────────────
    await db.execute('''
      CREATE TABLE ets (
        id TEXT PRIMARY KEY,
        materia TEXT NOT NULL,
        carrera TEXT NOT NULL,
        semestre INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        salon TEXT NOT NULL,
        profesor TEXT NOT NULL,
        lugares_disponibles INTEGER NOT NULL,
        cupo_maximo INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Tabla de ETS favoritos (guardados por el usuario) ─
    await db.execute('''
      CREATE TABLE favoritos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ets_id TEXT NOT NULL,
        materia TEXT NOT NULL,
        carrera TEXT NOT NULL,
        semestre INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        salon TEXT NOT NULL,
        profesor TEXT NOT NULL,
        saved_at TEXT NOT NULL
      )
    ''');

    // ── Insertar admin por defecto ────────────────────────
    // Usuario: admin | Contraseña: admin123
    await db.insert('admins', {
      'username': 'admin',
      'password_hash': CryptoHelper.hashPassword('admin123'),
      'nombre': 'Administrador ESCOM',
      'created_at': DateTime.now().toIso8601String(),
    });

    // ── Insertar ETS de ejemplo ───────────────────────────
    await _insertarEtsIniciales(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Aquí manejarías migraciones futuras.
    // Por ahora está vacío porque solo tenemos la versión 1.
  }

  // Inserta datos de ejemplo para que el admin tenga algo que ver
  Future<void> _insertarEtsIniciales(Database db) async {
    final ahora = DateTime.now().toIso8601String();
    final etsIniciales = [
      {'id': 'ETS-001', 'materia': 'Cálculo', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 1, 'fecha': '12/07/2025', 'hora': '07:00', 'salon': 'Salón A-101', 'profesor': 'Dr. Ramírez Hernández', 'lugares_disponibles': 15, 'cupo_maximo': 40, 'created_at': ahora, 'updated_at': ahora},
      {'id': 'ETS-002', 'materia': 'Fundamentos de Programación', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 1, 'fecha': '14/07/2025', 'hora': '09:00', 'salon': 'Lab. Cómputo 1', 'profesor': 'M.C. Torres Gutiérrez', 'lugares_disponibles': 0, 'cupo_maximo': 35, 'created_at': ahora, 'updated_at': ahora},
      {'id': 'ETS-003', 'materia': 'Algoritmos y Estructuras de Datos', 'carrera': 'ISC - Ingeniería en Sistemas Computacionales', 'semestre': 2, 'fecha': '13/07/2025', 'hora': '07:00', 'salon': 'Lab. Cómputo 2', 'profesor': 'M.C. Sánchez Pérez', 'lugares_disponibles': 12, 'cupo_maximo': 35, 'created_at': ahora, 'updated_at': ahora},
      {'id': 'ETS-004', 'materia': 'Aprendizaje de Máquina', 'carrera': 'IA - Ingeniería en Inteligencia Artificial', 'semestre': 5, 'fecha': '15/07/2025', 'hora': '15:00', 'salon': 'Lab. IA', 'profesor': 'Dra. Reyes Vargas', 'lugares_disponibles': 6, 'cupo_maximo': 20, 'created_at': ahora, 'updated_at': ahora},
      {'id': 'ETS-005', 'materia': 'Introducción a la Ciencia de Datos', 'carrera': 'LCD - Licenciatura en Ciencia de Datos', 'semestre': 1, 'fecha': '13/07/2025', 'hora': '09:00', 'salon': 'Salón D-401', 'profesor': 'Dr. Hernández Vidal', 'lugares_disponibles': 30, 'cupo_maximo': 45, 'created_at': ahora, 'updated_at': ahora},
    ];
    for (final ets in etsIniciales) {
      await db.insert('ets', ets);
    }
  }

  // ─── MÉTODOS CRUD PARA ETS ────────────────────────────────

  Future<List<Map<String, dynamic>>> getEts({
    String? carrera,
    int? semestre,
    String? materia,
  }) async {
    final db = await database;
    String where = '1=1';
    final args = <dynamic>[];
    if (carrera != null) { where += ' AND carrera = ?'; args.add(carrera); }
    if (semestre != null) { where += ' AND semestre = ?'; args.add(semestre); }
    if (materia != null) { where += ' AND materia = ?'; args.add(materia); }
    return db.query('ets', where: where, whereArgs: args, orderBy: 'fecha ASC');
  }

  Future<int> insertEts(Map<String, dynamic> ets) async {
    final db = await database;
    return db.insert('ets', ets, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateEts(Map<String, dynamic> ets) async {
    final db = await database;
    return db.update('ets', ets, where: 'id = ?', whereArgs: [ets['id']]);
  }

  Future<int> deleteEts(String id) async {
    final db = await database;
    return db.delete('ets', where: 'id = ?', whereArgs: [id]);
  }

  // ─── MÉTODOS PARA FAVORITOS ───────────────────────────────

  Future<List<Map<String, dynamic>>> getFavoritos() async {
    final db = await database;
    return db.query('favoritos', orderBy: 'saved_at DESC');
  }

  Future<int> insertFavorito(Map<String, dynamic> favorito) async {
    final db = await database;
    return db.insert('favoritos', favorito, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> deleteFavorito(String etsId) async {
    final db = await database;
    return db.delete('favoritos', where: 'ets_id = ?', whereArgs: [etsId]);
  }

  Future<bool> esFavorito(String etsId) async {
    final db = await database;
    final result = await db.query('favoritos', where: 'ets_id = ?', whereArgs: [etsId]);
    return result.isNotEmpty;
  }

  // ─── MÉTODOS PARA AUTH ────────────────────────────────────

  Future<Map<String, dynamic>?> getAdmin(String username) async {
    final db = await database;
    final result = await db.query('admins', where: 'username = ?', whereArgs: [username]);
    return result.isNotEmpty ? result.first : null;
  }

  // ─── ESTADÍSTICAS PARA EL DASHBOARD ──────────────────────

  Future<Map<String, int>> getEstadisticas() async {
    final db = await database;
    final total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ets')) ?? 0;
    final conLugares = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ets WHERE lugares_disponibles > 0')) ?? 0;
    final sinLugares = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ets WHERE lugares_disponibles = 0')) ?? 0;
    final favoritos = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM favoritos')) ?? 0;

    // ETS por carrera
    final porCarrera = await db.rawQuery('SELECT carrera, COUNT(*) as total FROM ets GROUP BY carrera');

    final Map<String, int> stats = {
      'total': total,
      'con_lugares': conLugares,
      'sin_lugares': sinLugares,
      'favoritos': favoritos,
    };

    for (final row in porCarrera) {
      // Clave corta: "ISC", "IA", "LCD"
      final carrera = (row['carrera'] as String).split(' - ').first;
      stats['carrera_$carrera'] = (row['total'] as int);
    }

    return stats;
  }
}