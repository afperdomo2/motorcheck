import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../dashboard/providers.dart';
import '../../maintenance/providers.dart';
import '../../reminders/providers.dart';
import '../models/vehicle.dart';
import '../providers.dart';

class MileageUpdateSheet extends ConsumerStatefulWidget {
  const MileageUpdateSheet({super.key, required this.vehicle});

  final Vehicle vehicle;

  static Future<void> show(BuildContext context, Vehicle vehicle) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (context) => MileageUpdateSheet(vehicle: vehicle),
    );
  }

  @override
  ConsumerState<MileageUpdateSheet> createState() => _MileageUpdateSheetState();
}

class _MileageUpdateSheetState extends ConsumerState<MileageUpdateSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.vehicle.currentMileage?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final mileage = int.tryParse(_controller.text.trim());
    if (mileage == null) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(vehiclesNotifierProvider.notifier)
          .updateMileage(widget.vehicle.id!, mileage);
      ref.invalidate(upcomingMaintenanceProvider);
      ref.invalidate(maintenanceAttentionCountProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(dashboardUpcomingProvider);
      ref.invalidate(vehicleMaintenanceSummaryProvider(widget.vehicle.id!));
      ref.invalidate(vehicleHealthProvider(widget.vehicle.id!));
      ref.invalidate(remindersProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.success('Kilometraje actualizado');
    } catch (error) {
      logError('actualizar kilometraje', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo actualizar el kilometraje',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = widget.vehicle.currentMileage;

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
                Icon(Icons.speed, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Actualizar kilometraje',
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
              current != null
                  ? 'Actual: ${formatMileage(current)}. '
                        'La corrección manual se hace desde Editar vehículo.'
                  : 'Registra el kilometraje actual para calcular los '
                        'próximos mantenimientos.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Kilometraje',
                hintText: 'Ej: 152300',
                prefixIcon: Icon(Icons.speed),
                suffixText: 'km',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final mileage = int.tryParse(value?.trim() ?? '');
                if (mileage == null || mileage < 0) {
                  return 'Ingresa un kilometraje válido';
                }
                if (current != null && mileage <= current) {
                  return 'Debe ser mayor a ${formatMileage(current)}';
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
              label: const Text('Guardar kilometraje'),
            ),
          ],
        ),
      ),
    );
  }
}
