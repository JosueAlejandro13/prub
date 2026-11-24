import 'package:flutter_test/flutter_test.dart';
import 'package:multiverse_explorers/features/characters/data/models/character_model.dart';

void main() {
  group('CharacterModel', () {
    final sampleJson = {
      'id': 1,
      'name': 'Rick Sanchez',
      'status': 'Alive',
      'species': 'Human',
      'type': '',
      'gender': 'Male',
      'origin': {'name': 'Earth (C-137)', 'url': 'https://rickandmortyapi.com/api/location/1'},
      'location': {'name': 'Citadel of Ricks', 'url': 'https://rickandmortyapi.com/api/location/3'},
      'image': 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
      'episode': ['https://rickandmortyapi.com/api/episode/1', 'https://rickandmortyapi.com/api/episode/2'],
    };

    test('fromJson parsea correctamente el payload de la API', () {
      final model = CharacterModel.fromJson(sampleJson);

      expect(model.id, 1);
      expect(model.name, 'Rick Sanchez');
      expect(model.status, 'Alive');
      expect(model.species, 'Human');
      expect(model.gender, 'Male');
      expect(model.originName, 'Earth (C-137)');
      expect(model.locationName, 'Citadel of Ricks');
      expect(model.episodeCount, 2);
      expect(model.isSaved, false);
      expect(model.notes, isNull);
    });

    test('toSavedSqliteMap asocia correctamente el celular y las notas', () {
      final model = CharacterModel.fromJson(sampleJson);
      final map = model.toSavedSqliteMap('5512345678');

      expect(map['id'], 1);
      expect(map['user_phone'], '5512345678');
      expect(map['name'], 'Rick Sanchez');
      expect(map['origin_name'], 'Earth (C-137)');
      expect(map['episode_count'], 2);
      expect(map['saved_at'], isNotNull);
    });

    test('fromSqlite reconstruye el modelo persistido con estado isSaved', () {
      final sqliteMap = {
        'id': 2,
        'name': 'Morty Smith',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'gender': 'Male',
        'origin_name': 'Earth (C-137)',
        'location_name': 'Citadel of Ricks',
        'image': 'https://example.com/morty.png',
        'episode_count': 51,
        'notes': 'Sujeto de pruebas dimensional',
      };

      final model = CharacterModel.fromSqlite(sqliteMap, isSaved: true);

      expect(model.id, 2);
      expect(model.name, 'Morty Smith');
      expect(model.notes, 'Sujeto de pruebas dimensional');
      expect(model.isSaved, true);
    });

    test('toCachedSqliteMap genera estructura sin campo user_phone', () {
      final model = CharacterModel.fromJson(sampleJson);
      final map = model.toCachedSqliteMap();

      expect(map['id'], 1);
      expect(map.containsKey('user_phone'), false);
      expect(map['cached_at'], isNotNull);
    });
  });
}
