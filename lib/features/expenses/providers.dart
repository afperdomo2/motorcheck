import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/expense.dart';
import 'models/expense_category.dart';
import 'repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expenseCategoryRepositoryProvider = Provider<ExpenseCategoryRepository>((
  ref,
) {
  return ExpenseCategoryRepository();
});

final expenseCategoriesProvider = FutureProvider<List<ExpenseCategory>>((
  ref,
) async {
  return ref.watch(expenseCategoryRepositoryProvider).getAll();
});

/// Gastos exclusivos del vehículo (sin globales), para sumatorias.
final vehicleExpensesProvider = FutureProvider.family<List<Expense>, int>((
  ref,
  vehicleId,
) async {
  return ref
      .watch(expenseRepositoryProvider)
      .getForVehicle(vehicleId, includeGlobal: false);
});

/// Lista de pantalla: incluye gastos globales.
final expensesForVehicleProvider = FutureProvider.family<List<Expense>, int>((
  ref,
  vehicleId,
) async {
  return ref.watch(expenseRepositoryProvider).getForVehicle(vehicleId);
});

final globalExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  return ref.watch(expenseRepositoryProvider).getGlobal();
});

final allExpensesProvider = FutureProvider<List<Expense>>((ref) async {
  return ref.watch(expenseRepositoryProvider).getAll();
});

final expenseByIdProvider = FutureProvider.family<Expense?, int>((
  ref,
  id,
) async {
  return ref.watch(expenseRepositoryProvider).getById(id);
});

class ExpensesNotifier extends Notifier<AsyncValue<void>> {
  ExpenseRepository get _repo => ref.read(expenseRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> save(Expense expense) async {
    state = const AsyncValue.loading();
    try {
      if (expense.id == null) {
        await _repo.insert(expense);
      } else {
        await _repo.update(expense);
      }
      _invalidate(expense.vehicleId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> remove(int id, {int? vehicleId}) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      _invalidate(vehicleId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void _invalidate(int? vehicleId) {
    ref.invalidate(allExpensesProvider);
    ref.invalidate(globalExpensesProvider);
    ref.invalidate(expensesForVehicleProvider);
    if (vehicleId != null) {
      ref.invalidate(vehicleExpensesProvider(vehicleId));
    }
    ref.invalidate(expenseByIdProvider);
  }
}

final expensesNotifierProvider =
    NotifierProvider<ExpensesNotifier, AsyncValue<void>>(ExpensesNotifier.new);

class ExpenseCategoriesNotifier extends Notifier<AsyncValue<void>> {
  ExpenseCategoryRepository get _repo =>
      ref.read(expenseCategoryRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> save(ExpenseCategory category) async {
    state = const AsyncValue.loading();
    try {
      if (category.id == null) {
        await _repo.insert(category);
      } else {
        await _repo.update(category);
      }
      ref.invalidate(expenseCategoriesProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> remove(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(id);
      ref.invalidate(expenseCategoriesProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final expenseCategoriesNotifierProvider =
    NotifierProvider<ExpenseCategoriesNotifier, AsyncValue<void>>(
      ExpenseCategoriesNotifier.new,
    );
