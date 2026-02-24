import 'dart:convert';

class MeasurementModel {
  final String id;
  final String userId;
  final DateTime date;
  final int? durationSeconds;
  final String? position;
  final String? method;
  final String? deviceName;
  final double? rmssd;
  final double? sdnn;
  final double? pnn50;
  final double? lf;
  final double? hf;
  final double? lfHfRatio;
  final double? sd1;
  final double? sd2;
  final List<double> rrIntervals;
  final bool synced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MeasurementModel({
    required this.id,
    required this.userId,
    required this.date,
    this.durationSeconds,
    this.position,
    this.method,
    this.deviceName,
    this.rmssd,
    this.sdnn,
    this.pnn50,
    this.lf,
    this.hf,
    this.lfHfRatio,
    this.sd1,
    this.sd2,
    this.rrIntervals = const [],
    this.synced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MeasurementModel.fromMap(Map<String, dynamic> map) {
    List<double> rr = [];
    if (map['rr_intervals'] != null) {
      final decoded = jsonDecode(map['rr_intervals'] as String);
      rr = (decoded as List).map((e) => (e as num).toDouble()).toList();
    }

    return MeasurementModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      durationSeconds: map['duration_seconds'] as int?,
      position: map['position'] as String?,
      method: map['method'] as String?,
      deviceName: map['device_name'] as String?,
      rmssd: (map['rmssd'] as num?)?.toDouble(),
      sdnn: (map['sdnn'] as num?)?.toDouble(),
      pnn50: (map['pnn50'] as num?)?.toDouble(),
      lf: (map['lf'] as num?)?.toDouble(),
      hf: (map['hf'] as num?)?.toDouble(),
      lfHfRatio: (map['lf_hf_ratio'] as num?)?.toDouble(),
      sd1: (map['sd1'] as num?)?.toDouble(),
      sd2: (map['sd2'] as num?)?.toDouble(),
      rrIntervals: rr,
      synced: (map['synced'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String(),
      'duration_seconds': durationSeconds,
      'position': position,
      'method': method,
      'device_name': deviceName,
      'rmssd': rmssd,
      'sdnn': sdnn,
      'pnn50': pnn50,
      'lf': lf,
      'hf': hf,
      'lf_hf_ratio': lfHfRatio,
      'sd1': sd1,
      'sd2': sd2,
      'rr_intervals': jsonEncode(rrIntervals),
      'synced': synced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MeasurementModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    int? durationSeconds,
    String? position,
    String? method,
    String? deviceName,
    double? rmssd,
    double? sdnn,
    double? pnn50,
    double? lf,
    double? hf,
    double? lfHfRatio,
    double? sd1,
    double? sd2,
    List<double>? rrIntervals,
    bool? synced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MeasurementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      position: position ?? this.position,
      method: method ?? this.method,
      deviceName: deviceName ?? this.deviceName,
      rmssd: rmssd ?? this.rmssd,
      sdnn: sdnn ?? this.sdnn,
      pnn50: pnn50 ?? this.pnn50,
      lf: lf ?? this.lf,
      hf: hf ?? this.hf,
      lfHfRatio: lfHfRatio ?? this.lfHfRatio,
      sd1: sd1 ?? this.sd1,
      sd2: sd2 ?? this.sd2,
      rrIntervals: rrIntervals ?? this.rrIntervals,
      synced: synced ?? this.synced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
