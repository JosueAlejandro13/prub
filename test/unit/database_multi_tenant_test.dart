import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SQLite Multi-Tenant Isolation', () {
    late Database db;

    setUp(() async {
      db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE saved_characters (
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
        },
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('los registros guardados por el investigador A no son visibles para el investigador B', () async {
      const phoneA = '5511111111';
      const phoneB = '5522222222';

      await db.insert('saved_characters', {
        'id': 1,
        'user_phone': phoneA,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'origin_name': 'Earth (C-137)',
        'location_name': 'Citadel',
        'image': 'https://example.com/rick.png',
        'episode_count': 51,
        'notes': 'Notas secretas de Investigador A',
        'saved_at': DateTime.now().toIso8601String(),
      });

      await db.insert('saved_characters', {
        'id': 2,
        'user_phone': phoneB,
        'name': 'Morty Smith',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'origin_name': 'Earth (C-137)',
        'location_name': 'Earth',
        'image': 'https://example.com/morty.png',
        'episode_count': 45,
        'notes': 'Notas de Investigador B',
        'saved_at': DateTime.now().toIso8601String(),
      });

      final resultsA = await db.query(
        'saved_characters',
        where: 'user_phone = ?',
        whereArgs: [phoneA],
      );
      final resultsB = await db.query(
        'saved_characters',
        where: 'user_phone = ?',
        whereArgs: [phoneB],
      );

      expect(resultsA.length, 1);
      expect(resultsA.first['name'], 'Rick Sanchez');
      expect(resultsA.first['notes'], 'Notas secretas de Investigador A');

      expect(resultsB.length, 1);
      expect(resultsB.first['name'], 'Morty Smith');
      expect(resultsB.first['notes'], 'Notas de Investigador B');

      final crossCheck = resultsB.any((row) => row['name'] == 'Rick Sanchez');
      expect(crossCheck, false);
    });

    test('dos investigadores pueden guardar el mismo personaje con notas independientes', () async {
      const phoneA = '5511111111';
      const phoneB = '5522222222';
      const sharedCharacterId = 1;

      await db.insert('saved_characters', {
        'id': sharedCharacterId,
        'user_phone': phoneA,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'origin_name': 'Earth (C-137)',
        'location_name': 'Citadel',
        'image': 'https://example.com/rick.png',
        'episode_count': 51,
        'notes': 'Investigar portal gun',
        'saved_at': DateTime.now().toIso8601String(),
      });

      await db.insert('saved_characters', {
        'id': sharedCharacterId,
        'user_phone': phoneB,
        'name': 'Rick Sanchez',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'origin_name': 'Earth (C-137)',
        'location_name': 'Citadel',
        'image': 'https://example.com/rick.png',
        'episode_count': 51,
        'notes': 'Interrogar por incidente en dimensión C-137',
        'saved_at': DateTime.now().toIso8601String(),
      });

      final rowA = await db.query(
        'saved_characters',
        where: 'id = ? AND user_phone = ?',
        whereArgs: [sharedCharacterId, phoneA],
      );
      final rowB = await db.query(
        'saved_characters',
        where: 'id = ? AND user_phone = ?',
        whereArgs: [sharedCharacterId, phoneB],
      );

      expect(rowA.first['notes'], 'Investigar portal gun');
      expect(rowB.first['notes'], 'Interrogar por incidente en dimensión C-137');
    });
  });
}
