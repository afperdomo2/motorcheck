import 'package:flutter/material.dart';

const expenseIconNames = <String>[
  'receipt_long',
  'security',
  'account_balance',
  'toll',
  'local_parking',
  'gavel',
  'local_car_wash',
  'shopping_bag',
  'directions_car',
  'build',
  'payments',
  'more_horiz',
];

const _expenseIcons = <String, IconData>{
  'receipt_long': Icons.receipt_long,
  'security': Icons.security,
  'account_balance': Icons.account_balance,
  'toll': Icons.toll,
  'local_parking': Icons.local_parking,
  'gavel': Icons.gavel,
  'local_car_wash': Icons.local_car_wash,
  'shopping_bag': Icons.shopping_bag,
  'directions_car': Icons.directions_car,
  'build': Icons.build,
  'payments': Icons.payments,
  'more_horiz': Icons.more_horiz,
};

IconData expenseIconFor(String name) {
  return _expenseIcons[name] ?? Icons.receipt_long;
}

String expenseIconLabel(String name) {
  return switch (name) {
    'receipt_long' => 'Recibo',
    'security' => 'Seguro',
    'account_balance' => 'Impuesto',
    'toll' => 'Peaje',
    'local_parking' => 'Parqueadero',
    'gavel' => 'Multa',
    'local_car_wash' => 'Lavado',
    'shopping_bag' => 'Accesorio',
    'directions_car' => 'Vehículo',
    'build' => 'Taller',
    'payments' => 'Pago',
    _ => 'Otro',
  };
}
