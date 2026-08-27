import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:motorcheck/features/maintenance/models/maintenance.dart';
import 'package:motorcheck/features/maintenance/models/maintenance_item.dart';
import 'package:motorcheck/features/maintenance/models/workshop.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/maintenance/repository.dart';
import 'package:motorcheck/features/maintenance/screens/maintenance_detail_screen.dart';
import 'package:motorcheck/features/settings/models/maintenance_category.dart';
import 'package:motorcheck/features/settings/providers.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es');
  });

  testWidgets('tocar un item abre el historial de la categoría', (
    tester,
  ) async {
    final maintenance = Maintenance(
      id: 1,
      vehicleId: 1,
      date: DateTime(2024, 3, 15),
      mileage: 6000,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    final item = MaintenanceItem(
      id: 1,
      maintenanceId: 1,
      category: 'car_oil',
      partsCost: 50,
      notes: 'Sintético',
      createdAt: DateTime(2024),
    );
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
      currentMileage: 6000,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    final upcoming = UpcomingMaintenance(
      category: category,
      lastMileage: 5000,
      remainingKm: 10,
      isOverdue: false,
      isWarning: true,
    );
    final history = <CategoryHistoryEntry>[
      (
        date: DateTime(2024, 3, 15),
        mileage: 6000,
        partsCost: 50,
        notes: 'Sintético',
        maintenanceNotes: null,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          maintenanceByIdProvider(1).overrideWith((ref) async => maintenance),
          maintenanceItemsProvider(1).overrideWith((ref) async => [item]),
          workshopsProvider.overrideWith((ref) async => <Workshop>[]),
          maintenanceCategoriesProvider.overrideWith((ref) async => [category]),
          vehicleNamesProvider.overrideWith((ref) async => {1: vehicle}),
          upcomingMaintenanceProvider(
            1,
          ).overrideWith((ref) async => [upcoming]),
          maintenanceCategoryHistoryProvider((
            vehicleId: 1,
            category: 'car_oil',
          )).overrideWith((ref) async => history),
        ],
        child: const MaterialApp(
          home: MaintenanceDetailScreen(maintenanceId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aceite'), findsOneWidget);

    await tester.tap(find.text('Aceite'));
    await tester.pumpAndSettle();

    expect(find.text('Kilometraje actual'), findsOneWidget);
    expect(find.text('Próximo mantenimiento'), findsOneWidget);
  });
}
