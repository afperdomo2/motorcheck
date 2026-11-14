import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../vehicles/providers.dart';
import '../models/component_status.dart';
import '../models/vehicle_component.dart';
import '../providers.dart';
import '../widgets/component_card.dart';

class ComponentsScreen extends ConsumerStatefulWidget {
  const ComponentsScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  ConsumerState<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends ConsumerState<ComponentsScreen> {
  String? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicleAsync = ref.watch(selectedVehicleProvider(widget.vehicleId));
    final statusesAsync = ref.watch(
      vehicleComponentStatusesProvider(widget.vehicleId),
    );
    final vehicle = vehicleAsync.valueOrNull;
    final hasSpare =
        statusesAsync.valueOrNull?.any(
          (status) => status.component.name == 'Llanta de repuesto',
        ) ??
        false;
    final showSpareAction = vehicle?.type == 'car' && !hasSpare;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Componentes'),
            if (vehicle != null)
              Text(
                vehicle.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          if (showSpareAction)
            IconButton(
              tooltip: 'Agregar llanta de repuesto',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => context.push(
                '/vehicles/${widget.vehicleId}/components/add?spare=1',
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
      body: statusesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudieron cargar los componentes',
          onRetry: () => ref.invalidate(
            vehicleComponentStatusesProvider(widget.vehicleId),
          ),
        ),
        data: (statuses) {
          if (statuses.isEmpty) {
            return EmptyState(
              icon: Icons.tire_repair,
              title: 'Sin componentes',
              subtitle:
                  'Registra llantas, batería, cadena, frenos o suspensión '
                  'para controlar su desgaste.',
              onAction: _openForm,
              actionLabel: 'Agregar componente',
            );
          }

          final availableTypes = <String>{
            for (final status in statuses) status.component.type,
          };
          final filtered = _typeFilter == null
              ? statuses
              : statuses
                    .where((status) => status.component.type == _typeFilter)
                    .toList();

          return Column(
            children: [
              _FilterBar(
                types: availableTypes,
                selected: _typeFilter,
                onSelected: (type) => setState(() => _typeFilter = type),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      vehicleComponentStatusesProvider(widget.vehicleId),
                    );
                    await ref.read(
                      vehicleComponentStatusesProvider(widget.vehicleId).future,
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxxl * 2,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          '${filtered.length} componente'
                          '${filtered.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      if (_typeFilter == null)
                        ..._grouped(statuses)
                      else
                        ..._cards(filtered),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _grouped(List<ComponentStatus> statuses) {
    final theme = Theme.of(context);
    final widgets = <Widget>[];
    for (final option in componentTypeOptions) {
      final group = statuses
          .where((status) => status.component.type == option.key)
          .toList();
      if (group.isEmpty) continue;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(option.label, style: theme.textTheme.titleSmall),
            ],
          ),
        ),
      );
      widgets.addAll(_cards(group));
    }
    return widgets;
  }

  List<Widget> _cards(List<ComponentStatus> statuses) {
    return [
      for (final status in statuses)
        ComponentCard(status: status, onTap: () => _openDetail(status)),
    ];
  }

  void _openForm() {
    context.push('/vehicles/${widget.vehicleId}/components/add');
  }

  void _openDetail(ComponentStatus status) {
    final id = status.component.id;
    if (id == null) return;
    context.push('/vehicles/${widget.vehicleId}/components/$id');
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.types,
    required this.selected,
    required this.onSelected,
  });

  final Set<String> types;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = componentTypeOptions
        .where((option) => types.contains(option.key))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Todos'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final option in options) ...[
            const SizedBox(width: AppSpacing.sm),
            FilterChip(
              label: Text(option.label),
              selected: selected == option.key,
              onSelected: (_) => onSelected(option.key),
            ),
          ],
        ],
      ),
    );
  }
}
