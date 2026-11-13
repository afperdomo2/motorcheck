import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/date_field.dart';
import '../../maintenance/providers.dart';
import '../../reminders/providers.dart';
import '../providers.dart';

class MileageReadingFormSheet extends ConsumerStatefulWidget {
  const MileageReadingFormSheet({super.key, required this.vehicleId});

  final int vehicleId;

  static Future<void> show(BuildContext context, int vehicleId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (context) => MileageReadingFormSheet(vehicleId: vehicleId),
    );
  }

  @override
  ConsumerState<MileageReadingFormSheet> createState() =>
      _MileageReadingFormSheetState();
}

class _MileageReadingFormSheetState
    extends ConsumerState<MileageReadingFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Fecha de la lectura',
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final mileage = int.tryParse(_mileageController.text.trim());
    if (mileage == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(mileageRepositoryProvider)
          .addReading(
            vehicleId: widget.vehicleId,
            mileage: mileage,
            date: _date,
          );
      _invalidate();
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.success('Lectura agregada');
    } catch (error) {
      logError('agregar lectura de km', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo agregar la lectura'),
      );
    }
  }

  void _invalidate() {
    ref.invalidate(vehicleMileageReadingsProvider(widget.vehicleId));
    ref.invalidate(mileageStatsProvider(widget.vehicleId));
    ref.invalidate(vehiclesProvider);
    ref.invalidate(selectedVehicleProvider(widget.vehicleId));
    ref.invalidate(upcomingMaintenanceProvider);
    ref.invalidate(maintenanceAttentionCountProvider);
    ref.invalidate(vehicleHealthProvider(widget.vehicleId));
    ref.invalidate(remindersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.add_road, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Agregar lectura',
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Úsala para corregir o registrar el kilometraje en una fecha '
              'pasada. El vehículo solo sube automáticamente.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            DateField(
              label: 'Fecha *',
              value: _date,
              onTap: _pickDate,
              prefixIcon: Icons.calendar_today,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _mileageController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Kilometraje *',
                hintText: 'Ej: 152300',
                prefixIcon: const Icon(Icons.speed),
                suffixText: 'km',
                helperText:
                    'Último registrado: ${formatMileage(ref.read(mileageStatsProvider(widget.vehicleId)).valueOrNull?.currentMileage)}',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final mileage = int.tryParse(value?.trim() ?? '');
                if (mileage == null || mileage < 0) {
                  return 'Ingresa un kilometraje válido';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Guardar lectura'),
            ),
          ],
        ),
      ),
    );
  }
}
