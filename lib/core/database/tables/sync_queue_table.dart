class SyncQueueTable {
  static const String tableName = 'sync_queue';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      table_name TEXT NOT NULL,
      record_id TEXT NOT NULL,
      operation TEXT NOT NULL,
      payload TEXT NOT NULL,
      created_at TEXT NOT NULL,
      attempts INTEGER DEFAULT 0
    )
  ''';

  static const String id = 'id';
  static const String tableName_ = 'table_name';
  static const String recordId = 'record_id';
  static const String operation = 'operation';
  static const String payload = 'payload';
  static const String createdAt = 'created_at';
  static const String attempts = 'attempts';
}
