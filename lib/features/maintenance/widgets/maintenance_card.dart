import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme, total),
              _buildSubHeader(context, theme),
              if (items.isNotEmpty || maintenance.maintenanceCost > 0) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                if (maintenance.maintenanceCost > 0) _buildLaborItem(context),
                ...visibleItems.map((item) => _buildItemLine(context, item)),
                if (remaining > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '+$remaining más',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, double total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            maintenance.mileage != null
                ? formatMileage(maintenance.mileage)
                : 'Sin kilometraje',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: maintenance.mileage != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (total > 0)
          Text(formatCurrency(total), style: theme.textTheme.titleMedium),
      ],
    );
  }

  Widget _buildSubHeader(BuildContext context, ThemeData theme) {
    final parts = <Widget>[
      Text(
        formatWeekdayDay(maintenance.date),
        style: theme.textTheme.bodySmall,
      ),
    ];

    if (workshopName != null) {
      parts.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.handyman_outlined,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                workshopLocation != null && workshopLocation!.isNotEmpty
                    ? '$workshopName · $workshopLocation'
                    : workshopName!,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: parts,
      ),
    );
  }

  Widget _buildItemLine(BuildContext context, MaintenanceItem item) {
    final cat = categoryMap[item.category];
    final catName = cat?.name ?? item.category;
    final hasNotes = item.notes != null && item.notes!.isNotEmpty;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            cat != null
                ? MaintenanceCategories.iconByName(cat.iconName)
                : Icons.build_outlined,
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: catName),
                  if (hasNotes)
                    TextSpan(
                      text: ' · ${item.notes}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.partsCost > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              formatCurrency(item.partsCost),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLaborItem(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            Icons.engineering_outlined,
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Mano de obra',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            formatCurrency(maintenance.maintenanceCost),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
