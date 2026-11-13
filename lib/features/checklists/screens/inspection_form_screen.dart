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
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../../vehicles/providers.dart';
import '../models/inspection_answer.dart';
import '../models/inspection_run.dart';
import '../providers.dart';

class InspectionFormScreen extends ConsumerStatefulWidget {
  const InspectionFormScreen({
    super.key,
    required this.vehicleId,
    required this.checklistId,
  });

  final int vehicleId;
  final int checklistId;

  @override
  ConsumerState<InspectionFormScreen> createState() =>
      _InspectionFormScreenState();
}

class _InspectionFormScreenState extends ConsumerState<InspectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _odometerController = TextEditingController();
  final Map<int, String> _statuses = {};
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _dirty = false;
  bool _loadedVehicle = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadVehicle);
  }

  Future<void> _loadVehicle() async {
    final vehicle = await ref.read(
      selectedVehicleProvider(widget.vehicleId).future,
    );
    if (!mounted || _loadedVehicle) return;
    _odometerController.text = vehicle?.currentMileage?.toString() ?? '';
    setState(() => _loadedVehicle = true);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Fecha de la inspección',
    );
    if (date != null) {
      setState(() {
        _date = date;
        _dirty = true;
      });
    }
  }

  Future<void> _save(List<int> itemIds) async {
    if (!_formKey.currentState!.validate()) return;
    if (itemIds.isEmpty) {
      AppSnackBar.error('El checklist no tiene items');
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final run = InspectionRun(
      vehicleId: widget.vehicleId,
      checklistId: widget.checklistId,
      date: _date,
      odometer: int.tryParse(_odometerController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: now,
    );
    final answers = [
      for (final itemId in itemIds)
        InspectionAnswer(
          runId: 0,
          itemId: itemId,
          status: _statuses[itemId] ?? 'ok',
        ),
    ];

    try {
      await ref
          .read(inspectionsNotifierProvider.notifier)
          .save(widget.vehicleId, run, answers);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      AppSnackBar.success('Inspección guardada');
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar inspección', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo guardar la inspección',
        ),
      );
    }
  }

  Future<void> _confirmDiscard() async {
    final leave = await showConfirmDialog(
      context,
      title: 'Descartar inspección',
      message: '¿Salir sin guardar la inspección?',
      confirmLabel: 'Descartar',
      cancelLabel: 'Seguir',
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
    final itemsAsync = ref.watch(checklistItemsProvider(widget.checklistId));
    final checklistAsync = ref.watch(checklistByIdProvider(widget.checklistId));
    final theme = Theme.of(context);
    final checklistName = checklistAsync.valueOrNull?.name;

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
              const Text('Inspección'),
              if (checklistName != null)
                Text(
                  checklistName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        body: itemsAsync.when(
          loading: () => const LoadingIndicator(),
          error: (error, _) => Center(
            child: Text(
              'No se pudo cargar el checklist',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          data: (items) {
            return Form(
              key: _formKey,
              onChanged: () {
                if (!_dirty) setState(() => _dirty = true);
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        FormSection(
                          title: 'Checklist',
                          icon: Icons.checklist_outlined,
                          child: Column(
                            children: [
                              for (final item in items) ...[
                                _ChecklistItemRow(
                                  label: item.label,
                                  status: _statuses[item.id] ?? 'ok',
                                  onChanged: (status) => setState(() {
                                    _statuses[item.id!] = status;
                                    _dirty = true;
                                  }),
                                ),
                                if (item != items.last) const Divider(),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FormSection(
                          title: 'Datos de la inspección',
                          icon: Icons.assignment_outlined,
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
                                  labelText: 'Kilometraje',
                                  prefixIcon: const Icon(Icons.speed),
                                  suffixText: 'km',
                                  helperText: _loadedVehicle
                                      ? null
                                      : 'Cargando…',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null;
                                  }
                                  final km = int.tryParse(value.trim());
                                  if (km == null || km < 0) {
                                    return 'Ingresa un kilometraje válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TextFormField(
                                controller: _notesController,
                                minLines: 2,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: 'Notas',
                                  hintText: 'Observaciones de la inspección',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                  StickyBottomBar(
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving
                            ? null
                            : () =>
                                  _save(items.map((item) => item.id!).toList()),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Guardar inspección'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChecklistItemRow extends StatelessWidget {
  const _ChecklistItemRow({
    required this.label,
    required this.status,
    required this.onChanged,
  });

  final String label;
  final String status;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _StatusChip(
                label: 'OK',
                selected: status == 'ok',
                color: theme.colorScheme.primaryContainer,
                textColor: theme.colorScheme.onPrimaryContainer,
                onTap: () => onChanged('ok'),
              ),
              _StatusChip(
                label: 'Revisar',
                selected: status == 'attention',
                color: theme.colorScheme.tertiaryContainer,
                textColor: theme.colorScheme.onTertiaryContainer,
                onTap: () => onChanged('attention'),
              ),
              _StatusChip(
                label: 'Falla',
                selected: status == 'fail',
                color: theme.colorScheme.errorContainer,
                textColor: theme.colorScheme.onErrorContainer,
                onTap: () => onChanged('fail'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? textColor : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? Colors.transparent : theme.colorScheme.outlineVariant,
      ),
    );
  }
}
