import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/shared/widgets/category_history_sheet.dart';

void main() {
  testWidgets(
    'CategoryHistoryView muestra km actual, alerta e historial ordenado',
    (tester) async {
      final category = MaintenanceCategory(
        id: 1,
        key: 'car_oil',
        name: 'Aceite',
        vehicleType: 'car',
        intervalKm: 1000,
        warningKm: 20,
        createdAt: DateTime(2024),
      );
      final vehicle = Vehicle(
        id: 1,
        name: 'Toyota',
        type: 'car',
        currentMileage: 6790,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final upcoming = UpcomingMaintenance(
        category: category,
        lastMileage: 5800,
        remainingKm: 10,
        isOverdue: false,
        isWarning: true,
      );
      final history = <CategoryHistoryEntry>[
        (
          date: DateTime(2024, 3, 15),
          mileage: 5800,
          partsCost: 50,
          notes: 'Sintético',
          maintenanceNotes: null,
        ),
        (
          date: DateTime(2024, 1, 10),
          mileage: 4500,
          partsCost: 40,
          notes: null,
          maintenanceNotes: 'Cambio de aceite',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            upcomingMaintenanceProvider(
              1,
            ).overrideWith((ref) async => [upcoming]),
            maintenanceCategoryHistoryProvider((
              vehicleId: 1,
              category: 'car_oil',
            )).overrideWith((ref) async => history),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CategoryHistoryView(vehicle: vehicle, category: category),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kilometraje actual'), findsOneWidget);
      expect(find.text('6,790 km'), findsOneWidget);

      expect(find.text('En 10 km'), findsOneWidget);
      expect(find.text('6,800 km'), findsOneWidget);
      expect(find.text('10 km'), findsOneWidget);
      expect(find.text('Último: 5,800 km'), findsOneWidget);

      expect(find.text('Historial'), findsOneWidget);
      expect(find.text('Sintético'), findsOneWidget);
      expect(find.text('Cambio de aceite'), findsOneWidget);
      expect(find.text('5,800 km'), findsOneWidget);
      expect(find.text('4,500 km'), findsOneWidget);

      expect(
        tester.getTopLeft(find.text('Sintético')).dy,
        lessThan(tester.getTopLeft(find.text('Cambio de aceite')).dy),
      );
    },
  );
}
