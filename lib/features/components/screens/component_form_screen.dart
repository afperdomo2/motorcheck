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
import '../models/vehicle_component.dart';
import '../providers.dart';

class ComponentFormScreen extends ConsumerStatefulWidget {
  const ComponentFormScreen({
    super.key,
    required this.vehicleId,
    this.componentId,
    this.spare = false,
  });

  final int vehicleId;
  final int? componentId;
  final bool spare;

  @override
  ConsumerState<ComponentFormScreen> createState() =>
      _ComponentFormScreenState();
}

class _ComponentFormScreenState extends ConsumerState<ComponentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _installedKmController = TextEditingController();
  final _intervalKmController = TextEditingController();
  final _warningKmController = TextEditingController();
  final _intervalMonthsController = TextEditingController();
  final _warningDaysController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'tire';
  DateTime _installedAt = DateTime.now();
  bool _active = true;
  bool _isSystem = false;
  String? _categoryKey;
  bool _loading = false;
  bool _saving = false;
  bool _dirty = false;
  DateTime? _createdAt;

  bool get _isEditing => widget.componentId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loading = true;
      Future.microtask(_load);
    } else if (widget.spare) {
      _type = 'tire';
      _nameController.text = 'Llanta de repuesto';
      _positionController.text = 'Repuesto';
      _intervalMonthsController.text = '72';
      _warningDaysController.text = '45';
    }
  }

  Future<void> _load() async {
    final component = await ref.read(
      componentByIdProvider(widget.componentId!).future,
    );
    if (!mounted) return;
    if (component == null) {
      setState(() => _loading = false);
      return;
    }
    _nameController.text = component.name;
    _positionController.text = component.position ?? '';
    _installedKmController.text = component.installedKm?.toString() ?? '';
    _intervalKmController.text = component.intervalKm?.toString() ?? '';
    _warningKmController.text = component.warningKm?.toString() ?? '';
    _intervalMonthsController.text = component.intervalMonths?.toString() ?? '';
    _warningDaysController.text = component.warningDays?.toString() ?? '';
    _notesController.text = component.notes ?? '';
    setState(() {
      _type = component.type;
      _isSystem = component.isSystem;
      _categoryKey = component.categoryKey;
      _installedAt = component.installedAt;
      _active = component.active;
      _createdAt = component.createdAt;
      _loading = false;
      _dirty = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _installedKmController.dispose();
    _intervalKmController.dispose();
    _warningKmController.dispose();
    _intervalMonthsController.dispose();
    _warningDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int? _toInt(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  Future<void> _pickInstalledAt() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _installedAt,
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Fecha de instalación',
    );
    if (date != null) {
      setState(() {
        _installedAt = date;
        _dirty = true;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final component = VehicleComponent(
      id: widget.componentId,
      vehicleId: widget.vehicleId,
      name: _nameController.text.trim(),
      type: _type,
      position: _positionController.text.trim().isEmpty
          ? null
          : _positionController.text.trim(),
      installedAt: _installedAt,
      installedKm: _toInt(_installedKmController),
      intervalKm: _toInt(_intervalKmController),
      intervalMonths: _toInt(_intervalMonthsController),
      warningKm: _toInt(_warningKmController),
      warningDays: _toInt(_warningDaysController),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      active: _active,
      isSystem: _isSystem,
      categoryKey: _isSystem ? _categoryKey : null,
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    try {
      await ref.read(componentsNotifierProvider.notifier).save(component);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      AppSnackBar.success(
        _isEditing ? 'Componente actualizado' : 'Componente agregado',
      );
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar componente', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo guardar el componente',
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
    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar componente' : 'Nuevo componente'),
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
                              title: 'Componente',
                              icon: Icons.tire_repair,
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    initialValue: _type,
                                    decoration: InputDecoration(
                                      labelText: 'Tipo *',
                                      prefixIcon: const Icon(
                                        Icons.category_outlined,
                                      ),
                                      helperText: _isSystem
                                          ? 'El tipo de un componente de '
                                                'plantilla no se cambia.'
                                          : null,
                                    ),
                                    disabledHint: Text(
                                      componentTypeFor(_type).label,
                                    ),
                                    items: componentTypeOptions
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
                                    onChanged: _isSystem
                                        ? null
                                        : (value) {
                                            if (value == null) return;
                                            setState(() {
                                              _type = value;
                                              _dirty = true;
                                            });
                                          },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre *',
                                      hintText: 'Ej: Llanta delantera',
                                      prefixIcon: Icon(Icons.label_outline),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Escribe un nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _positionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Posición (opcional)',
                                      hintText: 'Ej: Eje 2 izquierda exterior',
                                      prefixIcon: Icon(Icons.place_outlined),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Instalación',
                              icon: Icons.event_outlined,
                              child: Column(
                                children: [
                                  DateField(
                                    label: 'Fecha de instalación *',
                                    value: _installedAt,
                                    onTap: _pickInstalledAt,
                                    prefixIcon: Icons.calendar_today,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _installedKmController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Kilometraje al instalar',
                                      hintText: 'Ej: 152300',
                                      suffixText: 'km',
                                      prefixIcon: Icon(Icons.speed_outlined),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Frecuencia',
                              icon: Icons.repeat_outlined,
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _intervalKmController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Cada',
                                            suffixText: 'km',
                                            prefixIcon: Icon(Icons.straighten),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _warningKmController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Aviso',
                                            suffixText: 'km antes',
                                            prefixIcon: Icon(
                                              Icons.notifications_outlined,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _intervalMonthsController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Cada',
                                            suffixText: 'meses',
                                            prefixIcon: Icon(
                                              Icons.event_repeat_outlined,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _warningDaysController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Aviso',
                                            suffixText: 'días antes',
                                            prefixIcon: Icon(
                                              Icons.alarm_outlined,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Puedes usar solo kilometraje, solo meses '
                                    'o ambos. Si usas ambos, el estado se '
                                    'calcula con lo que ocurra primero.',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Notas y estado',
                              icon: Icons.notes_outlined,
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Componente activo'),
                                    subtitle: const Text(
                                      'Si lo desactivas, deja de generar '
                                      'recordatorios.',
                                    ),
                                    value: _active,
                                    onChanged: (value) => setState(() {
                                      _active = value;
                                      _dirty = true;
                                    }),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  TextFormField(
                                    controller: _notesController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Notas (opcional)',
                                      hintText: 'Marca, referencia o detalles',
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isEditing ? 'Guardar cambios' : 'Guardar componente',
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
