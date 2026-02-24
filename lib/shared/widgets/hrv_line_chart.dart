import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';
import '../models/measurement_model.dart';

class HrvLineChart extends StatelessWidget {
  final List<MeasurementModel> measurements;
  final String metric; // e.g. 'rmssd', 'sdnn'

  const HrvLineChart({
    super.key,
    required this.measurements,
    this.metric = 'rmssd',
  });

  double? _getValue(MeasurementModel m) {
    switch (metric) {
      case 'rmssd':
        return m.rmssd;
      case 'sdnn':
        return m.sdnn;
      case 'pnn50':
        return m.pnn50;
      case 'lf':
        return m.lf;
      case 'hf':
        return m.hf;
      default:
        return m.rmssd;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final spots = measurements.asMap().entries.map((e) {
      final val = _getValue(e.value) ?? 0;
      return FlSpot(e.key.toDouble(), val);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 51 / 255),
            ),
          ),
        ],
      ),
    );
  }
}
