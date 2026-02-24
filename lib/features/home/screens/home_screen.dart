import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/offline_banner_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/weekly_chart_widget.dart';
import '../widgets/sync_status_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final measurements = ref.watch(recentMeasurementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: SyncStatusWidget()),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBannerWidget(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(homeProvider.notifier).triggerSync(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    authState.when(
                      data: (user) => Text(
                        'Olá, ${user?.name ?? ''}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    measurements.when(
                      data: (data) => WeeklyChartWidget(measurements: data),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.lastMeasurements,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, AppRoutes.history),
                          child: const Text('Ver todos'),
                        ),
                      ],
                    ),
                    measurements.when(
                      data: (data) {
                        if (data.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(l10n.noMeasurements),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.length > 5 ? 5 : data.length,
                          itemBuilder: (context, index) {
                            final m = data[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.favorite,
                                    color: AppColors.primary),
                                title: Text(DateFormat('dd/MM/yyyy HH:mm')
                                    .format(m.date)),
                                subtitle: Text(
                                  'RMSSD: ${m.rmssd?.toStringAsFixed(1) ?? '-'} ms',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.measurementDetail,
                                  arguments: m,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, AppRoutes.history);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.reminders);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: l10n.history,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.alarm),
            label: l10n.reminders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.preMeasurement),
        icon: const Icon(Icons.favorite),
        label: Text(l10n.startMeasurement),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
