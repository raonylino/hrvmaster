import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/database/tables/users_table.dart';
import '../../../shared/models/user_model.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  void _init() {
    final user = _auth.currentUser;
    if (user != null) {
      _loadUserFromDb(user.uid);
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> _loadUserFromDb(String uid) async {
    final rows = await _db.query(
      UsersTable.tableName,
      where: '${UsersTable.id} = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (rows.isNotEmpty) {
      state = AsyncValue.data(UserModel.fromMap(rows.first));
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _loadUserFromDb(cred.user!.uid);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Login failed', st);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final now = DateTime.now();
      final user = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        createdAt: now,
        updatedAt: now,
      );
      await _db.insert(UsersTable.tableName, user.toMap());
      state = AsyncValue.data(user);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Registration failed', st);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUserPreferences({
    String? theme,
    String? language,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(
      theme: theme ?? current.theme,
      language: language ?? current.language,
      updatedAt: DateTime.now(),
    );

    await _db.update(
      UsersTable.tableName,
      updated.toMap(),
      '${UsersTable.id} = ?',
      [updated.id],
    );

    final prefs = await SharedPreferences.getInstance();
    if (theme != null) await prefs.setString('theme', theme);
    if (language != null) await prefs.setString('language', language);

    state = AsyncValue.data(updated);
  }
}
