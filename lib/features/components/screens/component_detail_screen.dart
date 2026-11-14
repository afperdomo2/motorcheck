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
import '../models/component_service.dart';
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
    final statusAsync = ref.watch(componentStatusProvider(componentId));
    final servicesAsync = ref.watch(componentServicesProvider(componentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Componente'),
        actions: [
          PopupMenuButton<_ComponentAction>(
            tooltip: 'Opciones',
            onSelected: (action) {
              switch (action) {
                case _ComponentAction.edit:
                  context.push(
                    '/vehicles/$vehicleId/components/$componentId/edit',
                  );
                case _ComponentAction.delete:
                  _delete(context, ref);
              }
            },
            itemBuilder: (context) => [
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
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/vehicles/$vehicleId/components/$componentId/services/add',
        ),
        icon: const Icon(Icons.build_outlined),
        label: const Text('Registrar servicio'),
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
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              type.icon,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  component.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    type.label,
                                    if (component.position?.isNotEmpty == true)
                                      component.position!,
                                  ].join(' · '),
                                  style: Theme.of(context).textTheme.bodySmall,
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
                        style: Theme.of(context).textTheme.titleMedium,
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
                        label: 'Instalado',
                        value:
                            '${formatDisplayDate(component.installedAt)}'
                            '${component.installedKm != null ? ' · ${formatMileage(component.installedKm)}' : ''}',
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
                      if (component.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          component.notes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Historial de servicios',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              servicesAsync.when(
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
                data: (services) {
                  if (services.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Sin servicios registrados. Usa “Registrar '
                          'servicio” para guardar un cambio, rotación o '
                          'revisión.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final service in services)
                        _ServiceTile(
                          service: service,
                          onDelete: () => _deleteService(context, ref, service),
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

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar componente',
      message:
          '¿Eliminar este componente y todo su historial de servicios? '
          'Esta acción no se puede deshacer.',
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

  Future<void> _deleteService(
    BuildContext context,
    WidgetRef ref,
    ComponentService service,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar servicio',
      message: '¿Eliminar este registro del historial?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(componentsNotifierProvider.notifier)
          .removeService(
            service.id!,
            componentId: componentId,
            vehicleId: vehicleId,
          );
      if (!context.mounted) return;
      AppSnackBar.success('Servicio eliminado');
    } catch (error) {
      logError('eliminar servicio', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo eliminar el servicio',
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
            width: 130,
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

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onDelete});

  final ComponentService service;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = <String>[
      if (service.odometer != null) formatMileage(service.odometer),
      if (service.cost > 0) formatCurrency(service.cost),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatDisplayDate(service.date),
                        style: theme.textTheme.titleSmall,
                      ),
                      if (service.resetInterval)
                        const StatusChip(
                          status: AppStatus.info,
                          label: 'Reinició intervalo',
                          icon: Icons.restart_alt,
                        ),
                    ],
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(details.join(' · '), style: theme.textTheme.bodySmall),
                  ],
                  if (service.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      service.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Eliminar servicio',
              icon: const Icon(Icons.close),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
