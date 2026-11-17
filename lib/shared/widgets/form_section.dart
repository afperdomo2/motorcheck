import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'tonal_avatar.dart';

class FormSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const FormSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  TonalAvatar(icon: icon!, size: 32, iconSize: 18),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}
