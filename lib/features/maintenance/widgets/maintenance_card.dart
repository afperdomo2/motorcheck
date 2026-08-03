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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme, total),
              if (workshopName != null) ...[
                const SizedBox(height: 4),
                _buildWorkshop(context, theme),
              ],
              if (items.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ...visibleItems.map((item) => _buildItemLine(context, item)),
                if (remaining > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, double total) {
    final parts = <Widget>[];

    if (maintenance.mileage != null) {
      parts.add(
        Text(
          formatMileage(maintenance.mileage),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      parts.add(Text(' · ', style: TextStyle(color: theme.disabledColor)));
    }

    parts.add(
      Text(
        formatShortDate(maintenance.date),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Row(
      children: [
        Expanded(child: Row(children: parts)),
        if (total > 0)
          Text(
            formatCurrency(total),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildWorkshop(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.handyman, size: 14, color: theme.disabledColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            workshopLocation != null && workshopLocation!.isNotEmpty
                ? 'Taller: $workshopName · $workshopLocation'
                : 'Taller: $workshopName',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildItemLine(BuildContext context, MaintenanceItem item) {
    final cat = categoryMap[item.category];
    final catName = cat?.name ?? item.category;
    final hasNotes = item.notes != null && item.notes!.isNotEmpty;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
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
        ],
      ),
    );
  }
}
