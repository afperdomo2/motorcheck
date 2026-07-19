import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: workshops.length,
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
                                color: Theme.of(context).disabledColor,
                              ),
                              const SizedBox(width: 4),
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
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
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
