import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../models/maintenance.dart';
import '../providers.dart';

class MaintenanceSearchDelegate extends SearchDelegate<Maintenance?> {
  final WidgetRef ref;

  MaintenanceSearchDelegate(this.ref)
    : super(searchFieldLabel: 'Buscar mantenimiento...');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final maintenancesAsync = ref.watch(maintenancesProvider);
    final workshopsAsync = ref.watch(workshopsProvider);

    return maintenancesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (maintenances) {
        final q = query.toLowerCase().trim();
        final workshops = workshopsAsync.valueOrNull ?? [];

        List<Maintenance> filtered;
        if (q.isEmpty) {
          filtered = maintenances;
        } else {
          filtered = maintenances.where((m) {
            final dateStr = formatDate(m.date).toLowerCase();
            final notesStr = (m.notes ?? '').toLowerCase();
            final workshop = workshops
                .where((w) => w.id == m.workshopId)
                .firstOrNull;
            final workshopName = (workshop?.name ?? '').toLowerCase();
            return dateStr.contains(q) ||
                notesStr.contains(q) ||
                workshopName.contains(q);
          }).toList();
        }

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  q.isEmpty ? 'Escribe para buscar' : 'Sin resultados',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        final maintenanceIds = filtered.map((m) => m.id!).toList();
        final itemsProviderRef = ref;
        final itemsAsync = itemsProviderRef.watch(
          workshopItemsProvider(maintenanceIds),
        );
        final itemsByMaintenance = itemsAsync.valueOrNull ?? {};

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final maintenance = filtered[index];
            final items = itemsByMaintenance[maintenance.id] ?? [];
            final total =
                maintenance.maintenanceCost + maintenance.totalPartsCost;
            final workshop = workshops
                .where((w) => w.id == maintenance.workshopId)
                .firstOrNull;

            return ListTile(
              title: Text(formatDate(maintenance.date)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items.isNotEmpty)
                    Text(
                      items.map((i) => i.category).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (workshop != null)
                    Text(
                      workshop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              trailing: total > 0 ? Text(formatCurrency(total)) : null,
              onTap: () {
                close(context, null);
                context.push('/maintenance/${maintenance.id}');
              },
            );
          },
        );
      },
    );
  }
}
