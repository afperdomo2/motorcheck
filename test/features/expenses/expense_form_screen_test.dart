import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/expenses/models/expense_category.dart';
import 'package:motorcheck/features/expenses/providers.dart';
import 'package:motorcheck/features/expenses/screens/expense_form_screen.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

class _FakeVehicleRepository extends VehicleRepository {
  _FakeVehicleRepository(this.vehicle);

  final Vehicle vehicle;

  @override
  Future<Vehicle?> getById(int id) async => vehicle;
}

void main() {
  testWidgets('valida el valor antes de guardar un gasto', (tester) async {
    final now = DateTime(2026, 11, 17);
    final vehicle = Vehicle(
      id: 1,
      name: 'Mazda 33',
      type: 'car',
      createdAt: now,
      updatedAt: now,
    );
    final category = ExpenseCategory(
      id: 1,
      key: 'other',
      name: 'Otro',
      iconName: 'receipt_long',
      createdAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleRepositoryProvider.overrideWithValue(
            _FakeVehicleRepository(vehicle),
          ),
          expenseCategoriesProvider.overrideWith((ref) async => [category]),
        ],
        child: const MaterialApp(home: ExpenseFormScreen(vehicleId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar gasto'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa un valor válido'), findsOneWidget);
  });
}
