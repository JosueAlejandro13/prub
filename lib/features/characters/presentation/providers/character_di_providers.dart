import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/database_helper.dart';
import '../../data/datasources/character_local_data_source.dart';
import '../../data/datasources/character_remote_data_source.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../domain/repositories/character_repository.dart';

/// Provider de conectividad
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

/// Stream provider de cambios en la conexión de red
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});

/// Provider del cliente API
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider de la base de datos local SQLite
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// Provider de la fuente de datos remota
final characterRemoteDataSourceProvider = Provider<CharacterRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CharacterRemoteDataSource(apiClient);
});

/// Provider de la fuente de datos local
final characterLocalDataSourceProvider = Provider<CharacterLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return CharacterLocalDataSource(dbHelper);
});

/// Provider del repositorio de personajes
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  final remote = ref.watch(characterRemoteDataSourceProvider);
  final local = ref.watch(characterLocalDataSourceProvider);
  final net = ref.watch(networkInfoProvider);
  return CharacterRepositoryImpl(remote, local, net);
});
