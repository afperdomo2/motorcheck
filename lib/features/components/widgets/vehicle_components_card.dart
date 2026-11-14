import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/vehicle_component.dart';
import '../providers.dart';
import 'component_card.dart';

class VehicleComponentsCard extends ConsumerWidget {
  const VehicleComponentsCard({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusesAsync = ref.watch(
      vehicleComponentStatusesProvider(vehicleId),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tire_repair,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Componentes',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.push('/vehicles/$vehicleId/components'),
                  child: const Text('Abrir'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            statusesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: LinearProgressIndicator(),
              ),
              error: (error, _) => Text(
                'No se pudieron cargar los componentes',
                style: theme.textTheme.bodySmall,
              ),
              data: (statuses) {
                if (statuses.isEmpty) {
                  return Text(
                    'Sin componentes registrados. Agrega llantas, batería, '
                    'cadena, frenos o suspensión.',
                    style: theme.textTheme.bodySmall,
                  );
                }
                final active = statuses
                    .where((status) => status.component.active)
                    .toList();
                if (active.isEmpty) {
                  return Text(
                    'Todos los componentes están inactivos.',
                    style: theme.textTheme.bodySmall,
                  );
                }
                final visible = active.take(3).toList();
                return Column(
                  children: [
                    for (final status in visible)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          onTap: status.component.id == null
                              ? null
                              : () => context.push(
                                  '/vehicles/$vehicleId/components/'
                                  '${status.component.id}',
                                ),
                          child: Row(
                            children: [
                              Icon(
                                componentTypeFor(status.component.type).icon,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      status.component.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      status.primaryLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              StatusChip(
                                status: appStatusForComponent(status),
                                label: status.statusWord,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (active.length > visible.length)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'y ${active.length - visible.length} más',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
