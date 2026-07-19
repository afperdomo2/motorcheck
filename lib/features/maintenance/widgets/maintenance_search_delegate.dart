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

    return maintenancesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (maintenances) {
        final q = query.toLowerCase().trim();
        final filtered = q.isEmpty
            ? maintenances
            : maintenances
                  .where((m) => m.title.toLowerCase().contains(q))
                  .toList();

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

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final maintenance = filtered[index];
            final total =
                maintenance.totalLaborCost + maintenance.totalPartsCost;
            return ListTile(
              title: Text(maintenance.title),
              subtitle: Text(formatDate(maintenance.date)),
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
