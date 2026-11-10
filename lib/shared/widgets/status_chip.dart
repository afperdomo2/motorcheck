import 'package:flutter/material.dart';

import '../../core/theme/app_semantic_colors.dart';

enum AppStatus { ok, warning, danger, neutral, info }

class StatusChip extends StatelessWidget {
  final AppStatus status;
  final String label;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.status,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final semantic = AppSemanticColors.of(context);

    final (background, foreground, defaultIcon) = switch (status) {
      AppStatus.ok => (
        semantic.successContainer,
        semantic.onSuccessContainer,
        Icons.check_circle_outline,
      ),
      AppStatus.warning => (
        semantic.warningContainer,
        semantic.onWarningContainer,
        Icons.warning_amber_rounded,
      ),
      AppStatus.danger => (
        semantic.dangerContainer,
        semantic.onDangerContainer,
        Icons.error_outline,
      ),
      AppStatus.info => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.info_outline,
      ),
      AppStatus.neutral => (
        scheme.surfaceContainer,
        scheme.onSurfaceVariant,
        Icons.circle_outlined,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? defaultIcon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
