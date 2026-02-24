import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';

class FrequencyBarChart extends StatelessWidget {
  final double lf;
  final double hf;

  const FrequencyBarChart({
    super.key,
    required this.lf,
    required this.hf,
  });

  @override
  Widget build(BuildContext context) {
    final max = (lf > hf ? lf : hf) * 1.2;
    if (max == 0) {
      return const Center(child: Text('No data'));
    }

    return BarChart(
      BarChartData(
        maxY: max,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: lf,
                color: AppColors.primary,
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: hf,
                color: AppColors.secondary,
                width: 40,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                return Text(
                  value == 0 ? 'LF' : 'HF',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
      ),
    );
  }
}
