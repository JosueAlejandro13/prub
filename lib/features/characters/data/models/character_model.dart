import '../../domain/entities/character.dart';

/// Modelo de personaje con serialización JSON y mapeo SQLite
class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.name,
    required super.status,
    required super.species,
    required super.type,
    required super.gender,
    required super.originName,
    required super.locationName,
    required super.image,
    required super.episodeCount,
    super.notes,
    super.isSaved,
  });

  /// Crea una instancia desde la respuesta JSON de la API
  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Desconocido',
      status: json['status'] as String? ?? 'unknown',
      species: json['species'] as String? ?? 'unknown',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? 'unknown',
      originName: (json['origin'] != null && json['origin']['name'] != null)
          ? json['origin']['name'] as String
          : 'Desconocido',
      locationName: (json['location'] != null && json['location']['name'] != null)
          ? json['location']['name'] as String
          : 'Desconocido',
      image: json['image'] as String? ?? '',
      episodeCount: (json['episode'] as List?)?.length ?? 0,
      notes: null,
      isSaved: false,
    );
  }

  /// Crea una instancia desde un registro de SQLite
  factory CharacterModel.fromSqlite(Map<String, dynamic> map, {bool isSaved = false}) {
    return CharacterModel(
      id: map['id'] as int,
      name: map['name'] as String,
      status: map['status'] as String,
      species: map['species'] as String,
      type: map['type'] as String? ?? '',
      gender: map['gender'] as String,
      originName: map['origin_name'] as String? ?? 'Desconocido',
      locationName: map['location_name'] as String? ?? 'Desconocido',
      image: map['image'] as String,
      episodeCount: map['episode_count'] as int? ?? 0,
      notes: map['notes'] as String?,
      isSaved: isSaved,
    );
  }

  /// Mapeo para guardar en SQLite asociando el número celular del investigador
  Map<String, dynamic> toSavedSqliteMap(String userPhone) {
    return {
      'id': id,
      'user_phone': userPhone,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin_name': originName,
      'location_name': locationName,
      'image': image,
      'episode_count': episodeCount,
      'notes': notes,
      'saved_at': DateTime.now().toIso8601String(),
    };
  }

  /// Mapeo para guardar en caché general de SQLite
  Map<String, dynamic> toCachedSqliteMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin_name': originName,
      'location_name': locationName,
      'image': image,
      'episode_count': episodeCount,
      'cached_at': DateTime.now().toIso8601String(),
    };
  }
}
