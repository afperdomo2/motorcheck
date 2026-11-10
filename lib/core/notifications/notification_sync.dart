import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/reminders/providers.dart';
import '../settings/app_preferences.dart';
import 'notification_service.dart';

/// Mantiene sincronizadas las notificaciones programadas con los recordatorios
/// y las preferencias del usuario.
class NotificationSync extends ConsumerStatefulWidget {
  const NotificationSync({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationSync> createState() => _NotificationSyncState();
}

class _NotificationSyncState extends ConsumerState<NotificationSync> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_sync);
  }

  void _sync() {
    final reminders = ref.read(remindersProvider).valueOrNull;
    final settings = ref.read(notificationSettingsProvider).valueOrNull;
    if (reminders == null || settings == null) return;
    unawaited(NotificationService.instance.sync(reminders, settings));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(remindersProvider, (previous, next) => _sync());
    ref.listen(notificationSettingsProvider, (previous, next) => _sync());
    return widget.child;
  }
}
