import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../models/maintenance_category.dart';
import '../providers.dart';
import '../repository.dart';

const _vehicleTypeLabels = {
  'car': 'Carro',
  'motorcycle': 'Moto',
  'bike': 'Bicicleta',
  'truck': 'Camión',
  'other': 'Otro',
};

const _vehicleTypeOrder = ['car', 'motorcycle', 'bike', 'truck', 'other'];

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
          message: err.toString(),
          onRetry: () => ref
              .read(maintenanceCategoriesNotifierProvider.notifier)
              .loadCategories(),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.category,
              title: 'Sin categorías',
              subtitle: 'No hay categorías registradas',
            );
          }

          final grouped = _groupByVehicleType(categories);

          return RefreshIndicator(
            onRefresh: ref
                .read(maintenanceCategoriesNotifierProvider.notifier)
                .loadCategories,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final type in _vehicleTypeOrder)
                  if (grouped.containsKey(type)) ...[
                    _SectionHeader(
                      title: _vehicleTypeLabels[type] ?? type,
                      onAdd: () =>
                          context.push('/settings/categories/add?type=$type'),
                    ),
                    ...grouped[type]!.map(
                      (cat) => _CategoryTile(
                        category: cat,
                        onEdit: () =>
                            context.push('/settings/categories/${cat.id}/edit'),
                        onDelete: () => _confirmDelete(context, ref, cat),
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
    } on CategoryInUseException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
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
      padding: const EdgeInsets.only(top: 16, bottom: 4),
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
            icon: const Icon(Icons.add_circle_outline, size: 22),
            tooltip: 'Agregar categoría',
            visualDensity: VisualDensity.compact,
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
    final icon = _iconMap[category.iconName] ?? Icons.build;
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
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: 4),
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
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
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

const _iconMap = {
  'build': Icons.build,
  'construction': Icons.construction,
  'oil_barrel': Icons.oil_barrel,
  'disc_full': Icons.disc_full,
  'settings': Icons.settings,
  'tire_repair': Icons.tire_repair,
  'circle': Icons.circle,
  'filter_alt': Icons.filter_alt,
  'battery_charging_full': Icons.battery_charging_full,
  'ac_unit': Icons.ac_unit,
  'electrical_services': Icons.electrical_services,
  'link': Icons.link,
  'water_drop': Icons.water_drop,
  'local_gas_station': Icons.local_gas_station,
  'directions_car': Icons.directions_car,
  'cleaning_services': Icons.cleaning_services,
  'cable': Icons.cable,
  'wrench': Icons.handyman,
  'brightness_high': Icons.brightness_high,
  'sensors': Icons.sensors,
  'air': Icons.air,
  'radio': Icons.radio,
  'camera': Icons.camera,
  'visibility': Icons.visibility,
  'speed': Icons.speed,
  'bolt': Icons.bolt,
  'palette': Icons.palette,
  'security': Icons.security,
  'star': Icons.star,
};
