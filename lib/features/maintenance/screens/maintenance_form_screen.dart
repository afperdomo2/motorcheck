import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../vehicles/providers.dart';
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
  late final TextEditingController _titleController;
  late final TextEditingController _mileageController;
  late final TextEditingController _notesController;
  DateTime _date = DateTime.now();
  final List<MaintenanceItem> _items = [];
  bool _isLoading = false;
  DateTime? _originalCreatedAt;

  bool get _isEditing => widget.maintenanceId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _mileageController = TextEditingController();
    _notesController = TextEditingController();

    if (!_isEditing) {
      _addItem();
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

    _titleController.text = maintenance.title;
    _mileageController.text = maintenance.mileage?.toString() ?? '';
    _notesController.text = maintenance.notes ?? '';
    setState(() {
      _date = maintenance.date;
      _originalCreatedAt = maintenance.createdAt;
      _items
        ..clear()
        ..addAll(items);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        MaintenanceItem(
          maintenanceId: widget.maintenanceId ?? 0,
          name: '',
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() => _items.removeAt(index));
    }
  }

  void _updateItem(int index, MaintenanceItem updated) {
    setState(() => _items[index] = updated);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validItems = _items.where((i) => i.name.trim().isNotEmpty).toList();
    if (validItems.isEmpty) return;

    setState(() => _isLoading = true);

    final vehicleId =
        widget.vehicleId ?? ref.read(selectedVehicleIdProvider);
    if (vehicleId == null) return;
    final now = DateTime.now();

    final totalLabor = validItems.fold<double>(
      0,
      (sum, i) => sum + i.laborCost,
    );
    final totalParts = validItems.fold<double>(
      0,
      (sum, i) => sum + i.partsCost,
    );

    final maintenance = Maintenance(
      id: widget.maintenanceId,
      vehicleId: vehicleId,
      title: _titleController.text.trim(),
      date: _date,
      mileage: int.tryParse(_mileageController.text.trim()),
      totalLaborCost: totalLabor,
      totalPartsCost: totalParts,
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

  @override
  Widget build(BuildContext context) {
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Ej: Cambio de aceite',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Fecha *'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_date.day}/${_date.month}/${_date.year}'),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Kilometraje',
                  hintText: 'Ej: 15000',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final km = int.tryParse(v.trim());
                  if (km == null || km < 0) {
                    return 'Ingresa un kilometraje válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  hintText: 'Observaciones adicionales',
                ),
                maxLines: 3,
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
                    canRemove: _items.length > 1,
                    onRemove: () => _removeItem(entry.key),
                    onChanged: (updated) => _updateItem(entry.key, updated),
                  ),
                ),
              ),
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
