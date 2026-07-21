import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Shared database. Overridden in `main()` (and tests) with an
/// already-opened/bootstrapped instance.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);
