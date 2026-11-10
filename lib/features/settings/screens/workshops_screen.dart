import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../providers.dart';

class WorkshopsScreen extends ConsumerWidget {
  const WorkshopsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Talleres')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/settings/workshops/add'),
        tooltip: 'Agregar taller',
        child: const Icon(Icons.add),
      ),
      body: workshopsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () =>
              ref.read(workshopsNotifierProvider.notifier).loadWorkshops(),
        ),
        data: (workshops) {
          if (workshops.isEmpty) {
            return EmptyState(
              icon: Icons.handyman,
              title: 'Sin talleres',
              subtitle: 'Agrega tus talleres de confianza',
              onAction: () => context.push('/settings/workshops/add'),
              actionLabel: 'Agregar taller',
            );
          }

          return RefreshIndicator(
            onRefresh: ref
                .read(workshopsNotifierProvider.notifier)
                .loadWorkshops,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxxl * 2,
              ),
              itemCount: workshops.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final w = workshops[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.handyman, size: 20),
                    ),
                    title: Text(w.name),
                    subtitle: w.location != null && w.location!.isNotEmpty
                        ? Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(w.location!),
                            ],
                          )
                        : null,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.push('/settings/workshops/${w.id}/edit');
                        }
                        if (value == 'delete') {
                          _confirmDelete(context, ref, w);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: AppSpacing.sm),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: AppSpacing.sm),
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
                    onTap: () =>
                        context.push('/settings/workshops/${w.id}/edit'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    dynamic workshop,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar taller',
      message: '¿Eliminar "${workshop.name}"?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      ref.read(workshopsNotifierProvider.notifier).remove(workshop.id);
    }
  }
}
