import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workshopsAsync = ref.watch(workshopsListProvider);
    final count = workshopsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
        ],
      ),
    );
  }
}
