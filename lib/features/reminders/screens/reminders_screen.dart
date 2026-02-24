import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/reminders_provider.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  static const _dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  Future<void> _showAddDialog() async {
    TimeOfDay selectedTime = TimeOfDay.now();
    List<int> selectedDays = [1, 2, 3, 4, 5]; // Mon-Fri default

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).addReminder),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(selectedTime.format(context)),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (t != null) setDlgState(() => selectedTime = t);
                    },
                  ),
                  Wrap(
                    spacing: 4,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final selected = selectedDays.contains(day);
                      return FilterChip(
                        label: Text(_dayNames[i]),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        onSelected: (v) {
                          setDlgState(() {
                            if (v) {
                              selectedDays.add(day);
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final time =
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    ref
                        .read(remindersProvider.notifier)
                        .add(time, selectedDays);
                    Navigator.pop(ctx);
                  },
                  child: Text(AppLocalizations.of(context).save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remindersState = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reminders)),
      body: remindersState.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm_off,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text('Nenhum lembrete configurado'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addReminder),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final r = reminders[index];
              final daysStr = r.days
                  .map((d) => _dayNames[d - 1])
                  .join(', ');

              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.alarm,
                    color: r.active ? AppColors.primary : AppColors.textMuted,
                    size: 32,
                  ),
                  title: Text(
                    r.time,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: r.active ? null : AppColors.textMuted,
                    ),
                  ),
                  subtitle: Text(daysStr),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: r.active,
                        activeColor: AppColors.primary,
                        onChanged: (_) =>
                            ref.read(remindersProvider.notifier).toggle(r.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error),
                        onPressed: () =>
                            ref.read(remindersProvider.notifier).delete(r.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
