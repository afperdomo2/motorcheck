import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../categories.dart';
import '../models/maintenance_item.dart';
import '../../components/models/vehicle_component.dart';
import '../../settings/models/maintenance_category.dart';

class ItemFormRow extends StatefulWidget {
  final MaintenanceItem item;
  final int index;
  final VoidCallback onRemove;
  final bool canRemove;
  final ValueChanged<MaintenanceItem> onChanged;
  final List<MaintenanceCategory> categories;

  /// Componentes que se pueden reemplazar con este ítem. El padre filtra los
  /// que ya están usados en otras filas.
  final List<VehicleComponent> components;

  const ItemFormRow({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.canRemove,
    required this.onChanged,
    required this.categories,
    this.components = const [],
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ítem ${widget.index + 1}',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (widget.canRemove)
                IconButton(
                  onPressed: widget.onRemove,
                  tooltip: 'Quitar ítem',
                  icon: const Icon(Icons.close, size: 20),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            isExpanded: true,
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
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              final category = value ?? 'general';
              VehicleComponent? selected;
              for (final component in widget.components) {
                if (component.id == widget.item.componentId) {
                  selected = component;
                }
              }
              final keepsComponent =
                  selected != null && selected.categoryKey == category;
              widget.onChanged(
                widget.item.copyWith(
                  category: category,
                  componentId: keepsComponent ? widget.item.componentId : null,
                ),
              );
            },
          ),
          if (widget.components.isNotEmpty ||
              widget.item.componentId != null) ...[
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue:
                  widget.components.any(
                    (component) => component.id == widget.item.componentId,
                  )
                  ? widget.item.componentId
                  : 0,
              decoration: const InputDecoration(
                labelText: 'Componente reemplazado (opcional)',
                prefixIcon: Icon(Icons.tire_repair),
                helperText:
                    'Reinicia el ciclo de la pieza con la fecha y el '
                    'kilometraje de este mantenimiento.',
              ),
              items: [
                const DropdownMenuItem(
                  value: 0,
                  child: Text('Sin reemplazo de componente'),
                ),
                for (final component in widget.components)
                  if (component.id != null)
                    DropdownMenuItem(
                      value: component.id,
                      child: Text(
                        component.position?.isNotEmpty == true
                            ? '${component.name} · ${component.position}'
                            : component.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
              ],
              onChanged: (value) => widget.onChanged(
                widget.item.copyWith(
                  componentId: value == null || value == 0 ? null : value,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _costController,
            decoration: InputDecoration(
              labelText: 'Repuestos',
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: 'COP',
              helperText: widget.item.partsCost > 0
                  ? formatCurrency(widget.item.partsCost)
                  : null,
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
              labelText: 'Nota del ítem',
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
    );
  }
}
