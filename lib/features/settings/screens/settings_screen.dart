import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsListProvider);
    final count = workshopsAsync.valueOrNull?.length ?? 0;
    final themeModeAsync = ref.watch(themeModeProvider);
    final currentMode = themeModeAsync.valueOrNull ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Apariencia', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
              ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
            ],
            selected: {currentMode},
            onSelectionChanged: (modes) {
              ref.read(themeModeProvider.notifier).setThemeMode(modes.first);
            },
          ),
          const Divider(height: 32),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.handyman)),
            title: const Text('Talleres'),
            subtitle: Text(
              count > 0
                  ? '$count taller${count == 1 ? '' : 'es'} registrado${count == 1 ? '' : 's'}'
                  : 'Sin talleres',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/workshops'),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.category)),
            title: const Text('Categorías'),
            subtitle: const Text('Categorías de mantenimiento'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/categories'),
          ),
        ],
      ),
    );
  }
}
