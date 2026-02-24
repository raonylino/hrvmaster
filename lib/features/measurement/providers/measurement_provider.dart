import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/database/tables/measurements_table.dart';
import '../../../core/sync/sync_queue_service.dart';
import '../../../core/utils/hrv_calculator.dart';
import '../../../shared/models/measurement_model.dart';
import '../../auth/providers/auth_provider.dart';

enum MeasurementStatus { idle, measuring, processing, done, error }

class MeasurementState {
  final MeasurementStatus status;
  final int elapsedSeconds;
  final List<double> rrIntervals;
  final MeasurementModel? result;
  final String? errorMessage;

  const MeasurementState({
    this.status = MeasurementStatus.idle,
    this.elapsedSeconds = 0,
    this.rrIntervals = const [],
    this.result,
    this.errorMessage,
  });

  MeasurementState copyWith({
    MeasurementStatus? status,
    int? elapsedSeconds,
    List<double>? rrIntervals,
    MeasurementModel? result,
    String? errorMessage,
  }) {
    return MeasurementState(
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      rrIntervals: rrIntervals ?? this.rrIntervals,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final measurementProvider =
    StateNotifierProvider<MeasurementNotifier, MeasurementState>((ref) {
  return MeasurementNotifier(ref);
});

class MeasurementNotifier extends StateNotifier<MeasurementState> {
  MeasurementNotifier(this.ref) : super(const MeasurementState());

  final Ref ref;
  final DatabaseHelper _db = DatabaseHelper();
  final SyncQueueService _syncQueue = SyncQueueService();
  final Uuid _uuid = const Uuid();
  Timer? _timer;

  void startMeasurement(String method) {
    state = const MeasurementState(status: MeasurementStatus.measuring);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      // Simulate RR interval collection
      _addSimulatedRR();
    });
  }

  void _addSimulatedRR() {
    // Simulate realistic RR intervals (800-1000ms with variability)
    final rng = Random();
    final baseRR = 850 + rng.nextInt(150).toDouble();
    final variation = (rng.nextDouble() - 0.5) * 60;
    state = state.copyWith(
      rrIntervals: [...state.rrIntervals, baseRR + variation],
    );
  }

  void addRRInterval(double rr) {
    state = state.copyWith(rrIntervals: [...state.rrIntervals, rr]);
  }

  Future<void> stopAndProcess({
    required String method,
    String? deviceName,
    String? position,
  }) async {
    _timer?.cancel();
    state = state.copyWith(status: MeasurementStatus.processing);

    try {
      final rr = state.rrIntervals;
      if (rr.length < 10) {
        state = state.copyWith(
          status: MeasurementStatus.error,
          errorMessage: 'Not enough RR intervals collected',
        );
        return;
      }

      final metrics = HRVCalculator.calcAll(rr);
      final user = ref.read(authProvider).valueOrNull;
      final now = DateTime.now();

      final measurement = MeasurementModel(
        id: _uuid.v4(),
        userId: user?.id ?? 'anonymous',
        date: now,
        durationSeconds: state.elapsedSeconds,
        position: position,
        method: method,
        deviceName: deviceName,
        rmssd: metrics['rmssd'],
        sdnn: metrics['sdnn'],
        pnn50: metrics['pnn50'],
        lf: metrics['lf'],
        hf: metrics['hf'],
        lfHfRatio: metrics['lf_hf_ratio'],
        sd1: metrics['sd1'],
        sd2: metrics['sd2'],
        rrIntervals: rr,
        createdAt: now,
        updatedAt: now,
      );

      await _db.insert(MeasurementsTable.tableName, measurement.toMap());
      await _syncQueue.enqueue(
        tableName: MeasurementsTable.tableName,
        recordId: measurement.id,
        operation: 'insert',
        payload: measurement.toMap(),
      );

      state = state.copyWith(
        status: MeasurementStatus.done,
        result: measurement,
      );
    } catch (e) {
      state = state.copyWith(
        status: MeasurementStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    _timer?.cancel();
    state = const MeasurementState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
