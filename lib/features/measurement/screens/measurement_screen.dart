import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/measurement_provider.dart';

class MeasurementScreen extends ConsumerStatefulWidget {
  final String method;

  const MeasurementScreen({super.key, required this.method});

  @override
  ConsumerState<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends ConsumerState<MeasurementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(measurementProvider.notifier).startMeasurement(widget.method);
    });
  }

  @override
  void dispose() {
    // Don't reset here - we want results to persist to results screen
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final measureState = ref.watch(measurementProvider);

    // Navigate when done
    ref.listen(measurementProvider, (prev, next) {
      if (next.status == MeasurementStatus.done && next.result != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.results,
          arguments: next.result,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurement),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(measurementProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated heart
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1.1),
                duration: const Duration(milliseconds: 600),
                builder: (_, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 100,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _formatTime(measureState.elapsedSeconds),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'RR intervals: ${measureState.rrIntervals.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.method == 'camera'
                    ? 'Coloque o dedo na câmera traseira'
                    : 'Medindo via Bluetooth...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              if (measureState.status == MeasurementStatus.processing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Calculando métricas HRV...'),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: measureState.rrIntervals.length >= 10
                      ? () => ref
                          .read(measurementProvider.notifier)
                          .stopAndProcess(method: widget.method)
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Finalizar Medição'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                  ),
                ),
              if (measureState.rrIntervals.length < 10)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Aguarde pelo menos 10 intervalos RR (${measureState.rrIntervals.length}/10)',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
