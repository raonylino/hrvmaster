import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/database/tables/measurements_table.dart';
import '../../../core/sync/connectivity_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/models/measurement_model.dart';
import '../../auth/providers/auth_provider.dart';

final recentMeasurementsProvider =
    FutureProvider<List<MeasurementModel>>((ref) async {
  final user = ref.watch(authProvider).valueOrNull;
  if (user == null) return [];

  final db = DatabaseHelper();
  final rows = await db.query(
    MeasurementsTable.tableName,
    where: '${MeasurementsTable.userId} = ?',
    whereArgs: [user.id],
    orderBy: '${MeasurementsTable.date} DESC',
    limit: 10,
  );
  return rows.map(MeasurementModel.fromMap).toList();
});

final syncStatusProvider = StateProvider<String>((ref) => 'idle');

class HomeNotifier extends StateNotifier<AsyncValue<void>> {
  HomeNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;
  final SyncService _syncService = SyncService();

  Future<void> triggerSync() async {
    final connectivity = ref.read(connectivityProvider);
    final isOnline = connectivity.valueOrNull ?? false;
    if (!isOnline) return;

    ref.read(syncStatusProvider.notifier).state = 'syncing';
    try {
      await _syncService.syncAll();
      ref.invalidate(recentMeasurementsProvider);
      ref.read(syncStatusProvider.notifier).state = 'synced';
    } catch (_) {
      ref.read(syncStatusProvider.notifier).state = 'error';
    }
  }
}

final homeProvider =
    StateNotifierProvider<HomeNotifier, AsyncValue<void>>((ref) {
  return HomeNotifier(ref);
});
