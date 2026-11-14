import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../models/reminder.dart';
import '../providers.dart';
import '../widgets/reminder_tile.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  ReminderKind? _filter;

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: Column(
        children: [
          _FilterBar(
            selected: _filter,
            onSelected: (value) => setState(() => _filter = value),
          ),
          Expanded(
            child: remindersAsync.when(
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorState(
                message: 'No se pudieron calcular los recordatorios',
                onRetry: () => ref.invalidate(remindersProvider),
              ),
              data: (reminders) {
                final filtered = _filter == null
                    ? reminders
                    : reminders
                          .where((reminder) => reminder.kind == _filter)
                          .toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.check_circle_outline,
                    title: 'Todo al día',
                    subtitle:
                        'No tienes vencimientos pendientes en este momento',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  children: [
                    for (final reminder in filtered)
                      ReminderTile(
                        reminder: reminder,
                        onTap: () => context.push(reminder.route),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelected});

  final ReminderKind? selected;
  final ValueChanged<ReminderKind?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          _chip(context, null, 'Todos'),
          _chip(context, ReminderKind.maintenance, 'Mantenimiento'),
          _chip(context, ReminderKind.document, 'Documentos'),
          _chip(context, ReminderKind.component, 'Componentes'),
          _chip(context, ReminderKind.restriction, 'Pico y placa'),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, ReminderKind? kind, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected == kind,
        onSelected: (_) => onSelected(kind),
      ),
    );
  }
}
