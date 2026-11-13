import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../core/files/file_storage.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/date_field.dart';
import '../../../shared/widgets/form_section.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../../vehicles/providers.dart';
import '../models/expense.dart';
import '../providers.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.vehicleId, this.expenseId});

  final int? vehicleId;
  final int? expenseId;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  int? _vehicleId;
  String _vehicleName = '';
  bool _isGlobal = false;
  String _categoryKey = 'other';
  DateTime _date = DateTime.now();
  String? _receiptPath;
  String? _originalReceiptPath;
  DateTime? _originalCreatedAt;
  bool _loading = false;
  bool _saving = false;
  bool _dirty = false;
  bool _saved = false;

  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _vehicleId = widget.vehicleId;
    _isGlobal = widget.vehicleId == null;
    if (_isEditing) {
      _loading = true;
      Future.microtask(_load);
    } else {
      Future.microtask(_loadVehicle);
    }
  }

  Future<void> _load() async {
    final expense = await ref
        .read(expenseRepositoryProvider)
        .getById(widget.expenseId!);
    if (!mounted) return;
    if (expense != null) {
      _amountController.text = expense.amount.toStringAsFixed(0);
      _notesController.text = expense.notes ?? '';
      _originalReceiptPath = expense.receiptPath;
      _originalCreatedAt = expense.createdAt;
      _vehicleId = expense.vehicleId;
      setState(() {
        _isGlobal = expense.vehicleId == null;
        _categoryKey = expense.categoryKey;
        _date = expense.date;
        _receiptPath = expense.receiptPath;
        _loading = false;
        _dirty = false;
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
    if (!mounted) return;
    setState(() => _vehicleName = vehicle?.name ?? '');
  }

  @override
  void dispose() {
    if (!_saved &&
        _receiptPath != null &&
        _receiptPath != _originalReceiptPath) {
      deleteAttachmentFile(_receiptPath);
    }
    _amountController.dispose();
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
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: 'Fecha del gasto',
    );
    if (date != null) {
      setState(() {
        _date = date;
        _dirty = true;
      });
    }
  }

  Future<void> _pickFile() async {
    final file = await pickAttachmentFile();
    if (file != null) await _setFile(file);
  }

  Future<void> _takePhoto() async {
    final file = await takeAttachmentPhoto();
    if (file != null) await _setFile(file);
  }

  Future<void> _setFile(XFile file) async {
    try {
      final path = await copyAttachmentFile(file);
      if (!mounted) return;
      final previous = _receiptPath;
      setState(() {
        _receiptPath = path;
        _dirty = true;
      });
      if (previous != null && previous != _originalReceiptPath) {
        await deleteAttachmentFile(previous);
      }
    } catch (error) {
      logError('adjuntar recibo', error, StackTrace.current);
      if (!mounted) return;
      AppSnackBar.error('No se pudo adjuntar el archivo');
    }
  }

  Future<void> _removeFile() async {
    final current = _receiptPath;
    setState(() {
      _receiptPath = null;
      _dirty = true;
    });
    if (current != null && current != _originalReceiptPath) {
      await deleteAttachmentFile(current);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isGlobal && _vehicleId == null) {
      AppSnackBar.error('Selecciona un vehículo o marca gasto global');
      return;
    }

    final amount = _parseAmount(_amountController.text) ?? 0;
    final now = DateTime.now();
    final expense = Expense(
      id: widget.expenseId,
      vehicleId: _isGlobal ? null : _vehicleId,
      categoryKey: _categoryKey,
      date: _date,
      amount: amount,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      receiptPath: _receiptPath,
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );

    setState(() => _saving = true);
    try {
      await ref.read(expensesNotifierProvider.notifier).save(expense);
      _saved = true;
      if (_originalReceiptPath != null &&
          _originalReceiptPath != _receiptPath) {
        await deleteAttachmentFile(_originalReceiptPath);
      }
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      AppSnackBar.success(
        _isEditing ? 'Gasto actualizado' : 'Gasto registrado',
      );
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar gasto', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo guardar el gasto'),
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
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final theme = Theme.of(context);
    final canUseCamera = Platform.isAndroid || Platform.isIOS;

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
              Text(_isEditing ? 'Editar gasto' : 'Nuevo gasto'),
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
            : categoriesAsync.when(
                loading: () => const LoadingIndicator(),
                error: (error, _) => Center(
                  child: Text(
                    'No se pudieron cargar las categorías',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                data: (categories) {
                  return Form(
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
                                  title: 'Gasto',
                                  icon: Icons.receipt_long_outlined,
                                  child: Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        initialValue:
                                            categories.any(
                                              (category) =>
                                                  category.key == _categoryKey,
                                            )
                                            ? _categoryKey
                                            : categories.isNotEmpty
                                            ? categories.first.key
                                            : null,
                                        decoration: const InputDecoration(
                                          labelText: 'Categoría *',
                                          prefixIcon: Icon(
                                            Icons.category_outlined,
                                          ),
                                        ),
                                        items: categories
                                            .map(
                                              (category) => DropdownMenuItem(
                                                value: category.key,
                                                child: Text(category.name),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value == null) return;
                                          setState(() {
                                            _categoryKey = value;
                                            _dirty = true;
                                          });
                                        },
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
                                        controller: _amountController,
                                        decoration: const InputDecoration(
                                          labelText: 'Valor *',
                                          hintText: 'Ej: 180000',
                                          prefixIcon: Icon(Icons.attach_money),
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
                                        validator: (value) {
                                          final amount = _parseAmount(
                                            value ?? '',
                                          );
                                          if (amount == null || amount <= 0) {
                                            return 'Ingresa un valor válido';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      SwitchListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text(
                                          'Gasto global (sin vehículo)',
                                        ),
                                        subtitle: const Text(
                                          'Útil para gastos compartidos o generales',
                                        ),
                                        value: _isGlobal,
                                        onChanged: (value) => setState(() {
                                          _isGlobal = value;
                                          _dirty = true;
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                FormSection(
                                  title: 'Recibo',
                                  icon: Icons.attach_file,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_receiptPath != null)
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: const Icon(
                                            Icons.insert_drive_file_outlined,
                                          ),
                                          title: Text(
                                            p.basename(_receiptPath!),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: IconButton(
                                            tooltip: 'Quitar recibo',
                                            icon: const Icon(Icons.close),
                                            onPressed: _removeFile,
                                          ),
                                        ),
                                      Wrap(
                                        spacing: AppSpacing.sm,
                                        runSpacing: AppSpacing.sm,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: _pickFile,
                                            icon: const Icon(
                                              Icons.upload_file_outlined,
                                            ),
                                            label: Text(
                                              _receiptPath == null
                                                  ? 'Elegir archivo'
                                                  : 'Cambiar archivo',
                                            ),
                                          ),
                                          if (canUseCamera)
                                            OutlinedButton.icon(
                                              onPressed: _takePhoto,
                                              icon: const Icon(
                                                Icons.photo_camera_outlined,
                                              ),
                                              label: const Text('Tomar foto'),
                                            ),
                                        ],
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
                                          : 'Guardar gasto',
                                    ),
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
