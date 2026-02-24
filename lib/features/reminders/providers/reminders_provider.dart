import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/database/tables/reminders_table.dart';
import '../../auth/providers/auth_provider.dart';

class ReminderModel {
  final String id;
  final String userId;
  final String time; // HH:mm
  final List<int> days; // 1=Mon ... 7=Sun
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReminderModel({
    required this.id,
    required this.userId,
    required this.time,
    required this.days,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      time: map['time'] as String,
      days: (map['days'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map(int.parse)
          .toList(),
      active: (map['active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'time': time,
      'days': days.join(','),
      'active': active ? 1 : 0,
      'synced': 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

final remindersProvider =
    StateNotifierProvider<RemindersNotifier, AsyncValue<List<ReminderModel>>>(
  (ref) => RemindersNotifier(ref),
);

class RemindersNotifier
    extends StateNotifier<AsyncValue<List<ReminderModel>>> {
  RemindersNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  final Ref ref;
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authProvider).valueOrNull;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final rows = await _db.query(
        RemindersTable.tableName,
        where: '${RemindersTable.userId} = ?',
        whereArgs: [user.id],
        orderBy: RemindersTable.time,
      );
      state = AsyncValue.data(rows.map(ReminderModel.fromMap).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(String time, List<int> days) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;
    final now = DateTime.now();
    final reminder = ReminderModel(
      id: _uuid.v4(),
      userId: user.id,
      time: time,
      days: days,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insert(RemindersTable.tableName, reminder.toMap());
    await load();
  }

  Future<void> toggle(String id) async {
    final current = state.valueOrNull?.firstWhere((r) => r.id == id);
    if (current == null) return;
    await _db.update(
      RemindersTable.tableName,
      {'active': current.active ? 0 : 1},
      '${RemindersTable.id} = ?',
      [id],
    );
    await load();
  }

  Future<void> delete(String id) async {
    await _db.delete(
        RemindersTable.tableName, '${RemindersTable.id} = ?', [id]);
    await load();
  }
}
