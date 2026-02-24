import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/offline_banner_widget.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(historyProvider.notifier).load(),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBannerWidget(),
          Expanded(
            child: historyState.when(
              data: (measurements) {
                if (measurements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history,
                            size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(l10n.noMeasurements),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: measurements.length,
                  itemBuilder: (context, index) {
                    final m = measurements[index];
                    return Dismissible(
                      key: Key(m.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: AppColors.error,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.deleteTitle),
                            content: Text(l10n.deleteConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) =>
                          ref.read(historyProvider.notifier).delete(m.id),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              m.rmssd?.toStringAsFixed(0) ?? '-',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(m.date),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'RMSSD: ${m.rmssd?.toStringAsFixed(1) ?? '-'} ms  •  SDNN: ${m.sdnn?.toStringAsFixed(1) ?? '-'} ms',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!m.synced)
                                const Icon(Icons.cloud_off,
                                    size: 16, color: AppColors.textMuted),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.measurementDetail,
                            arguments: m,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
