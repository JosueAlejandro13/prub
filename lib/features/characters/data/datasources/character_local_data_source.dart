import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_helper.dart';
import '../models/character_model.dart';

/// Fuente de datos local en SQLite con aislamiento por investigador
class CharacterLocalDataSource {
  final DatabaseHelper _dbHelper;

  CharacterLocalDataSource(this._dbHelper);

  /// Guarda una lista de personajes en la caché general
  Future<void> cacheCharacters(List<CharacterModel> characters) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final char in characters) {
      batch.insert(
        'cached_characters',
        char.toCachedSqliteMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Obtiene personajes de la caché con filtros opcionales
  Future<List<CharacterModel>> getCachedCharacters({String? name, String? status}) async {
    final db = await _dbHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (name != null && name.trim().isNotEmpty) {
      whereClause = 'name LIKE ?';
      whereArgs.add('%$name%');
    }
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'status = ?';
      whereArgs.add(status.toLowerCase());
    }

    final List<Map<String, dynamic>> records = await db.query(
      'cached_characters',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'id ASC',
    );

    return records.map((map) => CharacterModel.fromSqlite(map)).toList();
  }

  /// Guarda un personaje para la misión de un investigador específico
  Future<void> saveCharacterForUser(
    CharacterModel character,
    String userPhone, {
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    final map = character.toSavedSqliteMap(userPhone);
    if (notes != null) {
      map['notes'] = notes;
    }
    await db.insert(
      'saved_characters',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtiene los personajes guardados de un investigador específico
  Future<List<CharacterModel>> getSavedCharactersForUser(String userPhone) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> records = await db.query(
      'saved_characters',
      where: 'user_phone = ?',
      whereArgs: [userPhone],
      orderBy: 'saved_at DESC',
    );

    return records.map((map) => CharacterModel.fromSqlite(map, isSaved: true)).toList();
  }

  /// Remueve un personaje guardado para un investigador específico
  Future<void> removeCharacterForUser(int characterId, String userPhone) async {
    final db = await _dbHelper.database;
    await db.delete(
      'saved_characters',
      where: 'id = ? AND user_phone = ?',
      whereArgs: [characterId, userPhone],
    );
  }

  /// Comprueba si el personaje ya fue guardado por el investigador
  Future<bool> isSavedForUser(int characterId, String userPhone) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'saved_characters',
      where: 'id = ? AND user_phone = ?',
      whereArgs: [characterId, userPhone],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
