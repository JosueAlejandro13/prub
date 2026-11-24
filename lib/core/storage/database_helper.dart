import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Administrador de la base de datos SQLite con aislamiento multi-usuario
class DatabaseHelper {
  static const String _dbName = 'multiverse_explorers.db';
  static const int _dbVersion = 3;

  static Database? _database;

  /// Retorna la instancia de la base de datos garantizando que las tablas existan
  Future<Database> get database async {
    if (_database != null) {
      await _createTables(_database!);
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos SQLite y crea las tablas
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
      },
      onOpen: (db) async {
        await _createTables(db);
      },
    );

    await _createTables(db);
    return db;
  }

  /// Asegura que todas las tablas requeridas existan
  Future<void> ensureTablesExist() async {
    final db = await database;
    await _createTables(db);
  }

  /// Crea las tablas si no existen
  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saved_characters (
        id INTEGER NOT NULL,
        user_phone TEXT NOT NULL,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        species TEXT NOT NULL,
        type TEXT,
        gender TEXT NOT NULL,
        origin_name TEXT,
        location_name TEXT,
        image TEXT NOT NULL,
        episode_count INTEGER NOT NULL,
        notes TEXT,
        saved_at TEXT NOT NULL,
        PRIMARY KEY (id, user_phone)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_characters (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        species TEXT NOT NULL,
        type TEXT,
        gender TEXT NOT NULL,
        origin_name TEXT,
        location_name TEXT,
        image TEXT NOT NULL,
        episode_count INTEGER NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS researcher_profiles (
        phone TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rank TEXT NOT NULL,
        dimension TEXT NOT NULL,
        notes TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  /// Guarda una configuración en la base local SQLite
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene una configuración desde la base local SQLite
  Future<String?> getSetting(String key) async {
    try {
      final db = await database;
      final results = await db.query(
        'app_settings',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      if (results.isNotEmpty) {
        return results.first['value'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
