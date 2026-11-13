import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/date_field.dart';
import '../../../shared/widgets/form_section.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../../../shared/widgets/vehicle_selector_sheet.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../../settings/providers.dart';
import '../models/maintenance.dart';
import '../models/maintenance_item.dart';
import '../providers.dart';
import '../widgets/item_form_row.dart';
import '../widgets/vehicle_ficha.dart';

class MaintenanceFormScreen extends ConsumerStatefulWidget {
  final int? maintenanceId;
  final int? vehicleId;

  const MaintenanceFormScreen({super.key, this.maintenanceId, this.vehicleId});

  @override
  ConsumerState<MaintenanceFormScreen> createState() =>
      _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends ConsumerState<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _mileageController;
  late final TextEditingController _notesController;
  late final TextEditingController _maintenanceCostController;
  DateTime _date = DateTime.now();
  final List<MaintenanceItem> _items = [];
  bool _isLoading = false;
  bool _dirty = false;
  bool _mileageBelowLast = false;
  DateTime? _originalCreatedAt;
  int? _vehicleCurrentMileage;
  DateTime? _vehicleMileageUpdatedAt;
  int? _workshopId;
  Vehicle? _vehicle;
  bool _vehicleLoaded = false;

  bool get _isEditing => widget.maintenanceId != null;

  @override
  void initState() {
    super.initState();
    _mileageController = TextEditingController();
    _notesController = TextEditingController();
    _maintenanceCostController = TextEditingController();

    if (!_isEditing) {
      Future.microtask(() => _loadVehicle());
    } else {
      Future.microtask(() => _loadMaintenance());
    }
  }

  Future<void> _loadMaintenance() async {
    final maintenance = await ref
        .read(maintenanceRepositoryProvider)
        .getById(widget.maintenanceId!);
    if (maintenance == null || !mounted) return;
    final items = await ref
        .read(maintenanceRepositoryProvider)
        .getItems(maintenance.id!);

    final vehicle = await ref
        .read(vehicleRepositoryProvider)
        .getById(maintenance.vehicleId);
    if (!mounted) return;

    _mileageController.text = maintenance.mileage?.toString() ?? '';
    _notesController.text = maintenance.notes ?? '';
    _maintenanceCostController.text = maintenance.maintenanceCost > 0
        ? maintenance.maintenanceCost.toStringAsFixed(0)
        : '';
    setState(() {
      _date = maintenance.date;
      _originalCreatedAt = maintenance.createdAt;
      _workshopId = maintenance.workshopId;
      _vehicle = vehicle;
      _vehicleLoaded = true;
      _items
        ..clear()
        ..addAll(items);
      _dirty = false;
    });
  }

  Future<void> _loadVehicle() async {
    final vehicleId = widget.vehicleId ?? ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) {
      if (mounted) setState(() => _vehicleLoaded = true);
      return;
    }
    final vehicle = await ref
        .read(vehicleRepositoryProvider)
        .getById(vehicleId);
    if (!mounted) return;
    setState(() {
      _vehicleCurrentMileage = vehicle?.currentMileage;
      _vehicleMileageUpdatedAt = vehicle?.mileageUpdatedAt;
      _vehicle = vehicle;
      _vehicleLoaded = true;
      _dirty = false;
    });
    if (vehicle?.currentMileage != null) {
      _mileageController.text = vehicle!.currentMileage.toString();
    }
  }

  Future<void> _pickVehicle() async {
    final selected = await VehicleSelectorSheet.show(context);
    if (selected == null || selected.id == null || !mounted) return;
    if (selected.id == _vehicle?.id) return;

    setState(() {
      _vehicle = selected;
      _vehicleCurrentMileage = selected.currentMileage;
      _vehicleMileageUpdatedAt = selected.mileageUpdatedAt;
      _mileageBelowLast = false;
    });
    _mileageController.text = selected.currentMileage?.toString() ?? '';
    await ref
        .read(vehiclesNotifierProvider.notifier)
        .selectVehicle(selected.id!);
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _notesController.dispose();
    _maintenanceCostController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        MaintenanceItem(
          maintenanceId: widget.maintenanceId ?? 0,
          createdAt: DateTime.now(),
        ),
      );
      _dirty = true;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _dirty = true;
    });
  }

  void _updateItem(int index, MaintenanceItem updated) {
    setState(() {
      _items[index] = updated;
      _dirty = true;
    });
  }

  void _updateMileageWarning() {
    final km = int.tryParse(_mileageController.text.trim());
    final last = _vehicleCurrentMileage;
    final below = !_isEditing && km != null && last != null && km < last;
    if (below != _mileageBelowLast) {
      setState(() => _mileageBelowLast = below);
    }
  }

  double get _totalParts =>
      _items.fold<double>(0, (sum, i) => sum + i.partsCost);

  double get _maintenanceCost =>
      double.tryParse(_maintenanceCostController.text.trim()) ?? 0;

  double get _total => _maintenanceCost + _totalParts;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validItems = _items.toList();
    final vehicleId = _vehicle?.id ?? widget.vehicleId;
    if (vehicleId == null) return;

    setState(() => _isLoading = true);
    final now = DateTime.now();

    final maintenance = Maintenance(
      id: widget.maintenanceId,
      vehicleId: vehicleId,
      date: _date,
      mileage: int.tryParse(_mileageController.text.trim()),
      maintenanceCost: _maintenanceCost,
      totalPartsCost: _totalParts,
      workshopId: _workshopId,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );

    final items = validItems
        .map(
          (i) => i.copyWith(
            maintenanceId: widget.maintenanceId ?? 0,
            createdAt: i.createdAt,
          ),
        )
        .toList();

    final notifier = ref.read(maintenancesNotifierProvider.notifier);

    try {
      if (_isEditing) {
        await notifier.update(maintenance, items);
      } else {
        await notifier.add(maintenance, items);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _dirty = false;
      });
      AppSnackBar.success(
        _isEditing ? 'Mantenimiento actualizado' : 'Mantenimiento registrado',
      );
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar mantenimiento', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo guardar el mantenimiento',
        ),
      );
    }
  }

  Future<void> _confirmDiscard() async {
    final leave = await showConfirmDialog(
      context,
      title: 'Descartar cambios',
      message: '¿Salir sin guardar los cambios?',
      confirmLabel: 'Descartar',
      cancelLabel: 'Seguir editando',
      isDestructive: true,
    );
    if (leave == true && mounted) {
      setState(() => _dirty = false);
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dirty = true;
      });
    }
  }

  Future<void> _addWorkshop() async {
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<({String name, String? location})>(
      context: context,
      builder: (ctx) {
        String name = '';
        String location = '';
        return AlertDialog(
          title: const Text('Nuevo taller'),
          scrollable: true,
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  autofocus: true,
                  onChanged: (v) => name = v,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del taller *',
                    hintText: 'Ej: Taller Juan, Concesionario Toyota',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa un nombre'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  onChanged: (v) => location = v,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad / Ubicación',
                    hintText: 'Ej: Bogotá, Zona Norte',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx, (
                  name: name.trim(),
                  location: location.trim().isEmpty ? null : location.trim(),
                ));
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    if (result == null || !mounted) return;

    try {
      final id = await ref
          .read(workshopRepositoryProvider)
          .insert(result.name, location: result.location);
      ref.invalidate(workshopsProvider);
      setState(() {
        _workshopId = id;
        _dirty = true;
      });
    } catch (error) {
      logError('crear taller desde mantenimiento', error, StackTrace.current);
      if (mounted) {
        AppSnackBar.error(
          friendlyErrorMessage(error, fallback: 'No se pudo crear el taller'),
        );
      }
    }
  }

  Widget _buildWorkshopField(AsyncValue<List<dynamic>> workshopsAsync) {
    return workshopsAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (workshops) {
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                key: ValueKey('workshop-$_workshopId-${workshops.length}'),
                isExpanded: true,
                initialValue: workshops.any((w) => w.id == _workshopId)
                    ? _workshopId
                    : null,
                decoration: const InputDecoration(
                  labelText: '¿Dónde se hizo?',
                  prefixIcon: Icon(Icons.handyman_outlined),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sin taller'),
                  ),
                  ...workshops.map(
                    (w) => DropdownMenuItem<int?>(
                      value: w.id,
                      child: Text(
                        w.location != null && w.location!.isNotEmpty
                            ? '${w.name} · ${w.location}'
                            : w.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() {
                  _workshopId = value;
                  _dirty = true;
                }),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filledTonal(
              onPressed: _addWorkshop,
              icon: const Icon(Icons.add),
              tooltip: 'Agregar taller',
            ),
          ],
        );
      },
    );
  }

  Widget? _buildVehicleHeader() {
    final vehicle = _vehicle;
    if (vehicle != null) {
      return Card(
        child: VehicleFicha(
          vehicle: vehicle,
          onTap: _isEditing ? null : _pickVehicle,
        ),
      );
    }

    // Mientras no haya vehículo resuelto no se muestra nada; al crear sí se
    // ofrece elegirlo para no llegar a un formulario que no puede guardar.
    if (!_vehicleLoaded || _isEditing) return null;
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: _pickVehicle,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_car_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Selecciona un vehículo',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(
                Icons.expand_more,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workshopsAsync = ref.watch(workshopsProvider);
    final vehicleType = _vehicle?.type ?? 'other';
    final categories =
        ref.watch(maintenanceCategoriesProvider).valueOrNull ?? [];
    final vehicleCategories = categories
        .where((c) => c.vehicleType == vehicleType)
        .toList();
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final vehicleHeader = _buildVehicleHeader();

    return PopScope(
      canPop: !_dirty && !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Editar mantenimiento' : 'Nuevo mantenimiento',
          ),
        ),
        body: Form(
          key: _formKey,
          onChanged: () {
            if (!_dirty) setState(() => _dirty = true);
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (vehicleHeader != null) ...[
                        vehicleHeader,
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      FormSection(
                        title: 'Datos del mantenimiento',
                        icon: Icons.event_note_outlined,
                        child: Column(
                          children: [
                            DateField(
                              label: 'Fecha *',
                              value: _date,
                              onTap: _pickDate,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _mileageController,
                              decoration: InputDecoration(
                                labelText: _vehicleCurrentMileage != null
                                    ? 'Kilometraje *'
                                    : 'Kilometraje',
                                prefixIcon: const Icon(Icons.speed),
                                suffixText: 'km',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => _updateMileageWarning(),
                              validator: (v) {
                                final isRequired =
                                    _vehicleCurrentMileage != null;
                                if (v == null || v.trim().isEmpty) {
                                  return isRequired ? 'Requerido' : null;
                                }
                                final km = int.tryParse(v.trim());
                                if (km == null || km < 0) return 'Inválido';
                                return null;
                              },
                            ),
                            if (_vehicleCurrentMileage != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Último registro: '
                                  '${formatMileage(_vehicleCurrentMileage)}'
                                  '${_vehicleMileageUpdatedAt != null ? ' (${formatDisplayDate(_vehicleMileageUpdatedAt!)})' : ''}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                            if (_mileageBelowLast) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 14,
                                    color: semantic.warning,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      'Es menor al último registro '
                                      '(${formatMileage(_vehicleCurrentMileage)}). '
                                      'Verifica el dato.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: semantic.warning),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            _buildWorkshopField(workshopsAsync),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _maintenanceCostController,
                              decoration: InputDecoration(
                                labelText: 'Mano de obra',
                                prefixIcon: const Icon(Icons.attach_money),
                                suffixText: 'COP',
                                helperText: _maintenanceCost > 0
                                    ? formatCurrency(_maintenanceCost)
                                    : null,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notas',
                                hintText: 'Observaciones adicionales',
                                prefixIcon: Icon(Icons.note_alt_outlined),
                              ),
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FormSection(
                        title: 'Ítems del mantenimiento',
                        icon: Icons.build_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _items.isEmpty
                                        ? 'Sin ítems'
                                        : '${_items.length} ítem${_items.length == 1 ? '' : 's'}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _addItem,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar'),
                                ),
                              ],
                            ),
                            if (_items.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
                                child: Text(
                                  'Agrega repuestos o trabajos realizados '
                                  'para llevar el detalle del costo.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              )
                            else ...[
                              const SizedBox(height: AppSpacing.sm),
                              ..._items.asMap().entries.map(
                                (entry) => ItemFormRow(
                                  key: ValueKey(
                                    entry.value.createdAt.toIso8601String(),
                                  ),
                                  item: entry.value,
                                  index: entry.key,
                                  canRemove: true,
                                  categories: vehicleCategories,
                                  onRemove: () => _removeItem(entry.key),
                                  onChanged: (updated) =>
                                      _updateItem(entry.key, updated),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              StickyBottomBar(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Total', style: theme.textTheme.bodySmall),
                          Text(
                            formatCurrency(_total),
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Guardar' : 'Registrar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
