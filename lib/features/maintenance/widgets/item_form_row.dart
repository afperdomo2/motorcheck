import 'package:flutter/material.dart';
import '../categories.dart';
import '../models/maintenance_item.dart';

class ItemFormRow extends StatelessWidget {
  final MaintenanceItem item;
  final int index;
  final VoidCallback onRemove;
  final bool canRemove;
  final ValueChanged<MaintenanceItem> onChanged;
  final String vehicleType;

  const ItemFormRow({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.canRemove,
    required this.onChanged,
    required this.vehicleType,
  });

  @override
  Widget build(BuildContext context) {
    final categories = MaintenanceCategories.forVehicleType(vehicleType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Item ${index + 1}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.close, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: categories.any((c) => c.key == item.category)
                  ? item.category
                  : 'general',
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category),
              ),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.key,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(c.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) =>
                  onChanged(item.copyWith(category: v ?? 'general')),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.partsCost > 0
                  ? item.partsCost.toStringAsFixed(0)
                  : '',
              decoration: const InputDecoration(
                labelText: 'Repuestos',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) =>
                  onChanged(item.copyWith(partsCost: double.tryParse(v) ?? 0)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: item.notes ?? '',
              decoration: const InputDecoration(
                labelText: 'Nota del item',
                prefixIcon: Icon(Icons.note_alt_outlined),
                hintText: 'Ej: Compré el filtro original',
              ),
              maxLines: 2,
              onChanged: (v) => onChanged(
                item.copyWith(notes: v.trim().isEmpty ? null : v.trim()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
