import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../../core/backup/backup_providers.dart';
import '../../../core/settings/app_preferences.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../documents/providers.dart';
import '../../maintenance/providers.dart';
import '../../reminders/providers.dart';
import '../../restrictions/providers.dart';
import '../../settings/providers.dart';
import '../../vehicles/providers.dart';

class DataBackupScreen extends ConsumerStatefulWidget {
  const DataBackupScreen({super.key});

  @override
  ConsumerState<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends ConsumerState<DataBackupScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastBackup = ref.watch(lastBackupProvider);
    final autoBackup = ref.watch(autoBackupEnabledProvider);
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? [];
    final maintenances =
        ref.watch(maintenancesNotifierProvider).valueOrNull ?? [];
    final documents = ref.watch(allDocumentsProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Datos y respaldo')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder_copy_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Tu información',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CountRow(label: 'Vehículos', value: vehicles.length),
                  _CountRow(
                    label: 'Mantenimientos',
                    value: maintenances.length,
                  ),
                  _CountRow(label: 'Documentos', value: documents.length),
                  const Divider(height: AppSpacing.xl),
                  lastBackup.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text('No se pudo leer la última copia'),
                    data: (date) => Row(
                      children: [
                        const Icon(Icons.history, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            date == null
                                ? 'Aún no hay copias de seguridad'
                                : 'Última copia: ${_formatBackupDate(date)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const _TonalIcon(Icons.backup_outlined),
                  title: const Text('Crear copia ahora'),
                  subtitle: const Text('Incluye datos y documentos adjuntos'),
                  trailing: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _busy ? null : _createBackup,
                ),
                const Divider(indent: 72),
                ListTile(
                  leading: const _TonalIcon(Icons.table_view_outlined),
                  title: const Text('Exportar a CSV'),
                  subtitle: const Text('Para abrir en Excel o LibreOffice'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _busy ? null : _exportCsv,
                ),
                const Divider(indent: 72),
                ListTile(
                  leading: const _TonalIcon(Icons.restore_outlined),
                  title: const Text('Restaurar copia'),
                  subtitle: const Text('Reemplaza todos los datos actuales'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _busy ? null : _restore,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const _TonalIcon(Icons.schedule_outlined),
                  title: const Text('Copia automática'),
                  subtitle: const Text(
                    'Una vez al día, conservando las últimas 7 copias',
                  ),
                  value: autoBackup.valueOrNull ?? true,
                  onChanged: _busy
                      ? null
                      : (value) async {
                          await AppPreferences.setAutoBackupEnabled(value);
                          ref.invalidate(autoBackupEnabledProvider);
                          if (!mounted) return;
                          AppSnackBar.info(
                            value
                                ? 'Copia automática activada'
                                : 'Copia automática desactivada',
                          );
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tus datos no salen del dispositivo salvo que tú '
                      'decidas exportarlos. La copia incluye información '
                      'personal y documentos; guárdala en un lugar seguro.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final result = await service.createBackup();
      ref.invalidate(lastBackupProvider);
      if (!mounted) return;
      await _shareOrSave(result.file);
      if (!mounted) return;
      AppSnackBar.success(
        'Copia creada: ${result.totalRecords} registros, '
        '${result.attachments} adjuntos',
      );
    } catch (error) {
      logError('crear copia', error, StackTrace.current);
      if (!mounted) return;
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo crear la copia'),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.exportCsv();
      if (!mounted) return;
      await _shareOrSave(file);
      if (!mounted) return;
      AppSnackBar.success('CSV exportado');
    } catch (error) {
      logError('exportar csv', error, StackTrace.current);
      if (!mounted) return;
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo exportar el CSV'),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final picked = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Copia de MotorCheck', extensions: ['zip']),
      ],
    );
    if (picked == null) return;

    setState(() => _busy = true);
    try {
      final service = ref.read(backupServiceProvider);
      final preview = await service.inspect(File(picked.path));
      if (!mounted) return;

      final confirmed = await showConfirmDialog(
        context,
        title: 'Restaurar copia',
        message:
            'Se reemplazarán todos los datos actuales por los de '
            '${preview.fileName}.\n\n'
            '${preview.counts.entries.where((e) => e.value > 0).map((e) => '${e.key}: ${e.value}').join('\n')}\n\n'
            'Antes de restaurar se creará una copia de seguridad.',
        confirmLabel: 'Restaurar',
        isDestructive: true,
      );
      if (confirmed != true) return;

      await service.restore(File(picked.path));
      _invalidateAfterRestore();
      if (!mounted) return;
      AppSnackBar.success('Datos restaurados');
    } catch (error) {
      logError('restaurar copia', error, StackTrace.current);
      if (!mounted) return;
      AppSnackBar.error(
        friendlyErrorMessage(
          error,
          fallback: 'No se pudo restaurar la copia. Revisa el archivo.',
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _invalidateAfterRestore() {
    ref.invalidate(vehiclesProvider);
    ref.invalidate(defaultVehicleProvider);
    ref.invalidate(selectedVehicleProvider);
    ref.invalidate(vehicleMileageReadingsProvider);
    ref.invalidate(mileageStatsProvider);
    ref.invalidate(maintenancesNotifierProvider);
    ref.invalidate(maintenanceAttentionCountProvider);
    ref.invalidate(workshopsListProvider);
    ref.invalidate(workshopsProvider);
    ref.invalidate(maintenanceCategoriesProvider);
    ref.invalidate(allDocumentsProvider);
    ref.invalidate(globalDocumentsProvider);
    ref.invalidate(vehicleDocumentsProvider);
    ref.invalidate(restrictionStatusesProvider);
    ref.invalidate(vehicleRestrictionProvider);
    ref.invalidate(remindersProvider);
    ref.invalidate(notificationSettingsProvider);
    ref.invalidate(themeModeProvider);
    ref.invalidate(lastBackupProvider);
    ref.read(vehiclesNotifierProvider.notifier).loadVehicles();
    ref.read(maintenancesNotifierProvider.notifier).loadMaintenances();
  }

  Future<void> _shareOrSave(File file) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Copia de seguridad de MotorCheck',
        ),
      );
      return;
    }

    final location = await getSaveLocation(
      suggestedName: p.basename(file.path),
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Archivo ZIP', extensions: ['zip']),
      ],
    );
    if (location == null) return;
    await file.copy(location.path);
    if (!mounted) return;
    AppSnackBar.info('Guardado en ${location.path}');
  }

  String _formatBackupDate(DateTime date) {
    return '${formatDisplayDate(date)} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _CountRow extends StatelessWidget {
  final String label;
  final int value;

  const _CountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TonalIcon extends StatelessWidget {
  final IconData icon;

  const _TonalIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
    );
  }
}
