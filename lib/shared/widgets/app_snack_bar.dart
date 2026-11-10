import 'package:flutter/material.dart';

import '../../core/theme/app_semantic_colors.dart';

/// Feedback global para que los mensajes sobrevivan a la navegación.
class AppSnackBar {
  AppSnackBar._();

  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void success(String message) {
    _show(message, Icons.check_circle_outline, _Tone.success);
  }

  static void error(String message) {
    _show(message, Icons.error_outline, _Tone.danger);
  }

  static void info(String message) {
    _show(message, Icons.info_outline, _Tone.neutral);
  }

  static void _show(String message, IconData icon, _Tone tone) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    final context = messenger.context;
    final semantic = AppSemanticColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (background, foreground) = switch (tone) {
      _Tone.success => (semantic.success, semantic.onSuccess),
      _Tone.danger => (semantic.danger, semantic.onDanger),
      _Tone.neutral => (scheme.inverseSurface, scheme.onInverseSurface),
    };

    final duration = switch (tone) {
      _Tone.success => const Duration(seconds: 2),
      _Tone.danger => const Duration(seconds: 4),
      _Tone.neutral => const Duration(seconds: 3),
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          duration: duration,
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

enum _Tone { success, danger, neutral }
