import 'package:flutter/material.dart';

import '../../core/theme/app_semantic_colors.dart';

/// Tono de un [TonalAvatar].
enum TonalAvatarTone {
  /// Decoración: superficies neutras. Nunca usa el ámbar de marca, para que
  /// una alerta sea la única nota cálida de la pantalla.
  neutral,

  /// Contenedor de advertencia: reservado para estados que piden atención.
  warning,
}

/// Contenedor tonal para el icono que encabeza una card, fila o ficha.
///
/// Centraliza el patrón "icono en caja redondeada" para que la decoración no
/// vuelva a pintarse con colores de marca o de severidad.
class TonalAvatar extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final bool circular;
  final TonalAvatarTone tone;

  const TonalAvatar({
    super.key,
    required this.icon,
    this.size = 40,
    double? iconSize,
    this.circular = false,
    this.tone = TonalAvatarTone.neutral,
  }) : iconSize = iconSize ?? size * 0.5;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = AppSemanticColors.of(context);

    final (background, foreground) = switch (tone) {
      TonalAvatarTone.neutral => (
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      ),
      TonalAvatarTone.warning => (
        semantic.warningContainer,
        semantic.onWarningContainer,
      ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size * 0.25),
      ),
      child: Icon(icon, size: iconSize, color: foreground),
    );
  }
}
