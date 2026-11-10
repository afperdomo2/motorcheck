import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../restrictions/providers.dart';

class PicoYPlacaBanner extends ConsumerWidget {
  const PicoYPlacaBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(restrictionStatusesProvider).valueOrNull ?? [];
    final restricted = entries
        .where((entry) => entry.status.restrictedToday)
        .toList();
    if (restricted.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final entry = restricted.first;

    return Card(
      color: semantic.warningContainer,
      child: InkWell(
        onTap: () => context.push('/vehicles/${entry.vehicle.id}/restriction'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.do_not_disturb_on_outlined,
                color: semantic.onWarningContainer,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pico y placa hoy',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: semantic.onWarningContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.vehicle.name} · ${entry.status.todayLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: semantic.onWarningContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: semantic.onWarningContainer),
            ],
          ),
        ),
      ),
    );
  }
}
