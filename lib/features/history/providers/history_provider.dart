import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/database/tables/measurements_table.dart';
import '../../../shared/models/measurement_model.dart';
import '../../auth/providers/auth_provider.dart';

final historyProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<List<MeasurementModel>>>(
  (ref) => HistoryNotifier(ref),
);

class HistoryNotifier
    extends StateNotifier<AsyncValue<List<MeasurementModel>>> {
  HistoryNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref ref;
  final DatabaseHelper _db = DatabaseHelper();

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authProvider).valueOrNull;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final rows = await _db.query(
        MeasurementsTable.tableName,
        where: '${MeasurementsTable.userId} = ?',
        whereArgs: [user.id],
        orderBy: '${MeasurementsTable.date} DESC',
      );

      state = AsyncValue.data(
        rows.map(MeasurementModel.fromMap).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    await _db.delete(
      MeasurementsTable.tableName,
      '${MeasurementsTable.id} = ?',
      [id],
    );
    await load();
  }
}
