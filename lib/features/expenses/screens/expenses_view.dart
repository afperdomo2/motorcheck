import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/files/file_storage.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/user_error.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../models/expense.dart';
import '../providers.dart';
import '../widgets/expense_card.dart';

class ExpensesView extends ConsumerWidget {
  const ExpensesView({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesForVehicleProvider(vehicleId));
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(expensesForVehicleProvider(vehicleId));
        ref.invalidate(expenseCategoriesProvider);
        await ref.read(expensesForVehicleProvider(vehicleId).future);
      },
      child: expensesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorState(
          message: 'No se pudieron cargar los gastos',
          onRetry: () => ref.invalidate(expensesForVehicleProvider(vehicleId)),
        ),
        data: (expenses) {
          if (expenses.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Sin gastos',
              subtitle: 'Registra seguro, impuesto, peajes, parqueadero y más',
              onAction: () => _openForm(context),
              actionLabel: 'Registrar gasto',
            );
          }

          final categories = categoriesAsync.valueOrNull ?? [];
          final categoryMap = {
            for (final category in categories) category.key: category,
          };
          final now = DateTime.now();
          final monthTotal = expenses
              .where(
                (expense) =>
                    expense.date.year == now.year &&
                    expense.date.month == now.month,
              )
              .fold<double>(0, (sum, expense) => sum + expense.amount);
          final hasGlobal = expenses.any(
            (expense) => expense.vehicleId == null,
          );

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gastos de ${formatMonthYearLong(now)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              formatCurrency(monthTotal),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            if (hasGlobal)
                              Text(
                                'Incluye gastos globales',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${expenses.length} registro'
                        '${expenses.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final expense in expenses)
                ExpenseCard(
                  expense: expense,
                  category: categoryMap[expense.categoryKey],
                  onTap: () => _openForm(context, expense: expense),
                  onDelete: () => _delete(context, ref, expense),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {Expense? expense}) {
    if (expense == null) {
      context.push('/finance/expenses/add?vehicleId=$vehicleId');
    } else {
      context.push('/finance/expenses/${expense.id}/edit');
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Eliminar gasto',
      message:
          '¿Eliminar ${formatCurrency(expense.amount)} del '
          '${formatDisplayDate(expense.date)}?',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(expensesNotifierProvider.notifier)
          .remove(expense.id!, vehicleId: expense.vehicleId);
      await deleteAttachmentFile(expense.receiptPath);
      AppSnackBar.success('Gasto eliminado');
    } catch (error) {
      logError('eliminar gasto', error, StackTrace.current);
      AppSnackBar.error(
        friendlyErrorMessage(error, fallback: 'No se pudo eliminar el gasto'),
      );
    }
  }
}
