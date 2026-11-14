import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/date_field.dart';
import '../../../shared/widgets/form_section.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../../vehicles/providers.dart';
import '../models/component_service.dart';
import '../models/vehicle_component.dart';
import '../providers.dart';

class ComponentServiceFormScreen extends ConsumerStatefulWidget {
  const ComponentServiceFormScreen({
    super.key,
    required this.vehicleId,
    required this.componentId,
  });

  final int vehicleId;
  final int componentId;

  @override
  ConsumerState<ComponentServiceFormScreen> createState() =>
      _ComponentServiceFormScreenState();
}

class _ComponentServiceFormScreenState
    extends ConsumerState<ComponentServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _resetInterval = false;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_prefillOdometer);
  }

  Future<void> _prefillOdometer() async {
    final vehicle = await ref.read(
      selectedVehicleProvider(widget.vehicleId).future,
    );
    final mileage = vehicle?.currentMileage;
    if (!mounted || mileage == null || _odometerController.text.isNotEmpty) {
      return;
    }
    setState(() => _odometerController.text = mileage.toString());
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseAmount(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Fecha del servicio',
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
    setState(() => _saving = true);

    final service = ComponentService(
      componentId: widget.componentId,
      date: _date,
      odometer: _odometerController.text.trim().isEmpty
          ? null
          : int.tryParse(_odometerController.text.trim()),
      cost: _parseAmount(_costController.text) ?? 0,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      resetInterval: _resetInterval,
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(componentsNotifierProvider.notifier)
          .registerService(service);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      AppSnackBar.success('Servicio registrado');
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('registrar servicio de componente', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo guardar el servicio'),
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
    final theme = Theme.of(context);
    final componentAsync = ref.watch(componentByIdProvider(widget.componentId));
    final component = componentAsync.valueOrNull;

    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Registrar servicio')),
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
                      if (component != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Text(
                            '${componentTypeFor(component.type).label} · '
                            '${component.name}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      FormSection(
                        title: 'Servicio',
                        icon: Icons.build_outlined,
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
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Odómetro',
                                hintText: 'Ej: 152300',
                                suffixText: 'km',
                                prefixIcon: Icon(Icons.speed_outlined),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _costController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Costo',
                                prefixText: '\$ ',
                                prefixIcon: Icon(Icons.payments_outlined),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Notas (opcional)',
                                hintText: 'Ej: cambio de llanta, rotación',
                                alignLabelWithHint: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Card(
                        child: SwitchListTile(
                          title: const Text('Este servicio reinicia el ciclo'),
                          subtitle: const Text(
                            'Úsalo para un cambio de llanta, batería o '
                            'pastillas. No lo actives para una rotación o '
                            'revisión.',
                          ),
                          value: _resetInterval,
                          onChanged: (value) => setState(() {
                            _resetInterval = value;
                            _dirty = true;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StickyBottomBar(
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Guardar servicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
