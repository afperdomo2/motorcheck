import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../maintenance/categories.dart';
import '../models/maintenance_category.dart';
import '../providers.dart';
import '../repository.dart';

const _vehicleTypeLabels = {
  'car': 'Carro',
  'motorcycle': 'Moto',
  'bike': 'Bicicleta',
  'scooter': 'Patineta eléctrica',
  'truck': 'Camión',
  'other': 'Otro',
};

const _vehicleTypeOrder = [
  'car',
  'motorcycle',
  'bike',
  'scooter',
  'truck',
  'other',
];

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(maintenanceCategoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías de mantenimiento')),
      body: categoriesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: 'No se pudieron cargar las categorías',
          onRetry: () => ref
              .read(maintenanceCategoriesNotifierProvider.notifier)
              .loadCategories(),
        ),
        data: (categories) {
          final grouped = _groupByVehicleType(categories);

          return RefreshIndicator(
            onRefresh: ref
                .read(maintenanceCategoriesNotifierProvider.notifier)
                .loadCategories,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                for (final type in _vehicleTypeOrder) ...[
                  _SectionHeader(
                    title: _vehicleTypeLabels[type] ?? type,
                    onAdd: () =>
                        context.push('/settings/categories/add?type=$type'),
                  ),
                  if (grouped[type] == null || grouped[type]!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                        'Sin categorías',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else
                    ...grouped[type]!.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CategoryTile(
                          category: cat,
                          onEdit: () => context.push(
                            '/settings/categories/${cat.id}/edit',
                          ),
                          onDelete: () => _confirmDelete(context, ref, cat),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, List<MaintenanceCategory>> _groupByVehicleType(
    List<MaintenanceCategory> categories,
  ) {
    final map = <String, List<MaintenanceCategory>>{};
    for (final cat in categories) {
      map.putIfAbsent(cat.vehicleType, () => []).add(cat);
    }
    return map;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    MaintenanceCategory category,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar categoría',
      message: '¿Eliminar "${category.name}"?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(maintenanceCategoriesNotifierProvider.notifier)
          .remove(category.id!);
      if (context.mounted) AppSnackBar.success('Categoría eliminada');
    } on CategoryInUseException catch (e) {
      if (context.mounted) AppSnackBar.error(e.toString());
    } catch (error) {
      logError('eliminar categoría', error, StackTrace.current);
      if (context.mounted) {
        AppSnackBar.error(
          friendlyErrorMessage(
            error,
            fallback: 'No se pudo eliminar la categoría',
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const _SectionHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline, size: 24),
            tooltip: 'Agregar categoría',
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final MaintenanceCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = MaintenanceCategories.iconByName(category.iconName);
    final intervalKm = category.intervalKm;

    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon, size: 20)),
        title: Text(category.name),
        subtitle: intervalKm != null
            ? Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Cada $intervalKm km',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
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
        onTap: onEdit,
      ),
    );
  }
}
