import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

Vehicle _vehicle(int id) {
  return Vehicle(
    id: id,
    name: 'Vehículo $id',
    type: 'car',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

void main() {
  test('suma mantenimiento, combustible, otros y gastos globales', () async {
    final container = ProviderContainer(
      overrides: [
        vehiclesProvider.overrideWith(
          (ref) async => [_vehicle(1), _vehicle(2)],
        ),
        vehicleMonthBreakdownProvider(1).overrideWith(
          (ref) async => const MonthSpendBreakdown(
            maintenance: 100,
            fuel: 50,
            expenses: 25,
          ),
        ),
        vehicleMonthBreakdownProvider(2).overrideWith(
          (ref) async => const MonthSpendBreakdown(
            maintenance: 200,
            fuel: 100,
            expenses: 50,
          ),
        ),
        globalMonthExpensesProvider.overrideWith((ref) async => 30),
      ],
    );
    addTearDown(container.dispose);

    final breakdown = await container.read(fleetMonthBreakdownProvider.future);

    expect(breakdown.maintenance, 300);
    expect(breakdown.fuel, 150);
    expect(breakdown.expenses, 105);
    expect(breakdown.total, 555);
  });
}
