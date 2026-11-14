import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/component_replacement.dart';
import '../models/vehicle_component.dart';
import '../providers.dart';
import '../widgets/component_card.dart';

class ComponentDetailScreen extends ConsumerWidget {
  const ComponentDetailScreen({
    super.key,
    required this.vehicleId,
    required this.componentId,
  });

  final int vehicleId;
  final int componentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusAsync = ref.watch(componentStatusProvider(componentId));
    final replacementsAsync = ref.watch(
      componentReplacementsProvider(componentId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Componente'),
        actions: [
          statusAsync.valueOrNull == null
              ? const SizedBox.shrink()
              : PopupMenuButton<_ComponentAction>(
                  tooltip: 'Opciones',
                  onSelected: (action) {
                    switch (action) {
                      case _ComponentAction.edit:
                        context.push(
                          '/vehicles/$vehicleId/components/$componentId/edit',
                        );
                      case _ComponentAction.delete:
                        if (statusAsync.valueOrNull!.component.isSystem) {
                          return;
                        }
                        _delete(context, ref);
                    }
                  },
                  itemBuilder: (context) {
                    final status = statusAsync.valueOrNull!;
                    return [
                      const PopupMenuItem(
                        value: _ComponentAction.edit,
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: AppSpacing.md),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      if (!status.component.isSystem)
                        PopupMenuItem(
                          value: _ComponentAction.delete,
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ];
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/maintenance/add?vehicleId=$vehicleId&componentId=$componentId',
        ),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Reemplazar componente'),
      ),
      body: statusAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudo cargar el componente',
          onRetry: () => ref.invalidate(componentStatusProvider(componentId)),
        ),
        data: (status) {
          if (status == null) {
            return const ErrorState(message: 'Componente no encontrado');
          }
          final component = status.component;
          final type = componentTypeFor(component.type);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxxl * 2,
            ),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              type.icon,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  component.name,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    type.label,
                                    if (component.position?.isNotEmpty == true)
                                      component.position!,
                                  ].join(' · '),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          StatusChip(
                            status: appStatusForComponent(status),
                            label: status.statusWord,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        status.primaryLabel,
                        style: theme.textTheme.titleMedium,
                      ),
                      if (status.remainingKmLabel != null ||
                          status.remainingDaysLabel != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.xs,
                          children: [
                            if (status.remainingKmLabel != null)
                              _Tag(
                                icon: Icons.speed_outlined,
                                text: status.remainingKmLabel!,
                              ),
                            if (status.remainingDaysLabel != null)
                              _Tag(
                                icon: Icons.event_outlined,
                                text: status.remainingDaysLabel!,
                              ),
                          ],
                        ),
                      ],
                      const Divider(height: AppSpacing.xl),
                      _InfoRow(
                        label: 'Frecuencia',
                        value: _frequencyText(component),
                      ),
                      _InfoRow(label: 'Aviso', value: _warningText(component)),
                      _InfoRow(
                        label: status.isReplaced
                            ? 'Último cambio'
                            : 'Instalación inicial',
                        value:
                            '${formatDisplayDate(status.baselineDate)}'
                            '${status.baselineKm != null ? ' · ${formatMileage(status.baselineKm)}' : ''}',
                      ),
                      if (status.nextKmLabel != null)
                        _InfoRow(
                          label: 'Próximo por km',
                          value: status.nextKmLabel!,
                        ),
                      if (status.nextDateLabel != null)
                        _InfoRow(
                          label: 'Próximo por fecha',
                          value: status.nextDateLabel!,
                        ),
                      if (!component.active)
                        const _InfoRow(
                          label: 'Estado',
                          value: 'Inactivo: no genera recordatorios',
                        ),
                      if (component.isSystem)
                        const _InfoRow(
                          label: 'Plantilla',
                          value:
                              'Componente del vehículo. Se puede editar y '
                              'desactivar, pero no eliminar.',
                        ),
                      if (component.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          component.notes!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Historial de reemplazos',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              replacementsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text('No se pudo cargar el historial'),
                  ),
                ),
                data: (replacements) {
                  if (replacements.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Sin reemplazos registrados. Usa “Reemplazar '
                          'componente” para registrar un cambio dentro de un '
                          'mantenimiento.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final replacement in replacements)
                        _ReplacementTile(
                          replacement: replacement,
                          onOpenMaintenance: () => context.push(
                            '/maintenance/${replacement.maintenanceId}',
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _frequencyText(VehicleComponent component) {
    final parts = <String>[];
    if (component.intervalKm != null) {
      parts.add('Cada ${formatMileage(component.intervalKm)}');
    }
    if (component.intervalMonths != null) {
      parts.add('Cada ${component.intervalMonths} meses');
    }
    return parts.isEmpty ? 'Sin frecuencia configurada' : parts.join(' · ');
  }

  String _warningText(VehicleComponent component) {
    final parts = <String>[];
    if (component.warningKm != null) {
      parts.add('${formatMileage(component.warningKm)} antes');
    }
    if (component.warningDays != null) {
      parts.add('${component.warningDays} días antes');
    }
    return parts.isEmpty ? 'Sin aviso previo' : parts.join(' · ');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar componente',
      message:
          '¿Eliminar este componente? Su historial de reemplazos se conserva '
          'en los mantenimientos. Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(componentsNotifierProvider.notifier)
          .remove(componentId, vehicleId: vehicleId);
      if (!context.mounted) return;
      AppSnackBar.success('Componente eliminado');
      context.pop();
    } catch (error) {
      logError('eliminar componente', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo eliminar el componente',
        ),
      );
    }
  }
}

enum _ComponentAction { edit, delete }

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _ReplacementTile extends StatelessWidget {
  const _ReplacementTile({
    required this.replacement,
    required this.onOpenMaintenance,
  });

  final ComponentReplacement replacement;
  final VoidCallback onOpenMaintenance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = <String>[
      if (replacement.mileage != null) formatMileage(replacement.mileage),
      if (replacement.partsCost > 0) formatCurrency(replacement.partsCost),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onOpenMaintenance,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatDisplayDate(replacement.date),
                      style: theme.textTheme.titleSmall,
                    ),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        details.join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (replacement.notes?.isNotEmpty == true) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        replacement.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ver mantenimiento',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
