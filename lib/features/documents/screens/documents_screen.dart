import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../vehicles/providers.dart';
import '../file_storage.dart';
import '../models/vehicle_document.dart';
import '../providers.dart';
import '../widgets/document_card.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key, this.vehicleId});

  final int? vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGlobal = vehicleId == null;
    final documentsAsync = isGlobal
        ? ref.watch(globalDocumentsProvider)
        : ref.watch(vehicleDocumentsProvider(vehicleId!));
    final vehicleAsync = vehicleId == null
        ? null
        : ref.watch(selectedVehicleProvider(vehicleId!));

    final title = isGlobal
        ? 'Mis documentos'
        : vehicleAsync?.valueOrNull?.name ?? 'Documentos';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: documentsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudieron cargar los documentos',
          onRetry: () {
            if (isGlobal) {
              ref.invalidate(globalDocumentsProvider);
            } else {
              ref.invalidate(vehicleDocumentsProvider(vehicleId!));
            }
          },
        ),
        data: (documents) {
          if (documents.isEmpty) {
            return EmptyState(
              icon: Icons.description_outlined,
              title: 'Sin documentos',
              subtitle: isGlobal
                  ? 'Guarda tu licencia de conducción y otros documentos'
                  : 'Registra SOAT, tecnomecánica, impuesto y seguro',
              onAction: () => _openForm(context),
              actionLabel: 'Agregar documento',
            );
          }

          final seenTypes = <String>{};
          final currentIds = <int>{};
          for (final document in documents) {
            if (seenTypes.add(document.type) && document.id != null) {
              currentIds.add(document.id!);
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl * 2,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  '${documents.length} documento'
                  '${documents.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ...documents.map(
                (document) => DocumentCard(
                  document: document,
                  isCurrent:
                      document.id != null && currentIds.contains(document.id),
                  onTap: () => _openForm(context, documentId: document.id),
                  onEdit: () => _openForm(context, documentId: document.id),
                  onRenew: () => _openForm(context, renewId: document.id),
                  onDelete: () => _delete(context, ref, document),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {int? documentId, int? renewId}) {
    final query = renewId != null ? '?renew=$renewId' : '';
    if (vehicleId == null) {
      if (documentId == null) {
        context.push('/settings/documents/add$query');
      } else {
        context.push('/settings/documents/$documentId/edit');
      }
      return;
    }
    if (documentId == null) {
      context.push('/vehicles/$vehicleId/documents/add$query');
    } else {
      context.push('/vehicles/$vehicleId/documents/$documentId/edit');
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    VehicleDocument document,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar documento',
      message:
          '¿Eliminar ${document.name ?? documentTypeFor(document.type).label}? '
          'También se eliminará el archivo adjunto.',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(documentsNotifierProvider.notifier)
          .remove(document.id!, vehicleId: document.vehicleId);
      await deleteDocumentFile(document.filePath);
      AppSnackBar.success('Documento eliminado');
    } catch (error) {
      logError('eliminar documento', error, StackTrace.current);
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo eliminar el documento',
        ),
      );
    }
  }
}
