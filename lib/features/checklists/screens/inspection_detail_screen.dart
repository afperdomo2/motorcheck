import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_chip.dart';
import '../providers.dart';

class InspectionDetailScreen extends ConsumerWidget {
  const InspectionDetailScreen({
    super.key,
    required this.vehicleId,
    required this.runId,
  });

  final int vehicleId;
  final int runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(inspectionDetailProvider(runId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de inspección')),
      body: detailAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudo cargar la inspección',
          onRetry: () => ref.invalidate(inspectionDetailProvider(runId)),
        ),
        data: (detail) {
          if (detail == null) {
            return const ErrorState(message: 'Inspección no encontrada');
          }

          final itemMap = {
            for (final item in detail.items) item.id!: item.label,
          };

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDisplayDate(detail.run.date),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (detail.run.odometer != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          formatMileage(detail.run.odometer),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (detail.run.notes != null &&
                          detail.run.notes!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          detail.run.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Resultados',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final answer in detail.answers)
                Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    title: Text(
                      itemMap[answer.itemId] ?? 'Item ${answer.itemId}',
                    ),
                    trailing: StatusChip(
                      status: _status(answer.status),
                      label: _label(answer.status),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  AppStatus _status(String status) {
    return switch (status) {
      'fail' => AppStatus.danger,
      'attention' => AppStatus.warning,
      _ => AppStatus.ok,
    };
  }

  String _label(String status) {
    return switch (status) {
      'fail' => 'Falla',
      'attention' => 'Revisar',
      _ => 'OK',
    };
  }
}
