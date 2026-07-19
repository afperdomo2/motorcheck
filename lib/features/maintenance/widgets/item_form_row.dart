import 'package:flutter/material.dart';
import '../models/maintenance_item.dart';

class ItemFormRow extends StatelessWidget {
  final MaintenanceItem item;
  final int index;
  final VoidCallback onRemove;
  final bool canRemove;
  final ValueChanged<MaintenanceItem> onChanged;

  const ItemFormRow({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.canRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
            TextFormField(
              initialValue: item.name,
              decoration: const InputDecoration(labelText: 'Nombre *'),
              onChanged: (v) => onChanged(item.copyWith(name: v)),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: item.category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: const [
                DropdownMenuItem(value: 'oil', child: Text('Aceite')),
                DropdownMenuItem(value: 'tires', child: Text('Llantas')),
                DropdownMenuItem(value: 'filters', child: Text('Filtros')),
                DropdownMenuItem(value: 'brakes', child: Text('Frenos')),
                DropdownMenuItem(
                  value: 'suspension',
                  child: Text('Suspensión'),
                ),
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'other', child: Text('Otro')),
              ],
              onChanged: (v) =>
                  onChanged(item.copyWith(category: v ?? 'other')),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.laborCost > 0
                        ? item.laborCost.toStringAsFixed(0)
                        : '',
                    decoration: const InputDecoration(
                      labelText: 'Mano de obra',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => onChanged(
                      item.copyWith(laborCost: double.tryParse(v) ?? 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: item.partsCost > 0
                        ? item.partsCost.toStringAsFixed(0)
                        : '',
                    decoration: const InputDecoration(labelText: 'Repuestos'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => onChanged(
                      item.copyWith(partsCost: double.tryParse(v) ?? 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
