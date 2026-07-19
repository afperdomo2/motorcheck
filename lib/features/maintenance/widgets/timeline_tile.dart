import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../categories.dart';
import '../models/maintenance.dart';
import '../models/maintenance_item.dart';

IconData _vehicleIcon(String? type) => switch (type) {
  'motorcycle' => Icons.motorcycle,
  'bike' => Icons.pedal_bike,
  'truck' => Icons.local_shipping,
  'other' => Icons.help_outline,
  _ => Icons.directions_car,
};

class TimelineTile extends StatelessWidget {
  final Maintenance maintenance;
  final VoidCallback onTap;
  final String? vehicleName;
  final String? vehicleType;
  final String? workshopName;
  final String? workshopLocation;
  final List<MaintenanceItem> items;
  final bool showConnector;
  final bool isLastInGroup;

  const TimelineTile({
    super.key,
    required this.maintenance,
    required this.onTap,
    this.vehicleName,
    this.vehicleType,
    this.workshopName,
    this.workshopLocation,
    this.items = const [],
    this.showConnector = true,
    this.isLastInGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = maintenance.maintenanceCost + maintenance.totalPartsCost;
    final categoryKeys = items.map((i) => i.category).toSet().toList();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConnectorLine(showConnector: showConnector, isLast: isLastInGroup),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (vehicleName != null)
                        Row(
                          children: [
                            Icon(_vehicleIcon(vehicleType), size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                vehicleName!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (total > 0)
                              Text(
                                formatCurrency(total),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                          ],
                        ),
                      if (categoryKeys.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildCategoryBadges(context, categoryKeys),
                      ],
                      if (maintenance.mileage != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.speed,
                              size: 14,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              formatMileage(maintenance.mileage),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                      if (workshopName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.handyman,
                              size: 14,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                workshopLocation != null &&
                                        workshopLocation!.isNotEmpty
                                    ? '${workshopName!} · $workshopLocation'
                                    : workshopName!,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (maintenance.notes != null &&
                          maintenance.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          maintenance.notes!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadges(BuildContext context, List<String> categoryKeys) {
    const showMax = 2;
    final visible = categoryKeys.take(showMax);
    final remaining = categoryKeys.length - showMax;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...visible.map((key) {
          final cat = MaintenanceCategories.byKey(key);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat?.icon ?? Icons.build, size: 12),
                const SizedBox(width: 3),
                Text(cat?.label ?? key, style: const TextStyle(fontSize: 10)),
              ],
            ),
          );
        }),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$remaining',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  final bool showConnector;
  final bool isLast;

  const _ConnectorLine({required this.showConnector, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Column(
        children: [
          if (showConnector)
            Expanded(
              child: Container(
                width: 2,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
          if (!showConnector) const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
