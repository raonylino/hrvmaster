import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/database/tables/users_table.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserModel?>>((ref) {
  return ProfileNotifier(ref);
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  ProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref ref;
  final DatabaseHelper _db = DatabaseHelper();

  void _load() {
    final user = ref.read(authProvider).valueOrNull;
    state = AsyncValue.data(user);
  }

  Future<void> updateName(String name) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = current.copyWith(name: name, updatedAt: DateTime.now());
    await _db.update(
      UsersTable.tableName,
      updated.toMap(),
      '${UsersTable.id} = ?',
      [updated.id],
    );
    state = AsyncValue.data(updated);
  }

  Future<void> updateTheme(String theme) async {
    await ref.read(authProvider.notifier).updateUserPreferences(theme: theme);
    _load();
  }

  Future<void> updateLanguage(String language) async {
    await ref
        .read(authProvider.notifier)
        .updateUserPreferences(language: language);
    _load();
  }
}
