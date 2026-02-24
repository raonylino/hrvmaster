import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../database/database_helper.dart';
import '../database/tables/sync_queue_table.dart';

class SyncQueueService {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  Future<void> enqueue({
    required String tableName,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _db.insert(SyncQueueTable.tableName, {
      SyncQueueTable.id: _uuid.v4(),
      SyncQueueTable.tableName_: tableName,
      SyncQueueTable.recordId: recordId,
      SyncQueueTable.operation: operation,
      SyncQueueTable.payload: jsonEncode(payload),
      SyncQueueTable.createdAt: DateTime.now().toIso8601String(),
      SyncQueueTable.attempts: 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingItems({int maxAttempts = 5}) async {
    return await _db.query(
      SyncQueueTable.tableName,
      where: '${SyncQueueTable.attempts} < ?',
      whereArgs: [maxAttempts],
      orderBy: SyncQueueTable.createdAt,
    );
  }

  Future<void> removeItem(String id) async {
    await _db.delete(
      SyncQueueTable.tableName,
      '${SyncQueueTable.id} = ?',
      [id],
    );
  }

  Future<void> incrementAttempts(String id) async {
    await _db.rawQuery(
      'UPDATE ${SyncQueueTable.tableName} SET ${SyncQueueTable.attempts} = ${SyncQueueTable.attempts} + 1 WHERE ${SyncQueueTable.id} = ?',
      [id],
    );
  }

  Future<int> getPendingCount() async {
    final items = await getPendingItems();
    return items.length;
  }
}
