import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/storage/database_helper.dart';
import '../../../characters/presentation/providers/character_di_providers.dart';
import '../../domain/models/researcher_profile.dart';
import 'auth_provider.dart';

/// Notifier para gestionar los datos de perfil del investigador en SQLite
class ProfileNotifier extends Notifier<ResearcherProfile> {
  DatabaseHelper get _dbHelper => ref.read(databaseHelperProvider);

  String get _currentPhone {
    final authState = ref.read(authNotifierProvider);
    final phone = authState.researcher?.phone ?? '';
    if (phone.isNotEmpty) return phone;
    return state.phone;
  }

  @override
  ResearcherProfile build() {
    final authState = ref.watch(authNotifierProvider);
    final phone = authState.researcher?.phone ?? '';
    if (phone.isNotEmpty) {
      Future.microtask(() => loadProfile());
    }
    return ResearcherProfile(phone: phone);
  }

  /// Carga el perfil del investigador desde SQLite
  Future<void> loadProfile() async {
    final phone = _currentPhone;
    if (phone.isEmpty) return;

    try {
      final db = await _dbHelper.database;
      await _dbHelper.ensureTablesExist();
      final results = await db.query(
        'researcher_profiles',
        where: 'phone = ?',
        whereArgs: [phone],
        limit: 1,
      );

      if (results.isNotEmpty) {
        state = ResearcherProfile.fromMap(results.first);
      } else {
        state = ResearcherProfile(phone: phone);
      }
    } catch (_) {
      state = ResearcherProfile(phone: phone);
    }
  }

  /// Guarda o actualiza el perfil en SQLite
  Future<void> updateProfile({
    required String name,
    required String rank,
    required String dimension,
    String notes = '',
  }) async {
    final phone = _currentPhone;
    if (phone.isEmpty) return;

    final updated = ResearcherProfile(
      phone: phone,
      name: name,
      rank: rank,
      dimension: dimension,
      notes: notes,
    );

    // Actualiza el estado reactivo inmediatamente para la UI
    state = updated;

    try {
      final db = await _dbHelper.database;
      await _dbHelper.ensureTablesExist();
      await db.insert(
        'researcher_profiles',
        updated.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Si ocurre error en SQLite, el estado en memoria ya quedó actualizado
    }
  }
}

/// Provider de perfil del investigador
final profileProvider = NotifierProvider<ProfileNotifier, ResearcherProfile>(ProfileNotifier.new);
