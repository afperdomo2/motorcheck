import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/maintenance_category.dart';
import '../providers.dart';

const _vehicleTypeOptions = [
  ('car', 'Carro', Icons.directions_car),
  ('motorcycle', 'Moto', Icons.motorcycle),
  ('bike', 'Bicicleta', Icons.pedal_bike),
  ('truck', 'Camión', Icons.local_shipping),
  ('other', 'Otro', Icons.help_outline),
];

const _iconNameOptions = [
  'build',
  'construction',
  'oil_barrel',
  'disc_full',
  'settings',
  'tire_repair',
  'circle',
  'filter_alt',
  'battery_charging_full',
  'ac_unit',
  'electrical_services',
  'link',
  'water_drop',
  'local_gas_station',
  'directions_car',
  'cleaning_services',
  'cable',
  'handyman',
  'brightness_high',
  'sensors',
  'air',
  'radio',
  'camera',
  'visibility',
  'speed',
  'bolt',
  'palette',
  'security',
  'star',
];

const _iconMap = {
  'build': Icons.build,
  'construction': Icons.construction,
  'oil_barrel': Icons.oil_barrel,
  'disc_full': Icons.disc_full,
  'settings': Icons.settings,
  'tire_repair': Icons.tire_repair,
  'circle': Icons.circle,
  'filter_alt': Icons.filter_alt,
  'battery_charging_full': Icons.battery_charging_full,
  'ac_unit': Icons.ac_unit,
  'electrical_services': Icons.electrical_services,
  'link': Icons.link,
  'water_drop': Icons.water_drop,
  'local_gas_station': Icons.local_gas_station,
  'directions_car': Icons.directions_car,
  'cleaning_services': Icons.cleaning_services,
  'cable': Icons.cable,
  'handyman': Icons.handyman,
  'brightness_high': Icons.brightness_high,
  'sensors': Icons.sensors,
  'air': Icons.air,
  'radio': Icons.radio,
  'camera': Icons.camera,
  'visibility': Icons.visibility,
  'speed': Icons.speed,
  'bolt': Icons.bolt,
  'palette': Icons.palette,
  'security': Icons.security,
  'star': Icons.star,
};

String _slugify(String text) {
  final slug = text
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll(RegExp(r'ñ'), 'n')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return slug.isEmpty ? 'general' : slug;
}

class CategoryFormScreen extends ConsumerStatefulWidget {
  final int? categoryId;
  final String? vehicleType;

  const CategoryFormScreen({super.key, this.categoryId, this.vehicleType});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _intervalKmController;
  late final TextEditingController _warningKmController;
  String _selectedIcon = 'build';
  String _selectedVehicleType = 'car';
  bool _isLoading = false;

  bool get _isEditing => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _sortOrderController = TextEditingController();
    _intervalKmController = TextEditingController();
    _warningKmController = TextEditingController();

    if (widget.vehicleType != null) {
      _selectedVehicleType = widget.vehicleType!;
    }

    if (_isEditing) {
      Future.microtask(() => _loadCategory());
    }
  }

  Future<void> _loadCategory() async {
    final cat = await ref
        .read(maintenanceCategoryRepositoryProvider)
        .getById(widget.categoryId!);
    if (cat != null && mounted) {
      _nameController.text = cat.name;
      _sortOrderController.text = cat.sortOrder.toString();
      _intervalKmController.text = cat.intervalKm != null
          ? cat.intervalKm.toString()
          : '';
      _warningKmController.text = cat.warningKm != null
          ? cat.warningKm.toString()
          : '';
      setState(() {
        _selectedIcon = cat.iconName;
        _selectedVehicleType = cat.vehicleType;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortOrderController.dispose();
    _intervalKmController.dispose();
    _warningKmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final sortOrder = int.tryParse(_sortOrderController.text.trim()) ?? 0;
    final intervalKm = int.tryParse(_intervalKmController.text.trim());
    final warningKm = int.tryParse(_warningKmController.text.trim());
    final key = '${_selectedVehicleType}_${_slugify(name)}';

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(maintenanceCategoriesNotifierProvider.notifier);

      if (_isEditing) {
        final category = MaintenanceCategory(
          id: widget.categoryId,
          key: key,
          name: name,
          iconName: _selectedIcon,
          vehicleType: _selectedVehicleType,
          sortOrder: sortOrder,
          intervalKm: intervalKm,
          warningKm: warningKm,
          createdAt: DateTime.now(),
        );
        await notifier.update(category);
      } else {
        final category = MaintenanceCategory(
          key: key,
          name: name,
          iconName: _selectedIcon,
          vehicleType: _selectedVehicleType,
          sortOrder: sortOrder,
          intervalKm: intervalKm,
          warningKm: warningKm,
          createdAt: DateTime.now(),
        );
        await notifier.add(category);
      }

      ref.invalidate(maintenanceCategoriesProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewFromType = !_isEditing && widget.vehicleType != null;
    final canEditType = !_isEditing && !isNewFromType;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar categoría' : 'Nueva categoría'),
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
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ej: Cambio de bujías',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (canEditType)
                DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de vehículo *',
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  items: _vehicleTypeOptions
                      .map(
                        (o) => DropdownMenuItem(
                          value: o.$1,
                          child: Row(
                            children: [
                              Icon(o.$3, size: 20),
                              const SizedBox(width: 8),
                              Text(o.$2),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedVehicleType = v ?? 'car'),
                ),
              if (!canEditType) ...[
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de vehículo',
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  child: Text(
                    _vehicleTypeOptions
                        .firstWhere(
                          (o) => o.$1 == _selectedVehicleType,
                          orElse: () => _vehicleTypeOptions.first,
                        )
                        .$2,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(
                  labelText: 'Orden',
                  hintText: 'Número de orden (0 primero)',
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _intervalKmController,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia (km)',
                  hintText: 'Ej: 2500',
                  prefixIcon: Icon(Icons.speed),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _warningKmController,
                decoration: const InputDecoration(
                  labelText: 'Aviso (km antes)',
                  hintText: 'Ej: 200',
                  prefixIcon: Icon(Icons.notifications_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Text('Ícono *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildIconGrid(),
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
                      : Text(_isEditing ? 'Guardar' : 'Crear categoría'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: _iconNameOptions.map((iconName) {
        final icon = _iconMap[iconName] ?? Icons.build;
        final selected = _selectedIcon == iconName;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = iconName),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: selected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Icon(
              icon,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
        );
      }).toList(),
    );
  }
}
