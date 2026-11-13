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
import '../../../shared/widgets/section_header.dart';
import '../../vehicles/providers.dart';
import '../providers.dart';

class ChecklistsScreen extends ConsumerWidget {
  const ChecklistsScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(selectedVehicleProvider(vehicleId));
    final checklistsAsync = ref.watch(checklistsForVehicleProvider(vehicleId));
    final runsAsync = ref.watch(inspectionRunsProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Inspecciones')),
      body: vehicleAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudo cargar el vehículo',
          onRetry: () => ref.invalidate(selectedVehicleProvider(vehicleId)),
        ),
        data: (vehicle) {
          if (vehicle == null) {
            return const ErrorState(message: 'Vehículo no encontrado');
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(checklistsForVehicleProvider(vehicleId));
              ref.invalidate(inspectionRunsProvider(vehicleId));
              await ref.read(checklistsForVehicleProvider(vehicleId).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  vehicle.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                checklistsAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (error, _) => const ErrorState(
                    message: 'No se pudieron cargar los checklists',
                  ),
                  data: (checklists) {
                    if (checklists.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Text('No hay checklists disponibles'),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final checklist in checklists)
                          Card(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.checklist_outlined),
                              title: Text(checklist.name),
                              subtitle: const Text(
                                'Inspección rápida antes de salir',
                              ),
                              trailing: FilledButton.tonal(
                                onPressed: () => context.push(
                                  '/vehicles/$vehicleId/checklists/'
                                  '${checklist.id}/start',
                                ),
                                child: const Text('Iniciar'),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Historial', icon: Icons.history),
                runsAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (error, _) => const ErrorState(
                    message: 'No se pudo cargar el historial',
                  ),
                  data: (runs) {
                    if (runs.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'Sin inspecciones registradas',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final run in runs)
                          Card(
                            margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.fact_check_outlined),
                              title: Text(formatDisplayDate(run.date)),
                              subtitle: Text(
                                [
                                  if (run.odometer != null)
                                    formatMileage(run.odometer),
                                  if (run.notes != null &&
                                      run.notes!.isNotEmpty)
                                    run.notes!,
                                ].join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: PopupMenuButton<_RunAction>(
                                tooltip: 'Opciones',
                                onSelected: (action) {
                                  switch (action) {
                                    case _RunAction.view:
                                      context.push(
                                        '/vehicles/$vehicleId/checklists/'
                                        'runs/${run.id}',
                                      );
                                    case _RunAction.delete:
                                      _delete(context, ref, run.id!);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: _RunAction.view,
                                    child: Text('Ver detalle'),
                                  ),
                                  const PopupMenuItem(
                                    value: _RunAction.delete,
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              ),
                              onTap: () => context.push(
                                '/vehicles/$vehicleId/checklists/runs/${run.id}',
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int runId) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar inspección',
      message: '¿Eliminar esta inspección del historial?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(inspectionsNotifierProvider.notifier)
          .remove(runId, vehicleId);
      if (!context.mounted) return;
      AppSnackBar.success('Inspección eliminada');
    } catch (error) {
      logError('eliminar inspección', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error('No se pudo eliminar la inspección');
    }
  }
}

enum _RunAction { view, delete }
