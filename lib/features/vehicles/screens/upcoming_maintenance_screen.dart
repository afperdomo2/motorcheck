import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../maintenance/widgets/upcoming_maintenance_view.dart';

class UpcomingMaintenanceScreen extends ConsumerWidget {
  final int vehicleId;

  const UpcomingMaintenanceScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Próximos mantenimientos')),
      body: UpcomingMaintenanceView(vehicleId: vehicleId),
    );
  }
}
