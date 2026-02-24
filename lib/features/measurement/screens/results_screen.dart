import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/measurement_model.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/poincare_plot_widget.dart';
import '../../../shared/widgets/frequency_bar_chart.dart';
import '../providers/measurement_provider.dart';

class ResultsScreen extends ConsumerWidget {
  final MeasurementModel? measurement;

  const ResultsScreen({super.key, this.measurement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final m = measurement;

    if (m == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.results)),
        body: const Center(child: Text('No results available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.results),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(measurementProvider.notifier).reset();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date / method header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(m.date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${m.method ?? '-'} • ${m.position ?? '-'} • ${m.durationSeconds ?? 0}s',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time-domain metrics
            Text(
              'Domínio do Tempo',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                MetricCard(
                  label: l10n.rmssd,
                  value: m.rmssd?.toStringAsFixed(1) ?? '-',
                  unit: 'ms',
                  icon: Icons.favorite,
                ),
                MetricCard(
                  label: l10n.sdnn,
                  value: m.sdnn?.toStringAsFixed(1) ?? '-',
                  unit: 'ms',
                  icon: Icons.show_chart,
                ),
                MetricCard(
                  label: l10n.pnn50,
                  value: m.pnn50?.toStringAsFixed(1) ?? '-',
                  unit: '%',
                  icon: Icons.percent,
                ),
                MetricCard(
                  label: l10n.lfHfRatio,
                  value: m.lfHfRatio?.toStringAsFixed(2) ?? '-',
                  icon: Icons.balance,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Poincaré plot
            Text(
              'Diagrama de Poincaré',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PoincareplotWidget(
                        rrIntervals: m.rrIntervals,
                        sd1: m.sd1,
                        sd2: m.sd2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('SD1: ${m.sd1?.toStringAsFixed(1) ?? '-'} ms'),
                        Text('SD2: ${m.sd2?.toStringAsFixed(1) ?? '-'} ms'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Frequency domain
            Text(
              'Domínio da Frequência',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 160,
                      child: FrequencyBarChart(
                        lf: m.lf ?? 0,
                        hf: m.hf ?? 0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('LF: ${m.lf?.toStringAsFixed(2) ?? '-'}'),
                        Text('HF: ${m.hf?.toStringAsFixed(2) ?? '-'}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
