import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/date_field.dart';
import '../../../shared/widgets/form_section.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../../finance/budget_alert_service.dart';
import '../../vehicles/providers.dart';
import '../models/fuel_log.dart';
import '../providers.dart';

class FuelFormScreen extends ConsumerStatefulWidget {
  const FuelFormScreen({super.key, this.vehicleId, this.fuelLogId});

  final int? vehicleId;
  final int? fuelLogId;

  @override
  ConsumerState<FuelFormScreen> createState() => _FuelFormScreenState();
}

class _FuelFormScreenState extends ConsumerState<FuelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _totalController = TextEditingController();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();

  int? _vehicleId;
  String _vehicleName = '';
  DateTime _date = DateTime.now();
  String _fuelType = 'gasoline';
  bool _fullTank = true;
  bool _loading = false;
  bool _saving = false;
  bool _dirty = false;
  bool _totalManuallyEdited = false;
  int? _lastMileage;
  DateTime? _originalCreatedAt;

  bool get _isEditing => widget.fuelLogId != null;

  @override
  void initState() {
    super.initState();
    _vehicleId = widget.vehicleId;
    if (_isEditing) {
      _loading = true;
      Future.microtask(_load);
    } else {
      Future.microtask(_loadVehicle);
    }
  }

  Future<void> _load() async {
    final log = await ref
        .read(fuelRepositoryProvider)
        .getById(widget.fuelLogId!);
    if (!mounted) return;
    if (log != null) {
      _vehicleId = log.vehicleId;
      _odometerController.text = log.odometer.toString();
      _quantityController.text = log.quantity.toString();
      _unitPriceController.text = log.unitPrice.toString();
      _totalController.text = log.totalCost.toString();
      _stationController.text = log.station ?? '';
      _notesController.text = log.notes ?? '';
      _originalCreatedAt = log.createdAt;
      setState(() {
        _date = log.date;
        _fuelType = log.fuelType;
        _fullTank = log.fullTank;
        _loading = false;
        _dirty = false;
        _totalManuallyEdited = false;
      });
    } else {
      setState(() => _loading = false);
    }
    await _loadVehicle();
  }

  Future<void> _loadVehicle() async {
    final id = _vehicleId;
    if (id == null) return;
    final vehicle = await ref.read(vehicleRepositoryProvider).getById(id);
    final last = await ref.read(mileageRepositoryProvider).getLastReading(id);
    if (!mounted) return;
    setState(() {
      _vehicleName = vehicle?.name ?? 'Vehículo';
      _lastMileage = last?.mileage;
    });
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _totalController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  void _updateTotal() {
    if (_totalManuallyEdited) return;
    final quantity = _parseDouble(_quantityController.text);
    final price = _parseDouble(_unitPriceController.text);
    if (quantity == null || price == null) return;
    _totalController.text = (quantity * price).toStringAsFixed(0);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Fecha de la tanqueada',
    );
    if (date != null) {
      setState(() {
        _date = date;
        _dirty = true;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vehicleId = _vehicleId;
    if (vehicleId == null) {
      AppSnackBar.error('Selecciona un vehículo');
      return;
    }

    final quantity = _parseDouble(_quantityController.text) ?? 0;
    final unitPrice = _parseDouble(_unitPriceController.text) ?? 0;
    final total = _parseDouble(_totalController.text) ?? 0;
    final odometer = int.tryParse(_odometerController.text.trim()) ?? 0;

    setState(() => _saving = true);
    final now = DateTime.now();
    final log = FuelLog(
      id: widget.fuelLogId,
      vehicleId: vehicleId,
      date: _date,
      odometer: odometer,
      quantity: quantity,
      unitPrice: unitPrice,
      totalCost: total,
      fuelType: _fuelType,
      station: _stationController.text.trim().isEmpty
          ? null
          : _stationController.text.trim(),
      fullTank: _fullTank,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );

    try {
      await ref.read(fuelLogsNotifierProvider.notifier).save(log);
      unawaited(BudgetAlertService().check(vehicleId));
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      AppSnackBar.success(
        _isEditing ? 'Tanqueada actualizada' : 'Tanqueada registrada',
      );
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar tanqueada', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo guardar la tanqueada',
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
    final type = fuelTypeFor(_fuelType);
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isEditing ? 'Editar tanqueada' : 'Nueva tanqueada'),
              if (_vehicleName.isNotEmpty)
                Text(
                  _vehicleName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        body: _loading
            ? const LoadingIndicator()
            : Form(
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
                              title: 'Tanqueada',
                              icon: Icons.local_gas_station_outlined,
                              child: Column(
                                children: [
                                  DateField(
                                    label: 'Fecha *',
                                    value: _date,
                                    onTap: _pickDate,
                                    prefixIcon: Icons.calendar_today,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _odometerController,
                                    decoration: InputDecoration(
                                      labelText: 'Odómetro *',
                                      hintText: 'Ej: 89500',
                                      prefixIcon: const Icon(Icons.speed),
                                      suffixText: 'km',
                                      helperText: _lastMileage != null
                                          ? 'Último: ${formatMileage(_lastMileage)}'
                                          : null,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      final km = int.tryParse(
                                        value?.trim() ?? '',
                                      );
                                      if (km == null || km < 0) {
                                        return 'Ingresa un odómetro válido';
                                      }
                                      final last = _lastMileage;
                                      if (!_isEditing &&
                                          last != null &&
                                          km < last) {
                                        return 'No puede ser menor al último '
                                            'kilometraje (${formatMileage(last)})';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  DropdownButtonFormField<String>(
                                    initialValue: _fuelType,
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo de combustible',
                                      prefixIcon: Icon(Icons.local_gas_station),
                                    ),
                                    items: fuelTypeOptions
                                        .map(
                                          (option) => DropdownMenuItem(
                                            value: option.key,
                                            child: Row(
                                              children: [
                                                Icon(option.icon, size: 20),
                                                const SizedBox(
                                                  width: AppSpacing.sm,
                                                ),
                                                Text(option.label),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _fuelType = value;
                                        _dirty = true;
                                      });
                                    },
                                  ),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Tanque lleno'),
                                    subtitle: const Text(
                                      'Necesario para calcular el consumo real',
                                    ),
                                    value: _fullTank,
                                    onChanged: (value) => setState(() {
                                      _fullTank = value;
                                      _dirty = true;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Cantidad y costo',
                              icon: Icons.payments_outlined,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _quantityController,
                                    decoration: InputDecoration(
                                      labelText: 'Cantidad *',
                                      hintText: 'Ej: 42',
                                      prefixIcon: const Icon(Icons.water_drop),
                                      suffixText: type.unit,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]'),
                                      ),
                                    ],
                                    onChanged: (_) {
                                      _updateTotal();
                                      setState(() {});
                                    },
                                    validator: (value) {
                                      final quantity = _parseDouble(
                                        value ?? '',
                                      );
                                      if (quantity == null || quantity <= 0) {
                                        return 'Ingresa una cantidad válida';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _unitPriceController,
                                    decoration: InputDecoration(
                                      labelText: 'Precio por ${type.unit}',
                                      hintText: 'Ej: 4285',
                                      prefixIcon: const Icon(
                                        Icons.attach_money,
                                      ),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]'),
                                      ),
                                    ],
                                    onChanged: (_) {
                                      _updateTotal();
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _totalController,
                                    decoration: const InputDecoration(
                                      labelText: 'Total pagado *',
                                      hintText: 'Ej: 180000',
                                      prefixIcon: Icon(Icons.receipt_long),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]'),
                                      ),
                                    ],
                                    onChanged: (_) =>
                                        _totalManuallyEdited = true,
                                    validator: (value) {
                                      final total = _parseDouble(value ?? '');
                                      if (total == null || total < 0) {
                                        return 'Ingresa un total válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _stationController,
                                    decoration: const InputDecoration(
                                      labelText: 'Estación (opcional)',
                                      hintText: 'Ej: Terpel Calle 100',
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                      ),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Notas',
                              icon: Icons.note_alt_outlined,
                              child: TextFormField(
                                controller: _notesController,
                                minLines: 2,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Observaciones opcionales',
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'El odómetro actualiza el kilometraje del '
                              'vehículo solo si es mayor al registrado.',
                              style: theme.textTheme.bodySmall,
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
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isEditing
                                      ? 'Guardar cambio'
                                      : 'Guardar tanqueada',
                                ),
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
