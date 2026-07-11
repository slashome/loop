import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import '../data/recurrence_repository.dart';
import '../domain/recurrence.dart';

final recurrenceRepositoryProvider = Provider<RecurrenceRepository>(
  (ref) => RecurrenceRepository(ref.watch(appDatabaseProvider)),
);

/// Flux de toutes les récurrences (non supprimées), pour l'onglet Repeats.
final recurrencesProvider = StreamProvider<List<Recurrence>>(
  (ref) => ref.watch(recurrenceRepositoryProvider).watchAll(),
);
