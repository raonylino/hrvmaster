import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../database/database_helper.dart';
import '../database/tables/sync_queue_table.dart';
import '../database/tables/measurements_table.dart';
import 'sync_queue_service.dart';

class SyncService {
  final DatabaseHelper _db = DatabaseHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SyncQueueService _queueService = SyncQueueService();

  Future<void> syncAll() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _processSyncQueue();
    await _pullFromFirestore(user.uid);
  }

  Future<void> _processSyncQueue() async {
    final queue = await _queueService.getPendingItems();

    for (final item in queue) {
      try {
        final tableName = item[SyncQueueTable.tableName_] as String;
        final operation = item[SyncQueueTable.operation] as String;
        final payload =
            jsonDecode(item[SyncQueueTable.payload] as String)
                as Map<String, dynamic>;
        final recordId = item[SyncQueueTable.recordId] as String;
        final itemId = item[SyncQueueTable.id] as String;

        final collection = _firestore.collection(tableName);

        switch (operation) {
          case 'insert':
          case 'update':
            await collection.doc(recordId).set(payload);
            break;
          case 'delete':
            await collection.doc(recordId).delete();
            break;
        }

        await _queueService.removeItem(itemId);
      } catch (_) {
        await _queueService.incrementAttempts(
          item[SyncQueueTable.id] as String,
        );
      }
    }
  }

  Future<void> _pullFromFirestore(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(MeasurementsTable.tableName)
          .where('user_id', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['synced'] = 1;
        await _db.insert(MeasurementsTable.tableName, data);
      }
    } catch (_) {
      // Silently fail - we will retry on next sync
    }
  }
}
