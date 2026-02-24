import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/measurement_model.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/poincare_plot_widget.dart';
import '../../../shared/widgets/frequency_bar_chart.dart';

class MeasurementDetailScreen extends ConsumerWidget {
  final MeasurementModel measurement;

  const MeasurementDetailScreen({super.key, required this.measurement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final m = measurement;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.measurementDetail)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(l10n.date,
                        DateFormat('dd/MM/yyyy HH:mm').format(m.date)),
                    _infoRow(l10n.method, m.method ?? '-'),
                    _infoRow(l10n.position, m.position ?? '-'),
                    _infoRow(l10n.duration,
                        '${m.durationSeconds ?? 0}s'),
                    if (m.deviceName != null)
                      _infoRow(l10n.device, m.deviceName!),
                    _infoRow(
                        l10n.syncStatus, m.synced ? l10n.synced : l10n.offline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.hrvMetrics,
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
                ),
                MetricCard(
                  label: l10n.sdnn,
                  value: m.sdnn?.toStringAsFixed(1) ?? '-',
                  unit: 'ms',
                ),
                MetricCard(
                  label: l10n.pnn50,
                  value: m.pnn50?.toStringAsFixed(1) ?? '-',
                  unit: '%',
                ),
                MetricCard(
                  label: l10n.lfHfRatio,
                  value: m.lfHfRatio?.toStringAsFixed(2) ?? '-',
                ),
                MetricCard(
                  label: l10n.sd1,
                  value: m.sd1?.toStringAsFixed(1) ?? '-',
                  unit: 'ms',
                ),
                MetricCard(
                  label: l10n.sd2,
                  value: m.sd2?.toStringAsFixed(1) ?? '-',
                  unit: 'ms',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (m.rrIntervals.isNotEmpty) ...[
              Text(
                l10n.poincarePlot,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: PoincarePlotWidget(
                      rrIntervals: m.rrIntervals,
                      sd1: m.sd1,
                      sd2: m.sd2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.frequencyDomain,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 160,
                    child: FrequencyBarChart(
                      lf: m.lf ?? 0,
                      hf: m.hf ?? 0,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
