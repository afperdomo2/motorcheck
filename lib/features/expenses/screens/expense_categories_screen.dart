import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../expense_icons.dart';
import '../models/expense_category.dart';
import '../providers.dart';
import '../repository.dart';

class ExpenseCategoriesScreen extends ConsumerWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías de gasto')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudieron cargar las categorías',
          onRetry: () => ref.invalidate(expenseCategoriesProvider),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Sin categorías de gasto'));
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final category in categories)
                Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        expenseIconFor(category.iconName),
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(category.name),
                    subtitle: Text('Orden ${category.sortOrder}'),
                    trailing: PopupMenuButton<_CategoryAction>(
                      tooltip: 'Opciones',
                      onSelected: (action) {
                        switch (action) {
                          case _CategoryAction.edit:
                            _openDialog(context, ref, category: category);
                          case _CategoryAction.delete:
                            _delete(context, ref, category);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: _CategoryAction.edit,
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: _CategoryAction.delete,
                          child: Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openDialog(
    BuildContext context,
    WidgetRef ref, {
    ExpenseCategory? category,
  }) async {
    final draft = await showDialog<_CategoryDraft>(
      context: context,
      builder: (context) => _CategoryDialog(existing: category),
    );
    if (draft == null || draft.name.trim().isEmpty) return;

    final categories = ref.read(expenseCategoriesProvider).valueOrNull ?? [];
    final now = DateTime.now();
    final key = category?.key ?? _uniqueKey(draft.name, categories);
    final value = ExpenseCategory(
      id: category?.id,
      key: key,
      name: draft.name.trim(),
      iconName: draft.iconName,
      sortOrder: category?.sortOrder ?? categories.length + 1,
      createdAt: category?.createdAt ?? now,
    );

    try {
      await ref.read(expenseCategoriesNotifierProvider.notifier).save(value);
      if (!context.mounted) return;
      AppSnackBar.success(
        category == null ? 'Categoría creada' : 'Categoría actualizada',
      );
    } on ExpenseCategoryKeyExistsException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.error(error.toString());
    } catch (error) {
      logError('guardar categoría de gasto', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error('No se pudo guardar la categoría');
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ExpenseCategory category,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar categoría',
      message: '¿Eliminar "${category.name}"?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(expenseCategoriesNotifierProvider.notifier)
          .remove(category.id!);
      if (!context.mounted) return;
      AppSnackBar.success('Categoría eliminada');
    } on ExpenseCategoryInUseException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.error(error.toString());
    } catch (error) {
      logError('eliminar categoría de gasto', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error('No se pudo eliminar la categoría');
    }
  }

  String _uniqueKey(String name, List<ExpenseCategory> categories) {
    final base = _slugify(name);
    final existing = categories.map((category) => category.key).toSet();
    if (!existing.contains(base)) return base;
    var index = 2;
    while (existing.contains('${base}_$index')) {
      index++;
    }
    return '${base}_$index';
  }

  String _slugify(String text) {
    final slug = text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'ñ'), 'n')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return slug.isEmpty ? 'other' : slug;
  }
}

class _CategoryDraft {
  const _CategoryDraft({required this.name, required this.iconName});

  final String name;
  final String iconName;
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.existing});

  final ExpenseCategory? existing;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _nameController;
  late String _iconName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _iconName = widget.existing?.iconName ?? 'receipt_long';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Nueva categoría' : 'Editar categoría',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ej: Seguro todo riesgo',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _iconName,
            decoration: const InputDecoration(labelText: 'Ícono'),
            items: expenseIconNames
                .map(
                  (name) => DropdownMenuItem(
                    value: name,
                    child: Row(
                      children: [
                        Icon(expenseIconFor(name), size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(expenseIconLabel(name)),
                      ],
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _iconName = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            _CategoryDraft(name: _nameController.text, iconName: _iconName),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

enum _CategoryAction { edit, delete }
