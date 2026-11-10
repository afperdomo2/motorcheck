import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/backup/backup_providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/utils/formatters.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final workshops = ref.watch(workshopsListProvider).valueOrNull ?? [];
    final currentMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Apariencia', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tema de la aplicación',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        avatar: const Icon(
                          Icons.brightness_auto_outlined,
                          size: 18,
                        ),
                        label: const Text('Sistema'),
                        selected: currentMode == ThemeMode.system,
                        showCheckmark: false,
                        onSelected: (_) => ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(ThemeMode.system),
                      ),
                      ChoiceChip(
                        avatar: const Icon(Icons.light_mode_outlined, size: 18),
                        label: const Text('Claro'),
                        selected: currentMode == ThemeMode.light,
                        showCheckmark: false,
                        onSelected: (_) => ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(ThemeMode.light),
                      ),
                      ChoiceChip(
                        avatar: const Icon(Icons.dark_mode_outlined, size: 18),
                        label: const Text('Oscuro'),
                        selected: currentMode == ThemeMode.dark,
                        showCheckmark: false,
                        onSelected: (_) => ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Recordatorios', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const _TonalIcon(
                    icon: Icons.notifications_active_outlined,
                  ),
                  title: const Text('Notificaciones y avisos'),
                  subtitle: const Text('Antelación y permisos del sistema'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/notifications'),
                ),
                const Divider(indent: 72),
                ListTile(
                  leading: const _TonalIcon(icon: Icons.inbox_outlined),
                  title: const Text('Ver recordatorios'),
                  subtitle: const Text(
                    'Mantenimiento, documentos y pico y placa',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/reminders'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Datos y respaldo', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListTile(
              leading: const _TonalIcon(icon: Icons.backup_outlined),
              title: const Text('Copias y exportación'),
              subtitle: const _LastBackupSubtitle(),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/backup'),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Catálogos', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const _TonalIcon(icon: Icons.handyman_outlined),
                  title: const Text('Talleres'),
                  subtitle: Text(
                    workshops.isEmpty
                        ? 'Sin talleres'
                        : '${workshops.length} taller${workshops.length == 1 ? '' : 'es'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/workshops'),
                ),
                const Divider(indent: 72),
                ListTile(
                  leading: const _TonalIcon(icon: Icons.category_outlined),
                  title: const Text('Categorías'),
                  subtitle: const Text('Frecuencias e iconos de mantenimiento'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/categories'),
                ),
                const Divider(indent: 72),
                ListTile(
                  leading: const _TonalIcon(icon: Icons.badge_outlined),
                  title: const Text('Mis documentos'),
                  subtitle: const Text('Licencia de conducción y otros'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/documents'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Acerca de', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: _TonalIcon(icon: Icons.info_outline),
                  title: Text('MotorCheck'),
                  subtitle: Text('Seguimiento de mantenimiento · v0.2.0'),
                ),
                Divider(indent: 72),
                ListTile(
                  leading: _TonalIcon(icon: Icons.storage_outlined),
                  title: Text('Datos locales'),
                  subtitle: Text(
                    'Tu información se guarda solo en este dispositivo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _LastBackupSubtitle extends ConsumerWidget {
  const _LastBackupSubtitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backup = ref.watch(lastBackupProvider).valueOrNull;
    return Text(
      backup == null
          ? 'Sin copias todavía'
          : 'Última copia: ${formatDisplayDate(backup)}',
    );
  }
}

class _TonalIcon extends StatelessWidget {
  final IconData icon;

  const _TonalIcon({required this.icon});

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
