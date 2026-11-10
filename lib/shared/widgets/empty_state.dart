import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionLabel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final iconSize = compact ? 40.0 : 88.0;
    final iconGlyph = compact ? 20.0 : 40.0;
    final titleGap = compact ? AppSpacing.md : AppSpacing.xl;
    final subtitleGap = compact ? AppSpacing.xs : AppSpacing.sm;
    final actionGap = compact ? AppSpacing.md : AppSpacing.xl;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconGlyph,
                color: scheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: titleGap),
            Text(
              title,
              style: compact
                  ? theme.textTheme.bodyLarge
                  : theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: subtitleGap),
              Text(
                subtitle!,
                style: compact
                    ? theme.textTheme.bodySmall
                    : theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: actionGap),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
