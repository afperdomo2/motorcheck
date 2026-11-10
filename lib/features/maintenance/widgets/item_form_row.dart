import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_spacing.dart';
import '../categories.dart';
import '../models/maintenance_item.dart';
import '../../settings/models/maintenance_category.dart';

class ItemFormRow extends StatefulWidget {
  final MaintenanceItem item;
  final int index;
  final VoidCallback onRemove;
  final bool canRemove;
  final ValueChanged<MaintenanceItem> onChanged;
  final List<MaintenanceCategory> categories;

  const ItemFormRow({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.canRemove,
    required this.onChanged,
    required this.categories,
  });

  @override
  State<ItemFormRow> createState() => _ItemFormRowState();
}

class _ItemFormRowState extends State<ItemFormRow> {
  late final TextEditingController _costController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _costController = TextEditingController(
      text: widget.item.partsCost > 0
          ? widget.item.partsCost.toStringAsFixed(0)
          : '',
    );
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Item ${widget.index + 1}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (widget.canRemove)
                  IconButton(
                    onPressed: widget.onRemove,
                    tooltip: 'Quitar item',
                    icon: const Icon(Icons.close, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue:
                  widget.categories.any((c) => c.key == widget.item.category)
                  ? widget.item.category
                  : null,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: widget.categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.key,
                      child: Row(
                        children: [
                          Icon(
                            MaintenanceCategories.iconByName(c.iconName),
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              c.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => widget.onChanged(
                widget.item.copyWith(category: value ?? 'general'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Repuestos',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'COP',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => widget.onChanged(
                widget.item.copyWith(partsCost: double.tryParse(value) ?? 0),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Nota del item',
                prefixIcon: Icon(Icons.note_alt_outlined),
                hintText: 'Ej: Compré el filtro original',
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) => widget.onChanged(
                widget.item.copyWith(
                  notes: value.trim().isEmpty ? null : value.trim(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
