import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../components/models/vehicle_component.dart';
import '../../settings/models/maintenance_category.dart';
import '../categories.dart';
import '../models/maintenance_item.dart';

/// Fila editable de un ítem de mantenimiento.
///
/// Colapsada muestra un resumen (índice, categoría y costo); expandida muestra
/// los campos. El padre controla el estado con [expanded] y [onToggle] para
/// que solo haya una fila abierta a la vez.
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

  final bool expanded;

  /// Si es `null` la fila no se puede expandir ni colapsar.
  final VoidCallback? onToggle;

  /// Resalta la fila recién agregada.
  final bool isNew;

  const ItemFormRow({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.canRemove,
    required this.onChanged,
    required this.categories,
    this.components = const [],
    this.expanded = true,
    this.onToggle,
    this.isNew = false,
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

  MaintenanceCategory? get _selectedCategory {
    for (final category in widget.categories) {
      if (category.key == widget.item.category) return category;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isNew
              ? scheme.primary
              : widget.expanded
              ? scheme.outlineVariant
              : scheme.surfaceContainerLow,
          width: widget.isNew ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                ),
                child: _buildHeader(context),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Visibility(
                visible: widget.expanded,
                maintainState: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: _buildFields(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = AppSemanticColors.of(context);
    final category = _selectedCategory;
    final missingCategory = category == null && widget.categories.isNotEmpty;
    final label = category?.name ?? 'Sin categoría';
    final amount = widget.item.partsCost > 0
        ? ' · ${formatCurrency(widget.item.partsCost)}'
        : '';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: missingCategory
                ? semantic.warningContainer
                : scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            missingCategory
                ? Icons.error_outline
                : category == null
                ? Icons.build_outlined
                : MaintenanceCategories.iconByName(category.iconName),
            size: 20,
            color: missingCategory
                ? semantic.onWarningContainer
                : scheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ítem ${widget.index + 1}',
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$label$amount',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: missingCategory
                      ? semantic.warning
                      : scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (widget.canRemove)
          IconButton(
            onPressed: widget.onRemove,
            tooltip: 'Quitar ítem',
            icon: const Icon(Icons.close, size: 20),
          ),
        if (widget.onToggle != null)
          Icon(
            widget.expanded ? Icons.expand_less : Icons.expand_more,
            color: scheme.onSurfaceVariant,
          ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }

  Widget _buildFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue:
              widget.categories.any((c) => c.key == widget.item.category)
              ? widget.item.category
              : null,
          decoration: const InputDecoration(
            labelText: 'Categoría *',
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
          validator: (value) {
            if (widget.categories.isEmpty) return null;
            if (value == null || value.isEmpty) return 'Elige una categoría';
            return null;
          },
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
    );
  }
}
