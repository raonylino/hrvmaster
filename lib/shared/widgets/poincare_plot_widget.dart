import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PoincareplotWidget extends StatelessWidget {
  final List<double> rrIntervals;
  final double? sd1;
  final double? sd2;

  const PoincareplotWidget({
    super.key,
    required this.rrIntervals,
    this.sd1,
    this.sd2,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: _PoincarePainter(
          rrIntervals: rrIntervals,
          sd1: sd1 ?? 0,
          sd2: sd2 ?? 0,
        ),
      ),
    );
  }
}

class _PoincarePainter extends CustomPainter {
  final List<double> rrIntervals;
  final double sd1;
  final double sd2;

  _PoincarePainter({
    required this.rrIntervals,
    required this.sd1,
    required this.sd2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rrIntervals.length < 2) return;

    final dotPaint = Paint()
      ..color = AppColors.primary.withAlpha(180)
      ..style = PaintingStyle.fill;

    final bgPaint = Paint()
      ..color = AppColors.secondary.withAlpha(60)
      ..style = PaintingStyle.fill;

    final minRR = rrIntervals.reduce(min);
    final maxRR = rrIntervals.reduce(max);
    final range = maxRR - minRR;
    if (range == 0) return;

    // Draw ellipse background representing SD1/SD2
    if (sd1 > 0 && sd2 > 0) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.rotate(-pi / 4);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: sd2 / range * size.width,
          height: sd1 / range * size.height,
        ),
        bgPaint,
      );
      canvas.restore();
    }

    // Draw points
    for (int i = 0; i < rrIntervals.length - 1; i++) {
      final x =
          (rrIntervals[i] - minRR) / range * size.width;
      final y =
          (rrIntervals[i + 1] - minRR) / range * size.height;
      canvas.drawCircle(Offset(x, size.height - y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_PoincarePainter oldDelegate) {
    return oldDelegate.rrIntervals != rrIntervals;
  }
}
