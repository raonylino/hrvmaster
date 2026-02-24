class UserModel {
  final String id;
  final String name;
  final String email;
  final String theme;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.theme = 'light',
    this.language = 'pt_BR',
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      theme: map['theme'] as String? ?? 'light',
      language: map['language'] as String? ?? 'pt_BR',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      synced: (map['synced'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'theme': theme,
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? theme,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }
}
