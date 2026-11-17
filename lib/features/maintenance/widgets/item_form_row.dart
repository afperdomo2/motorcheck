import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../components/models/component_status.dart';
import '../../components/models/vehicle_component.dart';
import '../../settings/models/maintenance_category.dart';
import '../categories.dart';
import '../models/maintenance_item.dart';

/// Fila editable de un ítem de mantenimiento.
///
/// Colapsada muestra un resumen (índice, pieza o categoría y costo); expandida
/// muestra los campos. El padre controla el estado con [expanded] y
/// [onToggle] para que solo haya una fila abierta a la vez.
class ItemFormRow extends StatefulWidget {
  final MaintenanceItem item;
  final int index;
  final VoidCallback onRemove;
  final bool canRemove;
  final ValueChanged<MaintenanceItem> onChanged;
  final List<MaintenanceCategory> categories;

  /// Componentes que se pueden reemplazar con este ítem. El padre filtra los
  /// que ya están usados en otras filas y los inactivos.
  final List<ComponentStatus> components;

  /// Categoría a usar cuando la pieza no tiene una propia (por ejemplo, un
  /// componente personalizado de tipo "otro").
  final String fallbackCategoryKey;

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
    this.fallbackCategoryKey = 'general',
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

  ComponentStatus? get _selectedComponent {
    for (final status in widget.components) {
      if (status.component.id == widget.item.componentId) return status;
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
    final component = _selectedComponent?.component;
    final missing =
        component == null && category == null && widget.categories.isNotEmpty;
    final label = component != null
        ? component.name
        : category?.name ?? 'Sin categoría';
    final subtitle = component != null
        ? [
            category?.name ?? 'Pieza',
            if (component.position?.isNotEmpty == true) component.position!,
          ].join(' · ')
        : null;
    final amount = widget.item.partsCost > 0
        ? ' · ${formatCurrency(widget.item.partsCost)}'
        : '';

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: missing
                ? semantic.warningContainer
                : scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            missing
                ? Icons.error_outline
                : component != null
                ? componentTypeFor(component.type).icon
                : category == null
                ? Icons.build_outlined
                : MaintenanceCategories.iconByName(category.iconName),
            size: 20,
            color: missing
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
                subtitle == null ? '$label$amount' : '$label · $subtitle',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: missing ? semantic.warning : scheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final component = _selectedComponent?.component;
    final category = _selectedCategory;
    final missing =
        component == null && category == null && widget.categories.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: '¿Qué se hizo? *',
              prefixIcon: Icon(
                component != null
                    ? componentTypeFor(component.type).icon
                    : Icons.build_outlined,
              ),
              suffixIcon: const Icon(Icons.expand_more),
              errorText: missing ? 'Elige qué se hizo' : null,
            ),
            child: Text(
              component != null
                  ? component.name
                  : category?.name ?? 'Elige una pieza o un servicio',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
        if (component != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Reemplaza la pieza y reinicia su ciclo con la fecha y el '
            'kilometraje de este mantenimiento.',
            style: theme.textTheme.bodySmall?.copyWith(color: semantic.success),
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

  Future<void> _openPicker(BuildContext context) async {
    final selection = await showModalBottomSheet<_ItemSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _ItemPickerSheet(
        categories: widget.categories,
        components: widget.components,
        selectedCategory: widget.item.category,
        selectedComponentId: widget.item.componentId,
      ),
    );
    if (selection == null) return;

    if (selection.componentId != null) {
      ComponentStatus? status;
      for (final candidate in widget.components) {
        if (candidate.component.id == selection.componentId) {
          status = candidate;
        }
      }
      if (status == null) return;
      widget.onChanged(
        widget.item.copyWith(
          componentId: selection.componentId,
          category: status.component.categoryKey ?? widget.fallbackCategoryKey,
        ),
      );
      return;
    }

    widget.onChanged(
      widget.item.copyWith(
        componentId: null,
        category: selection.category ?? '',
      ),
    );
  }
}

class _ItemSelection {
  const _ItemSelection({this.category, this.componentId});

  final String? category;
  final int? componentId;
}

/// Hoja de selección: Servicios (categorías) o Piezas (componentes).
///
/// Servicios es la pestaña por defecto porque es el caso más frecuente. Las
/// categorías se muestran como chips para que quepan sin scroll. Si el ítem ya
/// tiene una pieza, la hoja abre en Piezas.
/// Toggle de dos opciones que se adapta a texto grande sin desbordar.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final _PickerMode mode;
  final ValueChanged<_PickerMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Servicios',
              selected: mode == _PickerMode.services,
              onTap: () => onChanged(_PickerMode.services),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Piezas',
              selected: mode == _PickerMode.pieces,
              onTap: () => onChanged(_PickerMode.pieces),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemPickerSheet extends StatefulWidget {
  const _ItemPickerSheet({
    required this.categories,
    required this.components,
    required this.selectedCategory,
    required this.selectedComponentId,
  });

  final List<MaintenanceCategory> categories;
  final List<ComponentStatus> components;
  final String selectedCategory;
  final int? selectedComponentId;

  @override
  State<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

enum _PickerMode { services, pieces }

class _ItemPickerSheetState extends State<_ItemPickerSheet> {
  late _PickerMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.selectedComponentId != null && widget.components.isNotEmpty
        ? _PickerMode.pieces
        : _PickerMode.services;
  }

  List<MaintenanceCategory> get _orderedCategories {
    bool isGeneral(MaintenanceCategory category) {
      return category.key == 'general' || category.key.endsWith('_general');
    }

    final general = widget.categories.where(isGeneral).toList();
    final rest = widget.categories.where((c) => !isGeneral(c)).toList();
    return [...general, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;
    final hasPieces = widget.components.isNotEmpty;
    final hasServices = widget.categories.isNotEmpty;
    final showSwitch = hasPieces && hasServices;
    final effectiveMode = !hasPieces && hasServices
        ? _PickerMode.services
        : hasPieces && !hasServices
        ? _PickerMode.pieces
        : _mode;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '¿Qué se hizo?',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          if (showSwitch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _ModeToggle(
                mode: effectiveMode,
                onChanged: (mode) => setState(() => _mode = mode),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: effectiveMode == _PickerMode.services
                ? _buildServices(context)
                : _buildPieces(context),
          ),
        ],
      ),
    );
  }

  Widget _buildServices(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Text('No hay servicios disponibles.'),
      );
    }

    final theme = Theme.of(context);
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        _SectionHeader(
          label: 'Servicios',
          icon: Icons.handyman_outlined,
          count: widget.categories.length,
        ),
        for (final category in _orderedCategories)
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: Icon(MaintenanceCategories.iconByName(category.iconName)),
            title: Text(category.name),
            trailing:
                widget.selectedComponentId == null &&
                    widget.selectedCategory == category.key
                ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                : null,
            onTap: () => Navigator.of(
              context,
            ).pop(_ItemSelection(category: category.key)),
          ),
      ],
    );
  }

  Widget _buildPieces(BuildContext context) {
    if (widget.components.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Text('No hay piezas disponibles.'),
      );
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        _SectionHeader(
          label: 'Piezas',
          icon: Icons.tire_repair,
          count: widget.components.length,
        ),
        for (final status in widget.components)
          ListTile(
            dense: true,
            leading: Icon(componentTypeFor(status.component.type).icon),
            title: Text(status.component.name),
            subtitle: Text(
              [
                if (status.component.position?.isNotEmpty == true)
                  status.component.position!,
                status.primaryLabel,
              ].where((part) => part.isNotEmpty).join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: widget.selectedComponentId == status.component.id
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => Navigator.of(
              context,
            ).pop(_ItemSelection(componentId: status.component.id)),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon, this.count});

  final String label;
  final IconData icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Text(
              '· $count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
