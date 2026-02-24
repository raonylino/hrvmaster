import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/sync/connectivity_service.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_provider.dart';

class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final l10n = AppLocalizations.of(context);

    final isOnline = connectivity.valueOrNull ?? false;

    Color color;
    IconData icon;
    String label;

    if (!isOnline) {
      color = Colors.orange;
      icon = Icons.wifi_off;
      label = l10n.offline;
    } else if (syncStatus == 'syncing') {
      color = AppColors.primaryLight;
      icon = Icons.sync;
      label = l10n.syncing;
    } else {
      color = AppColors.success;
      icon = Icons.cloud_done;
      label = l10n.synced;
    }

    return GestureDetector(
      onTap: isOnline
          ? () => ref.read(homeProvider.notifier).triggerSync()
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
