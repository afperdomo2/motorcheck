import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../categories.dart';
import '../models/maintenance.dart';
import '../models/maintenance_item.dart';
import '../../settings/models/maintenance_category.dart';

class MaintenanceCard extends StatelessWidget {
  final Maintenance maintenance;
  final VoidCallback onTap;
  final String? workshopName;
  final String? workshopLocation;
  final List<MaintenanceItem> items;
  final Map<String, MaintenanceCategory> categoryMap;

  const MaintenanceCard({
    super.key,
    required this.maintenance,
    required this.onTap,
    this.workshopName,
    this.workshopLocation,
    this.items = const [],
    this.categoryMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final total = maintenance.maintenanceCost + maintenance.totalPartsCost;
    final theme = Theme.of(context);
    const maxItems = 5;
    final visibleItems = items.take(maxItems).toList();
    final remaining = items.length - maxItems;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme, total),
            if (workshopName != null || maintenance.mileage != null)
              _buildSubHeader(context, theme),
            if (items.isNotEmpty || maintenance.maintenanceCost > 0) ...[
              const SizedBox(height: 8),
              if (maintenance.maintenanceCost > 0) _buildLaborItem(context),
              ...visibleItems.map((item) => _buildItemLine(context, item)),
              if (remaining > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+$remaining más',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, double total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (maintenance.mileage != null)
          Expanded(
            child: Text(
              formatMileage(maintenance.mileage),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          )
        else
          const Expanded(child: SizedBox.shrink()),
        if (total > 0)
          Text(
            formatCurrency(total),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildSubHeader(BuildContext context, ThemeData theme) {
    final parts = <Widget>[];

    parts.add(
      Text(
        formatWeekdayDay(maintenance.date),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );

    if (workshopName != null) {
      parts.add(Text(' · ', style: TextStyle(color: theme.disabledColor)));
      parts.add(Icon(Icons.handyman, size: 12, color: theme.disabledColor));
      parts.add(const SizedBox(width: 3));
      parts.add(
        Flexible(
          child: Text(
            workshopLocation != null && workshopLocation!.isNotEmpty
                ? '$workshopName · $workshopLocation'
                : workshopName!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(children: parts),
    );
  }

  Widget _buildItemLine(BuildContext context, MaintenanceItem item) {
    final cat = categoryMap[item.category];
    final catName = cat?.name ?? item.category;
    final hasNotes = item.notes != null && item.notes!.isNotEmpty;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            cat != null
                ? MaintenanceCategories.iconByName(cat.iconName)
                : Icons.build,
            size: 14,
            color: theme.disabledColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: catName),
                  if (hasNotes)
                    TextSpan(
                      text: ' · ${item.notes}',
                      style: TextStyle(
                        color: theme.disabledColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
                style: theme.textTheme.bodySmall,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.partsCost > 0) ...[
            const SizedBox(width: 6),
            Text(
              formatCurrency(item.partsCost),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLaborItem(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.engineering_outlined,
            size: 14,
            color: theme.disabledColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Mano de obra', style: theme.textTheme.bodySmall),
          ),
          Text(
            formatCurrency(maintenance.maintenanceCost),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
