// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: (json['id'] as num?)?.toInt(),
  vehicleId: (json['vehicleId'] as num?)?.toInt(),
  categoryKey: json['categoryKey'] as String,
  date: DateTime.parse(json['date'] as String),
  amount: (json['amount'] as num).toDouble(),
  notes: json['notes'] as String?,
  receiptPath: json['receiptPath'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'vehicleId': instance.vehicleId,
  'categoryKey': instance.categoryKey,
  'date': instance.date.toIso8601String(),
  'amount': instance.amount,
  'notes': instance.notes,
  'receiptPath': instance.receiptPath,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
