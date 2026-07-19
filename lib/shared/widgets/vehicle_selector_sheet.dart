import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/vehicles/providers.dart';
import '../../features/vehicles/models/vehicle.dart';

class VehicleSelectorSheet extends ConsumerWidget {
  const VehicleSelectorSheet({super.key});

  static Future<Vehicle?> show(BuildContext context) {
    return showModalBottomSheet<Vehicle>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const VehicleSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Selecciona un vehículo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: vehiclesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) =>
                    Center(child: Text('Error: $err')),
                data: (vehicles) {
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _typeColor(vehicle.type)
                                .withValues(alpha: 0.15),
                            child: Icon(
                              _typeIcon(vehicle.type),
                              color: _typeColor(vehicle.type),
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(child: Text(vehicle.name)),
                              if (vehicle.isDefault) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.star,
                                    size: 16, color: Colors.amber[600]),
                              ],
                            ],
                          ),
                          subtitle: [
                            vehicle.brand,
                            vehicle.model,
                          ].whereType<String>().join(' ').isEmpty
                              ? null
                              : Text(
                                  [vehicle.brand, vehicle.model]
                                      .whereType<String>()
                                      .join(' '),
                                ),
                          trailing: vehicle.plate != null
                              ? Text(vehicle.plate!)
                              : null,
                          onTap: () => Navigator.of(context).pop(vehicle),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Color _typeColor(String type) {
  return switch (type) {
    'car' => const Color(0xFF2563EB),
    'motorcycle' => const Color(0xFF7C3AED),
    'bike' => const Color(0xFF059669),
    'truck' => const Color(0xFFD97706),
    _ => const Color(0xFF64748B),
  };
}

IconData _typeIcon(String type) {
  return switch (type) {
    'car' => Icons.directions_car,
    'motorcycle' => Icons.motorcycle,
    'bike' => Icons.pedal_bike,
    'truck' => Icons.local_shipping,
    _ => Icons.help_outline,
  };
}
