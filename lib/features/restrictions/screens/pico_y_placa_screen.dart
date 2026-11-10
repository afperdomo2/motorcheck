import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/form_section.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/vehicle_restriction.dart';
import '../providers.dart';
import '../restriction_status.dart';

class PicoYPlacaScreen extends ConsumerStatefulWidget {
  const PicoYPlacaScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  ConsumerState<PicoYPlacaScreen> createState() => _PicoYPlacaScreenState();
}

class _PicoYPlacaScreenState extends ConsumerState<PicoYPlacaScreen> {
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  bool _enabled = false;
  bool _exempt = false;
  final Set<int> _days = {};
  TimeOfDay _start = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 21, minute: 0);
  DateTime? _originalCreatedAt;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final restriction = await ref
        .read(restrictionRepositoryProvider)
        .getByVehicleId(widget.vehicleId);
    if (!mounted) return;
    if (restriction != null) {
      _cityController.text = restriction.city ?? '';
      _notesController.text = restriction.notes ?? '';
      _enabled = restriction.enabled;
      _exempt = restriction.exempt;
      _days
        ..clear()
        ..addAll(restriction.days);
      _start = _parseTime(restriction.startTime);
      _end = _parseTime(restriction.endTime);
      _originalCreatedAt = restriction.createdAt;
    }
    setState(() {
      _loading = false;
      _dirty = false;
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool start}) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
      helpText: start ? 'Hora de inicio' : 'Hora de fin',
    );
    if (value == null) return;
    setState(() {
      if (start) {
        _start = value;
      } else {
        _end = value;
      }
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_enabled && _days.isEmpty) {
      AppSnackBar.error('Selecciona al menos un día de restricción');
      return;
    }
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    if (endMinutes <= startMinutes) {
      AppSnackBar.error('La hora de fin debe ser mayor que la de inicio');
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final restriction = VehicleRestriction(
      vehicleId: widget.vehicleId,
      enabled: _enabled,
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      days: _days.toList()..sort(),
      startTime: _formatTime(_start),
      endTime: _formatTime(_end),
      exempt: _exempt,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );

    try {
      await ref.read(restrictionsNotifierProvider.notifier).save(restriction);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      AppSnackBar.success('Pico y placa guardado');
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar pico y placa', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo guardar el pico y placa',
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
    final theme = Theme.of(context);
    final preview = evaluateRestriction(
      VehicleRestriction(
        vehicleId: widget.vehicleId,
        enabled: _enabled,
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        days: _days.toList(),
        startTime: _formatTime(_start),
        endTime: _formatTime(_end),
        exempt: _exempt,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DateTime.now(),
    );

    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Pico y placa')),
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
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Row(
                                  children: [
                                    Icon(
                                      preview.restrictedToday
                                          ? Icons.do_not_disturb_on_outlined
                                          : Icons.check_circle_outline,
                                      color: preview.restrictedToday
                                          ? theme.colorScheme.error
                                          : theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            preview.todayLabel,
                                            style: theme.textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            preview.nextLabel,
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (preview.restrictedToday)
                                      const StatusChip(
                                        status: AppStatus.danger,
                                        label: 'Hoy',
                                        icon: Icons.schedule,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Configuración',
                              icon: Icons.location_city_outlined,
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Activar pico y placa'),
                                    subtitle: const Text(
                                      'Muestra el aviso en el inicio',
                                    ),
                                    value: _enabled,
                                    onChanged: (value) => setState(() {
                                      _enabled = value;
                                      _dirty = true;
                                    }),
                                  ),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                      'Exento (eléctrico o híbrido)',
                                    ),
                                    subtitle: const Text(
                                      'No se mostrarán restricciones',
                                    ),
                                    value: _exempt,
                                    onChanged: (value) => setState(() {
                                      _exempt = value;
                                      _dirty = true;
                                    }),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextFormField(
                                    controller: _cityController,
                                    decoration: const InputDecoration(
                                      labelText: 'Ciudad',
                                      hintText: 'Ej: Bogotá',
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                      ),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.words,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Días de restricción',
                              icon: Icons.calendar_month_outlined,
                              child: Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  for (var day = 1; day <= 7; day++)
                                    FilterChip(
                                      label: Text(weekdayLabels[day]!),
                                      selected: _days.contains(day),
                                      onSelected: _exempt
                                          ? null
                                          : (selected) => setState(() {
                                              if (selected) {
                                                _days.add(day);
                                              } else {
                                                _days.remove(day);
                                              }
                                              _dirty = true;
                                            }),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Horario',
                              icon: Icons.schedule,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _exempt
                                          ? null
                                          : () => _pickTime(start: true),
                                      icon: const Icon(Icons.login),
                                      label: Text(
                                        'Desde ${_formatTime(_start)}',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _exempt
                                          ? null
                                          : () => _pickTime(start: false),
                                      icon: const Icon(Icons.logout),
                                      label: Text('Hasta ${_formatTime(_end)}'),
                                    ),
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
                                  hintText: 'Ej: verificar el decreto vigente',
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Las reglas de pico y placa cambian por ciudad '
                              'y por decreto. MotorCheck no consulta fuentes '
                              'oficiales: configura y verifica tus días.',
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
                              : const Text('Guardar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 6, minute: 0);
    }
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
