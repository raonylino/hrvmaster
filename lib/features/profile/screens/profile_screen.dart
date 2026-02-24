import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../app/routes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileState = ref.watch(profileProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: profileState.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.loading));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  user.email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 32),
              // Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: Text(l10n.theme),
                      trailing: Switch(
                        value: themeMode == ThemeMode.dark,
                        activeColor: AppColors.primary,
                        onChanged: (isDark) {
                          final t = isDark ? 'dark' : 'light';
                          ref.read(themeProvider.notifier).setTheme(t);
                          ref
                              .read(profileProvider.notifier)
                              .updateTheme(t);
                        },
                      ),
                      subtitle: Text(themeMode == ThemeMode.dark
                          ? l10n.darkTheme
                          : l10n.lightTheme),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(l10n.language),
                      trailing: DropdownButton<String>(
                        value: locale.languageCode == 'en' ? 'en_US' : 'pt_BR',
                        underline: const SizedBox.shrink(),
                        items: [
                          DropdownMenuItem(
                            value: 'pt_BR',
                            child: Text(l10n.portuguese),
                          ),
                          DropdownMenuItem(
                            value: 'en_US',
                            child: Text(l10n.english),
                          ),
                        ],
                        onChanged: (lang) {
                          if (lang == null) return;
                          ref.read(localeProvider.notifier).setLocale(lang);
                          ref
                              .read(profileProvider.notifier)
                              .updateLanguage(lang);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.alarm),
                      title: Text(l10n.reminders),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.reminders),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    l10n.logout,
                    style: const TextStyle(color: AppColors.error),
                  ),
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.login);
                    }
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
