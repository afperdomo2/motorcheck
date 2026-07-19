import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/vehicle.dart';
import '../providers.dart';
import '../widgets/vehicle_type_selector.dart';

class VehicleFormScreen extends ConsumerStatefulWidget {
  final int? vehicleId;

  const VehicleFormScreen({super.key, this.vehicleId});

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _plateController;
  late final TextEditingController _colorController;
  String _type = 'car';
  bool _isDefault = false;
  bool _isLoading = false;
  DateTime? _originalCreatedAt;

  bool get _isEditing => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _plateController = TextEditingController();
    _colorController = TextEditingController();

    if (_isEditing) {
      Future.microtask(() => _loadVehicle());
    }
  }

  Future<void> _loadVehicle() async {
    final vehicle = await ref
        .read(vehicleRepositoryProvider)
        .getById(widget.vehicleId!);
    if (vehicle != null && mounted) {
      _nameController.text = vehicle.name;
      _brandController.text = vehicle.brand ?? '';
      _modelController.text = vehicle.model ?? '';
      _yearController.text = vehicle.year?.toString() ?? '';
      _plateController.text = vehicle.plate ?? '';
      _colorController.text = vehicle.color ?? '';
      setState(() {
        _type = vehicle.type;
        _isDefault = vehicle.isDefault;
        _originalCreatedAt = vehicle.createdAt;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final vehicle = Vehicle(
      id: widget.vehicleId,
      name: _nameController.text.trim(),
      type: _type,
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      model: _modelController.text.trim().isEmpty
          ? null
          : _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()),
      plate: _plateController.text.trim().isEmpty
          ? null
          : _plateController.text.trim(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      isDefault: _isDefault,
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(vehiclesNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.update(vehicle);
    } else {
      await notifier.add(vehicle);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/vehicles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar vehículo' : 'Nuevo vehículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tipo de vehículo',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              VehicleTypeSelector(
                selectedType: _type,
                onChanged: (type) => setState(() => _type = type),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Marca'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: 'Año'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(labelText: 'Placa'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Vehículo por defecto'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                contentPadding: EdgeInsets.zero,
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
                      : Text(_isEditing ? 'Guardar' : 'Crear vehículo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
