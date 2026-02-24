class MeasurementsTable {
  static const String tableName = 'measurements';

  static const String createTable = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      duration_seconds INTEGER,
      position TEXT,
      method TEXT,
      device_name TEXT,
      rmssd REAL,
      sdnn REAL,
      pnn50 REAL,
      lf REAL,
      hf REAL,
      lf_hf_ratio REAL,
      sd1 REAL,
      sd2 REAL,
      rr_intervals TEXT,
      synced INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  static const String id = 'id';
  static const String userId = 'user_id';
  static const String date = 'date';
  static const String durationSeconds = 'duration_seconds';
  static const String position = 'position';
  static const String method = 'method';
  static const String deviceName = 'device_name';
  static const String rmssd = 'rmssd';
  static const String sdnn = 'sdnn';
  static const String pnn50 = 'pnn50';
  static const String lf = 'lf';
  static const String hf = 'hf';
  static const String lfHfRatio = 'lf_hf_ratio';
  static const String sd1 = 'sd1';
  static const String sd2 = 'sd2';
  static const String rrIntervals = 'rr_intervals';
  static const String synced = 'synced';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
