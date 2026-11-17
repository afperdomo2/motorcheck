import 'package:flutter/material.dart';

import '../../core/theme/app_semantic_colors.dart';

/// Anillo de salud con el número dentro. `value == null` significa sin datos.
class HealthRing extends StatelessWidget {
  const HealthRing({
    super.key,
    required this.value,
    this.label,
    this.size = 48,
  });

  final int? value;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = AppSemanticColors.of(context);
    final hasData = value != null;
    final score = value ?? 0;
    final color = !hasData
        ? scheme.outline
        : score >= 90
        ? semantic.success
        : score >= 70
        ? semantic.warning
        : semantic.danger;

    return Semantics(
      label: hasData
          ? 'Salud $score de 100${label != null ? ', $label' : ''}'
          : 'Salud sin datos',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: hasData ? score / 100 : 0,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
                backgroundColor: scheme.surfaceContainer,
                color: color,
              ),
            ),
            Text(
              hasData ? '$score' : '—',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
