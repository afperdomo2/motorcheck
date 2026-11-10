import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/app_preferences.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: settingsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudieron cargar los recordatorios',
          onRetry: () => ref.invalidate(notificationSettingsProvider),
        ),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (!NotificationService.instance.supportsScheduling)
                Card(
                  color: theme.colorScheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        const Icon(Icons.desktop_windows_outlined),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'En escritorio los recordatorios se muestran '
                            'dentro de la app. Las notificaciones programadas '
                            'están disponibles en Android.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const _TonalIcon(
                        Icons.notifications_active_outlined,
                      ),
                      title: const Text('Notificaciones'),
                      subtitle: const Text(
                        'Avisos de mantenimiento, documentos y pico y placa',
                      ),
                      value: settings.enabled,
                      onChanged: (value) =>
                          _toggle(context, ref, settings, value),
                    ),
                    const Divider(indent: 72),
                    ListTile(
                      leading: const _TonalIcon(Icons.schedule_outlined),
                      title: const Text('Antelación'),
                      subtitle: Text(_leadLabel(settings.leadDays)),
                      trailing: DropdownButton<int>(
                        value: settings.leadDays,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: 7, child: Text('7 días')),
                          DropdownMenuItem(value: 15, child: Text('15 días')),
                          DropdownMenuItem(value: 30, child: Text('30 días')),
                          DropdownMenuItem(value: 60, child: Text('60 días')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .save(settings.copyWith(leadDays: value));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Column(
                  children: [
                    FutureBuilder<bool>(
                      future: NotificationService.instance
                          .areNotificationsEnabled(),
                      builder: (context, snapshot) {
                        final enabled = snapshot.data;
                        return ListTile(
                          leading: _TonalIcon(
                            enabled == false
                                ? Icons.notifications_off_outlined
                                : Icons.check_circle_outline,
                          ),
                          title: const Text('Permiso del sistema'),
                          subtitle: Text(
                            enabled == null
                                ? 'Comprobando…'
                                : enabled
                                ? 'Permiso concedido'
                                : 'Permiso denegado. Actívalo en Ajustes del '
                                      'sistema.',
                          ),
                        );
                      },
                    ),
                    const Divider(indent: 72),
                    ListTile(
                      leading: const _TonalIcon(Icons.send_outlined),
                      title: const Text('Probar notificación'),
                      subtitle: const Text(
                        'Envía un aviso inmediato si hay permiso',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await NotificationService.instance.showTest();
                        AppSnackBar.info('Notificación de prueba enviada');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Los avisos por kilometraje usan la fecha estimada según '
                    'tu ritmo de uso. Se recalculan cada vez que abres la app '
                    'o registras un mantenimiento.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
    bool value,
  ) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        if (context.mounted) {
          AppSnackBar.error(
            'Activa el permiso de notificaciones en Ajustes del sistema',
          );
        }
        return;
      }
    }
    try {
      await ref
          .read(notificationSettingsProvider.notifier)
          .save(settings.copyWith(enabled: value));
    } catch (error) {
      logError('guardar recordatorios', error, StackTrace.current);
      if (!context.mounted) return;
      AppSnackBar.error('No se pudieron guardar los recordatorios');
    }
  }

  String _leadLabel(int days) {
    switch (days) {
      case 7:
        return 'Una semana antes';
      case 15:
        return 'Quince días antes';
      case 30:
        return 'Un mes antes';
      case 60:
        return 'Dos meses antes';
      default:
        return '$days días antes';
    }
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
