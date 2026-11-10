import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_mode_provider.dart';
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
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Sistema'),
                          icon: Icon(Icons.brightness_auto_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Claro'),
                          icon: Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Oscuro'),
                          icon: Icon(Icons.dark_mode_outlined),
                        ),
                      ],
                      selected: {currentMode},
                      showSelectedIcon: false,
                      onSelectionChanged: (modes) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(modes.first);
                      },
                    ),
                  ),
                ],
              ),
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
                  subtitle: Text('Seguimiento de mantenimiento · v0.1.0'),
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
