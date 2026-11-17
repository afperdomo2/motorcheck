import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/health_ring.dart';
import '../../../shared/widgets/vehicle_avatar.dart';
import '../../finance/providers.dart';
import '../../maintenance/providers.dart';
import '../../reminders/providers.dart';
import '../../vehicles/current_vehicle_provider.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/providers.dart';

/// Carrusel de vehículos con altura natural. La card se desliza con el dedo
/// y cambia con una transición; no deja huecos y se adapta al tamaño de texto.
class VehicleCarousel extends ConsumerStatefulWidget {
  const VehicleCarousel({super.key});

  @override
  ConsumerState<VehicleCarousel> createState() => _VehicleCarouselState();
}

class _VehicleCarouselState extends ConsumerState<VehicleCarousel> {
  double _dragOffset = 0;
  bool _forward = true;

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? const [];
    final current = ref.watch(currentVehicleProvider).valueOrNull;
    if (vehicles.isEmpty) return const SizedBox.shrink();

    final vehicle = current ?? vehicles.first;
    final currentIndex = _indexFor(vehicles, vehicle);

    ref.listen(currentVehicleProvider, (previous, next) {
      final previousIndex = _indexFor(vehicles, previous?.valueOrNull);
      final nextIndex = _indexFor(vehicles, next.valueOrNull);
      if (previousIndex != nextIndex) _forward = nextIndex > previousIndex;
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              final width = MediaQuery.sizeOf(context).width;
              final max = width * 0.4;
              setState(() {
                _dragOffset = (_dragOffset + details.delta.dx).clamp(-max, max);
              });
            },
            onHorizontalDragEnd: (details) => _onDragEnd(
              vehicles,
              currentIndex,
              details.primaryVelocity ?? 0,
            ),
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) {
                  final incoming = child.key == ValueKey(vehicle.id);
                  final begin = incoming
                      ? Offset(_forward ? 0.12 : -0.12, 0)
                      : Offset(_forward ? -0.12 : 0.12, 0);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: begin, end: Offset.zero)
                          .animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                  );
                },
                child: _VehicleSlide(
                  key: ValueKey(vehicle.id),
                  vehicle: vehicle,
                ),
              ),
            ),
          ),
          if (vehicles.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            _PageDots(
              count: vehicles.length,
              activeIndex: currentIndex,
              onSelected: (index) {
                if (index == currentIndex) return;
                _forward = index > currentIndex;
                setState(() => _dragOffset = 0);
                _select(vehicles[index]);
              },
            ),
          ],
        ],
      ),
    );
  }

  int _indexFor(List<Vehicle> vehicles, Vehicle? vehicle) {
    final id = vehicle?.id;
    if (id == null) return 0;
    final index = vehicles.indexWhere((item) => item.id == id);
    return index < 0 ? 0 : index;
  }

  void _onDragEnd(List<Vehicle> vehicles, int currentIndex, double velocity) {
    final width = MediaQuery.sizeOf(context).width;
    final threshold = width * 0.18;
    final goNext = _dragOffset < -threshold || velocity < -500;
    final goPrev = _dragOffset > threshold || velocity > 500;

    if (goNext && currentIndex < vehicles.length - 1) {
      _forward = true;
      setState(() => _dragOffset = 0);
      _select(vehicles[currentIndex + 1]);
      return;
    }
    if (goPrev && currentIndex > 0) {
      _forward = false;
      setState(() => _dragOffset = 0);
      _select(vehicles[currentIndex - 1]);
      return;
    }
    setState(() => _dragOffset = 0);
  }

  Future<void> _select(Vehicle vehicle) async {
    final id = vehicle.id;
    if (id == null) return;
    try {
      await ref.read(vehiclesNotifierProvider.notifier).selectVehicle(id);
    } catch (error, stackTrace) {
      logError('seleccionar vehículo desde carrusel', error, stackTrace);
    }
  }
}

class _VehicleSlide extends ConsumerWidget {
  const _VehicleSlide({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semantic = AppSemanticColors.of(context);
    final scheme = theme.colorScheme;
    final accent = semantic.vehicleColor(vehicle.type);
    final tint = accent.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.18 : 0.08,
    );
    final id = vehicle.id;
    final meta = [
      if (vehicle.plate != null) vehicle.plate!,
      if (vehicle.currentMileage != null) formatMileage(vehicle.currentMileage),
    ].join(' · ');

    final health = id == null
        ? null
        : ref.watch(vehicleHealthProvider(id)).valueOrNull;
    final spendAsync = id == null
        ? null
        : ref.watch(vehicleMonthSpendProvider(id));
    final upcoming = id == null
        ? null
        : ref.watch(upcomingMaintenanceProvider(id)).valueOrNull;
    final upcomingCount =
        upcoming?.where((item) => item.isWarning || item.isOverdue).length ?? 0;

    final spendLabel = spendAsync == null
        ? '—'
        : spendAsync.hasValue
        ? formatCompactCurrency(spendAsync.requireValue)
        : '—';

    return Material(
      color: tint,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: id == null ? null : () => context.push('/vehicles/$id'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VehicleAvatar(type: vehicle.type, size: 52),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                vehicle.name,
                                style: theme.textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (vehicle.isDefault) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star,
                                size: 18,
                                color: scheme.primary,
                                semanticLabel: 'Vehículo principal',
                              ),
                            ],
                          ],
                        ),
                        if (meta.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            meta,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  HealthRing(
                    value: health?.hasData == true ? health!.value : null,
                    label: health?.label,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      formatMonthYear(DateTime.now()),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        spendLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: id == null
                      ? null
                      : () => context.push('/vehicles/$id/upcoming'),
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(
                    upcomingCount > 0
                        ? 'Próximos ($upcomingCount)'
                        : 'Próximos',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.count,
    required this.activeIndex,
    required this.onSelected,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++)
          Semantics(
            button: true,
            selected: index == activeIndex,
            label: 'Vehículo ${index + 1}',
            child: GestureDetector(
              onTap: () => onSelected(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: AppSpacing.xs,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: index == activeIndex ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == activeIndex
                        ? scheme.primary
                        : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
