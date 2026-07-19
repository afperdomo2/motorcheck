import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    final location = _locationController.text.trim().isEmpty
        ? null
        : _locationController.text.trim();

    final notifier = ref.read(workshopsNotifierProvider.notifier);

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

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar taller' : 'Nuevo taller'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ej: Taller Juan, Concesionario Toyota',
                  prefixIcon: Icon(Icons.handyman),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad / Ubicación',
                  hintText: 'Ej: Bogotá, Zona Norte',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: ElevatedButton(
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
            ],
          ),
        ),
      ),
    );
  }
}
