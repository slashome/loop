import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/db/app_database.dart';
import '../domain/category.dart';

/// Source of truth for task categories, scoped to the current profile.
class CategoryRepository {
  CategoryRepository(this._db, {this.ownerId = AppDatabase.defaultProfileId});

  final AppDatabase _db;
  final String ownerId;

  Stream<List<Category>> watchAll() => _db.watchCategories(ownerId).map(
        (rows) => rows
            .map((r) => Category(id: r.id, name: r.name, iconKey: r.iconKey))
            .toList(),
      );

  Future<String> create(String name, String iconKey) async {
    final id = const Uuid().v7();
    await _db.upsertCategory(
      CategoryRowsCompanion.insert(
        id: id,
        ownerId: Value(ownerId),
        name: name.trim(),
        iconKey: iconKey,
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  Future<void> delete(String id) => _db.deleteCategory(id);
}
