import 'package:flutter_test/flutter_test.dart';
import '../../helpers/database_test_helper.dart';
import 'package:motorcheck/features/expenses/models/expense.dart';
import 'package:motorcheck/features/expenses/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/repository.dart';

void main() {
  setUpAll(TestDatabase.setUp);

  tearDownAll(TestDatabase.tearDown);

  test('categorías, gastos por vehículo y globales', () async {
    final vehicleRepo = VehicleRepository();
    final categoryRepo = ExpenseCategoryRepository();
    final expenseRepo = ExpenseRepository();
    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'Gastos',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    final now = DateTime(2026, 1, 1);

    final categories = await categoryRepo.getAll();
    expect(categories.map((c) => c.key), contains('insurance'));
    expect(categories.map((c) => c.key), contains('other'));

    final vehicleExpenseId = await expenseRepo.insert(
      Expense(
        vehicleId: vehicleId,
        categoryKey: 'insurance',
        date: now,
        amount: 380000,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final globalExpenseId = await expenseRepo.insert(
      Expense(
        categoryKey: 'tolls',
        date: now,
        amount: 18000,
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(
      await expenseRepo.getForVehicle(vehicleId, includeGlobal: false),
      hasLength(1),
    );
    expect(await expenseRepo.getForVehicle(vehicleId), hasLength(2));
    expect(await expenseRepo.getGlobal(), hasLength(1));

    final loaded = await expenseRepo.getById(vehicleExpenseId);
    await expenseRepo.update(
      loaded!.copyWith(amount: 400000, notes: 'Actualizado'),
    );
    expect((await expenseRepo.getById(vehicleExpenseId))!.amount, 400000);

    await expenseRepo.delete(globalExpenseId);
    expect(await expenseRepo.getGlobal(), isEmpty);
  });

  test('no elimina una categoría en uso', () async {
    final vehicleRepo = VehicleRepository();
    final categoryRepo = ExpenseCategoryRepository();
    final expenseRepo = ExpenseRepository();
    final vehicleId = await vehicleRepo.insert(
      Vehicle(
        name: 'Categoría en uso',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
    final now = DateTime(2026, 1, 1);
    await expenseRepo.insert(
      Expense(
        vehicleId: vehicleId,
        categoryKey: 'insurance',
        date: now,
        amount: 1000,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final category = (await categoryRepo.getAll()).firstWhere(
      (c) => c.key == 'insurance',
    );

    expect(
      () => categoryRepo.delete(category.id!),
      throwsA(isA<ExpenseCategoryInUseException>()),
    );
  });
}
