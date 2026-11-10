import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class StickyBottomBar extends StatelessWidget {
  final Widget child;

  const StickyBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surface,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
