import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/date_field.dart';
import '../../../shared/widgets/form_section.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../file_storage.dart';
import '../models/vehicle_document.dart';
import '../providers.dart';

class DocumentFormScreen extends ConsumerStatefulWidget {
  const DocumentFormScreen({
    super.key,
    this.vehicleId,
    this.documentId,
    this.renewFromId,
  });

  final int? vehicleId;
  final int? documentId;
  final int? renewFromId;

  @override
  ConsumerState<DocumentFormScreen> createState() => _DocumentFormScreenState();
}

class _DocumentFormScreenState extends ConsumerState<DocumentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'soat';
  DateTime? _issuedAt;
  DateTime? _expiresAt;
  String? _filePath;
  String? _originalFilePath;
  DateTime? _originalCreatedAt;
  int? _vehicleId;
  bool _loading = false;
  bool _saving = false;
  bool _dirty = false;
  bool _saved = false;

  bool get _isEditing => widget.documentId != null;
  bool get _isRenewing => widget.renewFromId != null;

  @override
  void initState() {
    super.initState();
    _vehicleId = widget.vehicleId;
    if (widget.vehicleId == null) {
      _type = 'license';
    }
    if (_isRenewing) {
      _loading = true;
      Future.microtask(_loadRenewSource);
    } else if (_isEditing) {
      _loading = true;
      Future.microtask(_loadDocument);
    }
  }

  Future<void> _loadDocument() async {
    final document = await ref
        .read(documentsRepositoryProvider)
        .getById(widget.documentId!);
    if (!mounted) return;
    if (document == null) {
      setState(() => _loading = false);
      return;
    }
    _nameController.text = document.name ?? '';
    _numberController.text = document.number ?? '';
    _notesController.text = document.notes ?? '';
    _originalFilePath = document.filePath;
    _originalCreatedAt = document.createdAt;
    setState(() {
      _type = document.type;
      _vehicleId = document.vehicleId;
      _issuedAt = document.issuedAt;
      _expiresAt = document.expiresAt;
      _filePath = document.filePath;
      _loading = false;
      _dirty = false;
    });
  }

  @override
  void dispose() {
    if (!_saved && _filePath != null && _filePath != _originalFilePath) {
      deleteDocumentFile(_filePath);
    }
    _nameController.dispose();
    _numberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRenewSource() async {
    final source = await ref
        .read(documentsRepositoryProvider)
        .getById(widget.renewFromId!);
    if (!mounted) return;
    if (source == null) {
      setState(() => _loading = false);
      return;
    }
    _nameController.text = source.name ?? '';
    _numberController.text = source.number ?? '';
    _notesController.text = source.notes ?? '';
    setState(() {
      _type = source.type;
      _vehicleId = widget.vehicleId ?? source.vehicleId;
      _issuedAt = DateTime.now();
      _expiresAt = null;
      _filePath = null;
      _originalFilePath = null;
      _originalCreatedAt = null;
      _loading = false;
      _dirty = false;
    });
  }

  Future<void> _pickFile() async {
    final file = await pickDocumentFile();
    if (file != null) await _setFile(file);
  }

  Future<void> _takePhoto() async {
    final file = await takeDocumentPhoto();
    if (file != null) await _setFile(file);
  }

  Future<void> _setFile(XFile file) async {
    try {
      final path = await copyDocumentFile(file);
      if (!mounted) return;
      final previous = _filePath;
      setState(() {
        _filePath = path;
        _dirty = true;
      });
      if (previous != null && previous != _originalFilePath) {
        await deleteDocumentFile(previous);
      }
    } catch (error) {
      logError('adjuntar documento', error, StackTrace.current);
      if (!mounted) return;
      AppSnackBar.error('No se pudo adjuntar el archivo');
    }
  }

  Future<void> _removeFile() async {
    final current = _filePath;
    setState(() {
      _filePath = null;
      _dirty = true;
    });
    if (current != null && current != _originalFilePath) {
      await deleteDocumentFile(current);
    }
  }

  Future<void> _pickIssuedDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _issuedAt ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Fecha de emisión',
    );
    if (date != null) {
      setState(() {
        _issuedAt = date;
        _dirty = true;
      });
    }
  }

  Future<void> _pickExpiresDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(1990),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
      helpText: 'Fecha de vencimiento',
    );
    if (date != null) {
      setState(() {
        _expiresAt = date;
        _dirty = true;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiresAt == null) {
      AppSnackBar.error('Selecciona la fecha de vencimiento');
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final type = documentTypeFor(_type);
    final name = _nameController.text.trim().isEmpty
        ? type.label
        : _nameController.text.trim();

    final document = VehicleDocument(
      id: widget.documentId,
      vehicleId: _vehicleId,
      type: _type,
      name: name,
      number: _numberController.text.trim().isEmpty
          ? null
          : _numberController.text.trim(),
      issuedAt: _issuedAt,
      expiresAt: _expiresAt!,
      filePath: _filePath,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: _originalCreatedAt ?? now,
      updatedAt: now,
    );

    try {
      await ref.read(documentsNotifierProvider.notifier).save(document);
      _saved = true;
      if (_originalFilePath != null && _originalFilePath != _filePath) {
        await deleteDocumentFile(_originalFilePath);
      }
      if (!mounted) return;
      setState(() {
        _saving = false;
        _dirty = false;
      });
      AppSnackBar.success(
        _isEditing
            ? 'Documento actualizado'
            : _isRenewing
            ? 'Documento renovado'
            : 'Documento agregado',
      );
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar documento', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo guardar el documento',
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
    final canUseCamera = Platform.isAndroid || Platform.isIOS;

    return PopScope(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing
                ? 'Editar documento'
                : _isRenewing
                ? 'Renovar documento'
                : 'Nuevo documento',
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
                              title: 'Documento',
                              icon: Icons.description_outlined,
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    initialValue: _type,
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo *',
                                      prefixIcon: Icon(Icons.category_outlined),
                                    ),
                                    items: documentTypeOptions
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
                                        _type = value;
                                        _dirty = true;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre (opcional)',
                                      hintText: 'Ej: SOAT 2026',
                                      prefixIcon: Icon(Icons.label_outline),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  TextFormField(
                                    controller: _numberController,
                                    decoration: const InputDecoration(
                                      labelText: 'Número o póliza',
                                      hintText: 'Ej: 123456789',
                                      prefixIcon: Icon(Icons.numbers),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Fechas',
                              icon: Icons.event_outlined,
                              child: Column(
                                children: [
                                  DateField(
                                    label: 'Emisión',
                                    value: _issuedAt,
                                    onTap: _pickIssuedDate,
                                    onClear: () => setState(() {
                                      _issuedAt = null;
                                      _dirty = true;
                                    }),
                                    prefixIcon: Icons.calendar_today,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  DateField(
                                    label: 'Vencimiento *',
                                    value: _expiresAt,
                                    onTap: _pickExpiresDate,
                                    onClear: () => setState(() {
                                      _expiresAt = null;
                                      _dirty = true;
                                    }),
                                    prefixIcon: Icons.event_available,
                                  ),
                                  if (_expiresAt == null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.xs,
                                      ),
                                      child: Text(
                                        'Selecciona la fecha de vencimiento',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.error,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            FormSection(
                              title: 'Adjunto',
                              icon: Icons.attach_file,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_filePath != null)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.insert_drive_file_outlined,
                                      ),
                                      title: Text(
                                        p.basename(_filePath!),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: IconButton(
                                        tooltip: 'Quitar adjunto',
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
                                          _filePath == null
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
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'PDF o imagen. Se guarda en este '
                                    'dispositivo.',
                                    style: theme.textTheme.bodySmall,
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
                                minLines: 3,
                                maxLines: 5,
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
                                      : 'Guardar documento',
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
