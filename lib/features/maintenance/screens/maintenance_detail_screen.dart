import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import '../../../core/files/file_storage.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/category_history_sheet.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../settings/models/maintenance_category.dart';
import '../../settings/providers.dart';
import '../../vehicles/models/vehicle.dart';
import '../categories.dart';
import '../models/maintenance.dart';
import '../models/maintenance_attachment.dart';
import '../models/maintenance_item.dart';
import '../models/workshop.dart';
import '../providers.dart';

class MaintenanceDetailScreen extends ConsumerWidget {
  final int maintenanceId;

  const MaintenanceDetailScreen({super.key, required this.maintenanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(maintenanceByIdProvider(maintenanceId));
    final itemsAsync = ref.watch(maintenanceItemsProvider(maintenanceId));
    final workshopsAsync = ref.watch(workshopsProvider);
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);
    final vehicleMap = ref.watch(vehicleNamesProvider).valueOrNull ?? {};
    final categoryMap = <String, MaintenanceCategory>{
      for (final c
          in (categoriesAsync.valueOrNull ?? []).cast<MaintenanceCategory>())
        c.key: c,
    };

    final maintenance = maintenanceAsync.valueOrNull;
    final title = maintenance != null
        ? formatDisplayDate(maintenance.date)
        : 'Detalle';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<_MaintenanceAction>(
            tooltip: 'Opciones',
            onSelected: (action) {
              switch (action) {
                case _MaintenanceAction.edit:
                  context.pushReplacement('/maintenance/$maintenanceId/edit');
                case _MaintenanceAction.delete:
                  _deleteMaintenance(context, ref, maintenanceId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _MaintenanceAction.edit,
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: AppSpacing.md),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _MaintenanceAction.delete,
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: maintenanceAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, _) => ErrorState(
          message: 'No se pudo cargar el mantenimiento',
          onRetry: () => ref.invalidate(maintenanceByIdProvider(maintenanceId)),
        ),
        data: (maintenance) {
          if (maintenance == null) {
            return const ErrorState(message: 'Mantenimiento no encontrado');
          }

          return itemsAsync.when(
            loading: () => const LoadingIndicator(),
            error: (err, _) => ErrorState(
              message: 'No se pudieron cargar los ítems',
              onRetry: () =>
                  ref.invalidate(maintenanceItemsProvider(maintenanceId)),
            ),
            data: (items) {
              final workshops = workshopsAsync.valueOrNull ?? [];
              final workshop = _findWorkshop(workshops, maintenance.workshopId);
              final vehicle = vehicleMap[maintenance.vehicleId];

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _InfoCard(
                    maintenance: maintenance,
                    vehicle: vehicle,
                    workshop: workshop,
                  ),
                  if (maintenance.maintenanceCost > 0 ||
                      maintenance.totalPartsCost > 0) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _CostCard(maintenance: maintenance),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _ItemsCard(
                    items: items,
                    categoryMap: categoryMap,
                    onItemTap: (item) => _openCategoryHistory(
                      context,
                      ref,
                      maintenance,
                      item,
                      categoryMap[item.category],
                      vehicle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _AttachmentsCard(maintenanceId: maintenanceId),
                  if (maintenance.notes != null &&
                      maintenance.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _NotesCard(notes: maintenance.notes!),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Workshop? _findWorkshop(List<Workshop> workshops, int? workshopId) {
    if (workshopId == null) return null;
    for (final w in workshops) {
      if (w.id == workshopId) return w;
    }
    return null;
  }

  void _openCategoryHistory(
    BuildContext context,
    WidgetRef ref,
    Maintenance maintenance,
    MaintenanceItem item,
    MaintenanceCategory? category,
    Vehicle? vehicle,
  ) {
    if (vehicle == null || vehicle.id == null) return;
    final cat =
        category ??
        MaintenanceCategory(
          key: item.category,
          name: item.category,
          vehicleType: vehicle.type,
          createdAt: maintenance.createdAt,
        );
    ref.invalidate(upcomingMaintenanceProvider(vehicle.id!));
    ref.invalidate(
      maintenanceCategoryHistoryProvider((
        vehicleId: vehicle.id!,
        category: item.category,
      )),
    );
    CategoryHistorySheet.show(context, vehicle: vehicle, category: cat);
  }

  Future<void> _deleteMaintenance(
    BuildContext context,
    WidgetRef ref,
    int maintenanceId,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar mantenimiento',
      message:
          '¿Estás seguro de eliminar este mantenimiento y todos sus ítems?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(maintenancesNotifierProvider.notifier)
          .remove(maintenanceId);
      if (context.mounted) {
        AppSnackBar.success('Mantenimiento eliminado');
        context.pop();
      }
    } catch (error) {
      logError('eliminar mantenimiento', error, StackTrace.current);
      if (context.mounted) {
        AppSnackBar.error(
          friendlyErrorMessage(
            error,
            fallback: 'No se pudo eliminar el mantenimiento',
          ),
        );
      }
    }
  }
}

enum _MaintenanceAction { edit, delete }

class _InfoCard extends StatelessWidget {
  final Maintenance maintenance;
  final dynamic vehicle;
  final Workshop? workshop;

  const _InfoCard({
    required this.maintenance,
    required this.vehicle,
    this.workshop,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleName = vehicle?.name ?? 'Vehículo';
    final vehicleType = vehicle?.type as String? ?? 'other';
    final typeColor = AppSemanticColors.of(context).vehicleColor(vehicleType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                VehicleAvatar(type: vehicleType, size: 40),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        vehicleTypeLabel(vehicleType),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: typeColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Fecha',
              value: formatDisplayDate(maintenance.date),
            ),
            if (maintenance.mileage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.speed,
                label: 'Kilometraje',
                value: formatMileage(maintenance.mileage),
              ),
            ],
            if (workshop != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.handyman,
                label: 'Taller',
                value:
                    workshop!.location != null && workshop!.location!.isNotEmpty
                    ? '${workshop!.name} · ${workshop!.location}'
                    : workshop!.name,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final Maintenance maintenance;

  const _CostCard({required this.maintenance});

  @override
  Widget build(BuildContext context) {
    final total = maintenance.maintenanceCost + maintenance.totalPartsCost;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              formatCurrency(total),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text('Total', style: theme.textTheme.labelSmall),
            if (maintenance.maintenanceCost > 0) ...[
              const Divider(height: AppSpacing.xl),
              Row(
                children: [
                  const Icon(Icons.construction, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Mano de obra', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Text(
                    formatCurrency(maintenance.maintenanceCost),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
            if (maintenance.totalPartsCost > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.inventory_2, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Repuestos', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Text(
                    formatCurrency(maintenance.totalPartsCost),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final List<MaintenanceItem> items;
  final Map<String, MaintenanceCategory> categoryMap;
  final void Function(MaintenanceItem item) onItemTap;

  const _ItemsCard({
    required this.items,
    this.categoryMap = const {},
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalParts = items.fold<double>(0, (s, i) => s + i.partsCost);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Ítems (${items.length})',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                if (totalParts > 0)
                  Text(
                    formatCurrency(totalParts),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (items.isEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sin ítems registrados',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const Divider(height: 20),
              ...items.map(
                (item) => _ItemTile(
                  item: item,
                  categoryMap: categoryMap,
                  onTap: () => onItemTap(item),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final MaintenanceItem item;
  final Map<String, MaintenanceCategory> categoryMap;
  final VoidCallback onTap;

  const _ItemTile({
    required this.item,
    this.categoryMap = const {},
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasNote = item.notes != null && item.notes!.isNotEmpty;
    final cat = categoryMap[item.category];
    final icon = cat != null
        ? MaintenanceCategories.iconByName(cat.iconName)
        : Icons.build;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            crossAxisAlignment: hasNote
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat?.name ?? item.category,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (hasNote)
                      Text(
                        item.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (item.partsCost > 0)
                Text(
                  formatCurrency(item.partsCost),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentsCard extends ConsumerWidget {
  const _AttachmentsCard({required this.maintenanceId});

  final int maintenanceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachmentsAsync = ref.watch(
      maintenanceAttachmentsProvider(maintenanceId),
    );
    final theme = Theme.of(context);
    final canUseCamera = Platform.isAndroid || Platform.isIOS;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Adjuntos', style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            attachmentsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(
                'No se pudieron cargar los adjuntos',
                style: theme.textTheme.bodySmall,
              ),
              data: (attachments) {
                if (attachments.isEmpty) {
                  return Text(
                    'Sin facturas ni fotos adjuntas.',
                    style: theme.textTheme.bodySmall,
                  );
                }
                return Column(
                  children: [
                    for (final attachment in attachments)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(
                          _attachmentIcon(attachment.name),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          attachment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(formatDisplayDate(attachment.createdAt)),
                        trailing: IconButton(
                          tooltip: 'Eliminar adjunto',
                          icon: const Icon(Icons.close),
                          onPressed: () => _delete(context, ref, attachment),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickFile(context, ref),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Adjuntar archivo'),
                ),
                if (canUseCamera)
                  OutlinedButton.icon(
                    onPressed: () => _takePhoto(context, ref),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Tomar foto'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _attachmentIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp')) {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final file = await pickAttachmentFile();
    if (file == null || !context.mounted) return;
    await _add(context, ref, file);
  }

  Future<void> _takePhoto(BuildContext context, WidgetRef ref) async {
    final file = await takeAttachmentPhoto();
    if (file == null || !context.mounted) return;
    await _add(context, ref, file);
  }

  Future<void> _add(BuildContext context, WidgetRef ref, XFile file) async {
    String? path;
    try {
      path = await copyAttachmentFile(file);
      final attachment = MaintenanceAttachment(
        maintenanceId: maintenanceId,
        name: p.basename(path),
        filePath: path,
        createdAt: DateTime.now(),
      );
      await ref
          .read(maintenanceAttachmentsNotifierProvider.notifier)
          .add(attachment);
      if (!context.mounted) return;
      AppSnackBar.success('Adjunto agregado');
    } catch (error) {
      if (path != null) await deleteAttachmentFile(path);
      logError('adjuntar a mantenimiento', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo adjuntar el archivo'),
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    MaintenanceAttachment attachment,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar adjunto',
      message: '¿Eliminar "${attachment.name}"?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(maintenanceAttachmentsNotifierProvider.notifier)
          .remove(attachment.id!, maintenanceId);
      await deleteAttachmentFile(attachment.filePath);
      if (!context.mounted) return;
      AppSnackBar.success('Adjunto eliminado');
    } catch (error) {
      logError('eliminar adjunto de mantenimiento', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo eliminar el adjunto'),
      );
    }
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.note_alt_outlined, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(notes, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Flexible(
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
