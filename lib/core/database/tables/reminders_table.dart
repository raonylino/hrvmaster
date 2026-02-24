class RemindersTable {
  static const String tableName = 'reminders';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      time TEXT NOT NULL,
      days TEXT NOT NULL,
      active INTEGER DEFAULT 1,
      synced INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static const String id = 'id';
  static const String userId = 'user_id';
  static const String time = 'time';
  static const String days = 'days';
  static const String active = 'active';
  static const String synced = 'synced';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
