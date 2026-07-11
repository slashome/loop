import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Base de données partagée. Surchargé dans `main()` (et les tests) par une
/// instance déjà ouverte/amorcée.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);
