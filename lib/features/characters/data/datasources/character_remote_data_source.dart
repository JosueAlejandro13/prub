import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/character_model.dart';

/// Fuente de datos remota mediante la API pública de Rick and Morty
class CharacterRemoteDataSource {
  final ApiClient _apiClient;

  CharacterRemoteDataSource(this._apiClient);

  /// Consulta la lista de personajes con paginación y filtros opcionales
  Future<List<CharacterModel>> fetchCharacters({
    int page = 1,
    String? name,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
    };

    if (name != null && name.trim().isNotEmpty) {
      queryParameters['name'] = name.trim();
    }
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParameters['status'] = status.toLowerCase();
    }

    try {
      final response = await _apiClient.dio.get(
        ApiConstants.charactersEndpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>;
        return results
            .map((item) => CharacterModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // La API de Rick and Morty retorna 404 cuando no hay coincidencias con la búsqueda
        return [];
      }
      rethrow;
    }
  }
}
