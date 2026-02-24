class UsersTable {
  static const String tableName = 'users';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      theme TEXT DEFAULT 'light',
      language TEXT DEFAULT 'pt_BR',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      synced INTEGER DEFAULT 0
    )
  ''';

  static const String id = 'id';
  static const String name = 'name';
  static const String email = 'email';
  static const String theme = 'theme';
  static const String language = 'language';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String synced = 'synced';
}
