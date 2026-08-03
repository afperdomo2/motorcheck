import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../vehicles/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../../settings/providers.dart';
import '../models/maintenance.dart';
import '../models/maintenance_item.dart';
import '../providers.dart';
import '../widgets/item_form_row.dart';

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
  DateTime? _originalCreatedAt;
  int? _vehicleCurrentMileage;
  DateTime? _vehicleMileageUpdatedAt;
  int? _workshopId;
  Vehicle? _vehicle;

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
      _items
        ..clear()
        ..addAll(items);
    });
  }

  Future<void> _loadVehicle() async {
    final vehicleId = widget.vehicleId ?? ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) return;
    final vehicle = await ref
        .read(vehicleRepositoryProvider)
        .getById(vehicleId);
    if (vehicle != null && mounted) {
      setState(() {
        _vehicleCurrentMileage = vehicle.currentMileage;
        _vehicleMileageUpdatedAt = vehicle.mileageUpdatedAt;
        _vehicle = vehicle;
      });
      if (vehicle.currentMileage != null) {
        _mileageController.text = vehicle.currentMileage.toString();
      }
    }
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
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  void _updateItem(int index, MaintenanceItem updated) {
    setState(() => _items[index] = updated);
  }

  double get _totalParts =>
      _items.fold<double>(0, (sum, i) => sum + i.partsCost);

  double get _maintenanceCost =>
      double.tryParse(_maintenanceCostController.text.trim()) ?? 0;

  double get _total => _maintenanceCost + _totalParts;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validItems = _items.toList();
    final vehicleId = widget.vehicleId ?? _vehicle?.id;
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

    if (_isEditing) {
      await notifier.update(maintenance, items);
    } else {
      await notifier.add(maintenance, items);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
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
      setState(() => _date = picked);
    }
  }

  Future<void> _addWorkshop() async {
    final result = await showDialog<({String name, String? location})>(
      context: context,
      builder: (ctx) {
        String name = '';
        String location = '';
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Nuevo taller'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  onChanged: (v) => name = v,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del taller *',
                    hintText: 'Ej: Taller Juan, Concesionario Toyota',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => location = v,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad / Ubicación',
                    hintText: 'Ej: Bogotá, Zona Norte',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (name.trim().isNotEmpty) {
                    Navigator.pop(ctx, (
                      name: name.trim(),
                      location: location.trim().isEmpty
                          ? null
                          : location.trim(),
                    ));
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      },
    );
    if (result != null && mounted) {
      final id = await ref
          .read(workshopRepositoryProvider)
          .insert(result.name, location: result.location);
      ref.invalidate(workshopsProvider);
      setState(() => _workshopId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workshopsAsync = ref.watch(workshopsProvider);
    final vehicleType = _vehicle?.type ?? 'other';
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];
    final vehicleCategories = categories
        .where((c) => c.vehicleType == vehicleType)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar mantenimiento' : 'Nuevo mantenimiento',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(formatShortDate(_date)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _mileageController,
                      decoration: InputDecoration(
                        labelText: _vehicleCurrentMileage != null
                            ? 'Kilometraje *'
                            : 'Kilometraje',
                        prefixIcon: const Icon(Icons.speed),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final isRequired = _vehicleCurrentMileage != null;
                        if (v == null || v.trim().isEmpty) {
                          return isRequired ? 'Requerido' : null;
                        }
                        final km = int.tryParse(v.trim());
                        if (km == null || km < 0) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_vehicleCurrentMileage != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Último registro: ${formatMileage(_vehicleCurrentMileage)}'
                  '${_vehicleMileageUpdatedAt != null ? ' (${formatDisplayDate(_vehicleMileageUpdatedAt!)})' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              workshopsAsync.when(
                loading: () => const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (workshops) {
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          initialValue: workshops.any((w) => w.id == _workshopId)
                              ? _workshopId
                              : null,
                          decoration: const InputDecoration(
                            labelText: '¿Dónde se hizo?',
                            prefixIcon: Icon(Icons.handyman),
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('--'),
                            ),
                            ...workshops.map(
                              (w) => DropdownMenuItem<int?>(
                                value: w.id,
                                child: Text(
                                  w.location != null && w.location!.isNotEmpty
                                      ? '${w.name} · ${w.location}'
                                      : w.name,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _workshopId = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addWorkshop,
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Agregar taller',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maintenanceCostController,
                decoration: const InputDecoration(
                  labelText: 'Precio del mantenimiento',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  hintText: 'Observaciones adicionales',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Items del mantenimiento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._items.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ItemFormRow(
                    item: entry.value,
                    index: entry.key,
                    canRemove: true,
                    categories: vehicleCategories,
                    onRemove: () => _removeItem(entry.key),
                    onChanged: (updated) => _updateItem(entry.key, updated),
                  ),
                ),
              ),
              if (_maintenanceCost > 0 || _totalParts > 0) ...[
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.summarize, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatCurrency(_total),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Guardar' : 'Registrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
