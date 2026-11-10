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
import '../../maintenance/providers.dart';
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
  late final TextEditingController _mileageController;
  String _type = 'car';
  bool _isDefault = false;
  bool _isLoading = false;
  bool _dirty = false;
  DateTime? _originalCreatedAt;
  int? _originalMileage;
  DateTime? _originalMileageUpdatedAt;
  int? _maxMaintenanceMileage;

  final _vinController = TextEditingController();
  DateTime? _soatDate;
  DateTime? _rtmDate;

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
    _mileageController = TextEditingController();

    if (_isEditing) {
      Future.microtask(() => _loadVehicle());
    }
  }

  Future<void> _loadVehicle() async {
    final vehicle = await ref
        .read(vehicleRepositoryProvider)
        .getById(widget.vehicleId!);
    if (vehicle == null || !mounted) return;

    final maxMaintenanceMileage = await ref
        .read(maintenanceRepositoryProvider)
        .getMaxMileageByVehicle(widget.vehicleId!);
    if (!mounted) return;

    _nameController.text = vehicle.name;
    _brandController.text = vehicle.brand ?? '';
    _modelController.text = vehicle.model ?? '';
    _yearController.text = vehicle.year?.toString() ?? '';
    _plateController.text = vehicle.plate ?? '';
    _colorController.text = vehicle.color ?? '';
    _mileageController.text = vehicle.currentMileage?.toString() ?? '';
    _vinController.text = vehicle.vin ?? '';
    _soatDate = vehicle.soatExpiresAt;
    _rtmDate = vehicle.rtmExpiresAt;
    setState(() {
      _type = vehicle.type;
      _isDefault = vehicle.isDefault;
      _originalCreatedAt = vehicle.createdAt;
      _originalMileage = vehicle.currentMileage;
      _originalMileageUpdatedAt = vehicle.mileageUpdatedAt;
      _maxMaintenanceMileage = maxMaintenanceMileage;
      _dirty = false;
    });
  }

  bool get _mileageBelowMax {
    final km = int.tryParse(_mileageController.text.trim());
    final max = _maxMaintenanceMileage;
    return km != null && max != null && km < max;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim().isNotEmpty
        ? _brandController.text.trim()
        : null;
    final model = _modelController.text.trim().isNotEmpty
        ? _modelController.text.trim()
        : null;
    final autoName = name.isNotEmpty
        ? name
        : [brand, model].whereType<String>().join(' ').trim().isNotEmpty
        ? [brand, model].whereType<String>().join(' ').trim()
        : 'Mi vehículo';

    final mileageText = _mileageController.text.trim();
    final newMileage = int.tryParse(mileageText);

    final vehicle = Vehicle(
      id: widget.vehicleId,
      name: autoName,
      type: _type,
      brand: brand,
      model: model,
      year: int.tryParse(_yearController.text.trim()),
      plate: _plateController.text.trim().isEmpty
          ? null
          : _plateController.text.trim(),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      currentMileage: newMileage,
      mileageUpdatedAt: mileageText.isNotEmpty
          ? (newMileage == _originalMileage ? _originalMileageUpdatedAt : now)
          : null,
      isDefault: _isDefault,
      vin: _vinController.text.trim().isEmpty
          ? null
          : _vinController.text.trim(),
      soatExpiresAt: _soatDate,
      rtmExpiresAt: _rtmDate,
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(vehiclesNotifierProvider.notifier);

    try {
      if (_isEditing) {
        await notifier.update(vehicle);
      } else {
        await notifier.add(vehicle);
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _dirty = false;
      });
      AppSnackBar.success(
        _isEditing ? 'Vehículo actualizado' : 'Vehículo creado',
      );
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar vehículo', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo guardar el vehículo'),
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

  Future<void> _pickSoatDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _soatDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Vencimiento SOAT',
    );
    if (date != null) {
      setState(() {
        _soatDate = date;
        _dirty = true;
      });
    }
  }

  Future<void> _pickRtmDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _rtmDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Vencimiento tecnomecánica',
    );
    if (date != null) {
      setState(() {
        _rtmDate = date;
        _dirty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = AppSemanticColors.of(context);
    return PopScope(
      canPop: !_dirty && !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar vehículo' : 'Nuevo vehículo'),
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
                      FormSection(
                        title: 'Identificación',
                        icon: Icons.badge_outlined,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre (opcional)',
                                hintText: 'Ej: Mi carro',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Tipo de vehículo',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            VehicleTypeSelector(
                              selectedType: _type,
                              onChanged: (type) => setState(() {
                                _type = type;
                                _dirty = true;
                              }),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _brandController,
                              decoration: const InputDecoration(
                                labelText: 'Marca',
                                hintText: 'Ej: Toyota',
                                prefixIcon: Icon(Icons.factory_outlined),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _modelController,
                              decoration: const InputDecoration(
                                labelText: 'Modelo',
                                hintText: 'Ej: Corolla',
                                prefixIcon: Icon(Icons.info_outline),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _yearController,
                              decoration: const InputDecoration(
                                labelText: 'Año',
                                hintText: 'Ej: 2020',
                                prefixIcon: Icon(Icons.calendar_month_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final year = int.tryParse(v.trim());
                                if (year == null) {
                                  return 'Ingresa un año válido';
                                }
                                final currentYear = DateTime.now().year;
                                if (year < 1886 || year > currentYear + 1) {
                                  return 'Año fuera de rango';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _plateController,
                              decoration: const InputDecoration(
                                labelText: 'Placa',
                                hintText: 'Ej: ABC123',
                                prefixIcon: Icon(Icons.pin_outlined),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _colorController,
                              decoration: const InputDecoration(
                                labelText: 'Color',
                                hintText: 'Ej: Blanco',
                                prefixIcon: Icon(Icons.palette_outlined),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FormSection(
                        title: 'Documentos',
                        icon: Icons.description_outlined,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _vinController,
                              decoration: const InputDecoration(
                                labelText: 'VIN / Número de serie',
                                hintText: '17 caracteres alfanuméricos',
                                prefixIcon: Icon(Icons.numbers),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 17,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                if (v.trim().length != 17) {
                                  return 'El VIN debe tener 17 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            DateField(
                              label: 'Vencimiento SOAT',
                              value: _soatDate,
                              onTap: _pickSoatDate,
                              onClear: () => setState(() {
                                _soatDate = null;
                                _dirty = true;
                              }),
                              prefixIcon: Icons.health_and_safety_outlined,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            DateField(
                              label: 'Tecnomecánica (RTM)',
                              value: _rtmDate,
                              onTap: _pickRtmDate,
                              onClear: () => setState(() {
                                _rtmDate = null;
                                _dirty = true;
                              }),
                              prefixIcon: Icons.engineering_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FormSection(
                        title: 'Estado',
                        icon: Icons.speed,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _mileageController,
                              decoration: const InputDecoration(
                                labelText: 'Kilometraje actual',
                                hintText: 'Ej: 15000',
                                prefixIcon: Icon(Icons.speed),
                                suffixText: 'km',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => setState(() {}),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final km = int.tryParse(v.trim());
                                if (km == null || km < 0) {
                                  return 'Ingresa un kilometraje válido';
                                }
                                return null;
                              },
                            ),
                            if (_mileageBelowMax) ...[
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
                                      'Es menor al último mantenimiento '
                                      'registrado '
                                      '(${formatMileage(_maxMaintenanceMileage)}). '
                                      'Verifica el dato.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: semantic.warning),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            SwitchListTile(
                              title: const Text('Vehículo por defecto'),
                              subtitle: const Text(
                                'Se mostrará primero en el inicio',
                              ),
                              value: _isDefault,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (value) => setState(() {
                                _isDefault = value;
                                _dirty = true;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              StickyBottomBar(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
