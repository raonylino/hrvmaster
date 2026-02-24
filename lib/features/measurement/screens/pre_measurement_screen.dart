import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class PreMeasurementScreen extends ConsumerStatefulWidget {
  const PreMeasurementScreen({super.key});

  @override
  ConsumerState<PreMeasurementScreen> createState() =>
      _PreMeasurementScreenState();
}

class _PreMeasurementScreenState
    extends ConsumerState<PreMeasurementScreen> {
  String _selectedMethod = 'camera';
  String _selectedPosition = 'sitting';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.measurement)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.selectMethod,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _MethodCard(
              icon: Icons.camera_alt,
              label: l10n.camera,
              subtitle: l10n.cameraSubtitle,
              selected: _selectedMethod == 'camera',
              onTap: () => setState(() => _selectedMethod = 'camera'),
            ),
            const SizedBox(height: 8),
            _MethodCard(
              icon: Icons.bluetooth,
              label: l10n.bluetooth,
              subtitle: l10n.bluetoothSubtitle,
              selected: _selectedMethod == 'bluetooth',
              onTap: () => setState(() => _selectedMethod = 'bluetooth'),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.position,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _positionChip(l10n.sitting, 'sitting'),
                _positionChip(l10n.lying, 'lying'),
                _positionChip(l10n.standing, 'standing'),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.measurement,
                  arguments: {
                    'method': _selectedMethod,
                    'position': _selectedPosition,
                  },
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.startMeasurement),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _positionChip(String label, String value) {
    final selected = _selectedPosition == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      onSelected: (_) => setState(() => _selectedPosition = value),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? AppColors.primary.withValues(alpha: 26 / 255)
              : Theme.of(context).cardColor,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected ? AppColors.primary : null,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
