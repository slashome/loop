import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/profile.dart';

/// Local profiles (multi-account on the same device, no server).
class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Stream<List<Profile>> watchAll() => _db.watchProfiles().map(
        (rows) => rows
            .map((r) => Profile(id: r.id, name: r.name, createdAt: r.createdAt))
            .toList(),
      );

  /// Creates a profile and returns its id.
  Future<String> create(String name) async {
    final id = const Uuid().v7();
    await _db.upsertProfile(
      ProfileRowsCompanion.insert(
        id: id,
        name: name.trim(),
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  Future<void> rename(String id, String name) =>
      _db.renameProfile(id, name.trim());
}
