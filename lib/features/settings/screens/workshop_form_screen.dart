import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/form_section.dart';
import '../../../shared/widgets/sticky_bottom_bar.dart';
import '../../maintenance/models/workshop.dart';
import '../providers.dart';

class WorkshopFormScreen extends ConsumerStatefulWidget {
  final int? workshopId;

  const WorkshopFormScreen({super.key, this.workshopId});

  @override
  ConsumerState<WorkshopFormScreen> createState() => _WorkshopFormScreenState();
}

class _WorkshopFormScreenState extends ConsumerState<WorkshopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  bool _isLoading = false;
  bool _dirty = false;

  bool get _isEditing => widget.workshopId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _locationController = TextEditingController();

    if (_isEditing) {
      Future.microtask(() => _loadWorkshop());
    }
  }

  Future<void> _loadWorkshop() async {
    final workshop = await ref
        .read(workshopRepositoryProvider)
        .getById(widget.workshopId!);
    if (workshop != null && mounted) {
      _nameController.text = workshop.name;
      _locationController.text = workshop.location ?? '';
      setState(() => _dirty = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final location = _locationController.text.trim().isEmpty
        ? null
        : _locationController.text.trim();

    final notifier = ref.read(workshopsNotifierProvider.notifier);

    try {
      if (_isEditing) {
        final workshop = Workshop(
          id: widget.workshopId,
          name: name,
          location: location,
          createdAt: DateTime.now(),
        );
        await notifier.update(workshop);
      } else {
        await notifier.add(name, location: location);
      }

      ref.invalidate(workshopsListProvider);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _dirty = false;
      });
      AppSnackBar.success(_isEditing ? 'Taller actualizado' : 'Taller creado');
      await Future<void>.delayed(Duration.zero);
      if (mounted) context.pop();
    } catch (error) {
      logError('guardar taller', error, StackTrace.current);
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo guardar el taller'),
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
      canPop: !_dirty && !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar taller' : 'Nuevo taller'),
        ),
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
                      FormSection(
                        title: 'Datos del taller',
                        icon: Icons.storefront_outlined,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: 'Nombre *',
                                hintText:
                                    'Ej: Taller Juan, Concesionario Toyota',
                                prefixIcon: Icon(Icons.handyman),
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
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Ciudad / Ubicación',
                                hintText: 'Ej: Bogotá, Zona Norte',
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ],
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
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Guardar' : 'Crear taller'),
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
