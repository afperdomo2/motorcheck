import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/form_section.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../../maintenance/categories.dart';
import '../models/maintenance_category.dart';
import '../providers.dart';
import '../repository.dart';

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
  String? _originalKey;
  DateTime? _originalCreatedAt;
  bool _isLoading = false;
  bool _dirty = false;

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
        _originalKey = cat.key;
        _originalCreatedAt = cat.createdAt;
        _dirty = false;
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
    final intervalKm = _intervalKmController.text.trim().isEmpty
        ? null
        : int.tryParse(_intervalKmController.text.trim());
    final warningKm = _warningKmController.text.trim().isEmpty
        ? null
        : int.tryParse(_warningKmController.text.trim());
    final key = _isEditing && _originalKey != null
        ? _originalKey!
        : '${_selectedVehicleType}_${_slugify(name)}';

    setState(() => _isLoading = true);

    final notifier = ref.read(maintenanceCategoriesNotifierProvider.notifier);

    try {
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
          createdAt: _originalCreatedAt ?? DateTime.now(),
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

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _dirty = false;
      });
      AppSnackBar.success(
        _isEditing ? 'Categoría actualizada' : 'Categoría creada',
      );
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } on CategoryKeyExistsException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.error(e.toString());
    } catch (error) {
      logError('guardar categoría', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo guardar la categoría',
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

  @override
  Widget build(BuildContext context) {
    final isNewFromType = !_isEditing && widget.vehicleType != null;
    final canEditType = !_isEditing && !isNewFromType;
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_dirty && !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar categoría' : 'Nueva categoría'),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        title: 'Categoría',
                        icon: Icons.category_outlined,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: 'Nombre *',
                                hintText: 'Ej: Cambio de bujías',
                                prefixIcon: Icon(Icons.label),
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingresa un nombre';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
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
                                            const SizedBox(
                                              width: AppSpacing.sm,
                                            ),
                                            Text(o.$2),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(
                                  () => _selectedVehicleType = v ?? 'car',
                                ),
                              ),
                            if (!canEditType)
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
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _sortOrderController,
                              decoration: const InputDecoration(
                                labelText: 'Orden',
                                hintText: 'Ej: 1',
                                helperText: 'Menor número aparece primero',
                                prefixIcon: Icon(Icons.format_list_numbered),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final n = int.tryParse(v.trim());
                                if (n == null || n < 0) {
                                  return 'Usa un número mayor o igual a 0';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FormSection(
                        title: 'Frecuencia',
                        icon: Icons.speed,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Se usa para calcular los próximos '
                              'mantenimientos del vehículo.',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _intervalKmController,
                              decoration: const InputDecoration(
                                labelText: 'Frecuencia (km)',
                                hintText: 'Ej: 2500',
                                suffixText: 'km',
                                prefixIcon: Icon(Icons.speed),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final n = int.tryParse(v.trim());
                                if (n == null || n <= 0) {
                                  return 'La frecuencia debe ser mayor a 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _warningKmController,
                              decoration: const InputDecoration(
                                labelText: 'Aviso (km antes)',
                                hintText: 'Ej: 200',
                                helperText:
                                    'Se avisa antes del próximo servicio',
                                suffixText: 'km',
                                prefixIcon: Icon(Icons.notifications_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final n = int.tryParse(v.trim());
                                if (n == null || n < 0) {
                                  return 'Usa un número mayor o igual a 0';
                                }
                                final interval = int.tryParse(
                                  _intervalKmController.text.trim(),
                                );
                                if (interval == null) {
                                  return 'Configura primero la frecuencia';
                                }
                                if (n >= interval) {
                                  return 'Debe ser menor que la frecuencia';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FormSection(
                        title: 'Ícono',
                        icon: Icons.palette_outlined,
                        child: _buildIconGrid(),
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
                        : Text(_isEditing ? 'Guardar' : 'Crear categoría'),
                  ),
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
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: _iconNameOptions.map((iconName) {
        final icon = MaintenanceCategories.iconByName(iconName);
        final selected = _selectedIcon == iconName;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedIcon = iconName;
            _dirty = true;
          }),
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
