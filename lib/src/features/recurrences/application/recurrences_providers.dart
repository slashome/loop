import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import '../data/recurrence_repository.dart';
import '../domain/recurrence.dart';

final recurrenceRepositoryProvider = Provider<RecurrenceRepository>(
  (ref) => RecurrenceRepository(ref.watch(appDatabaseProvider)),
);

/// Stream of all recurrences (not deleted), for the Repeats tab.
final recurrencesProvider = StreamProvider<List<Recurrence>>(
  (ref) => ref.watch(recurrenceRepositoryProvider).watchAll(),
);
