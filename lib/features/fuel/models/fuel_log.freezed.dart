// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fuel_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FuelLog {

 int? get id; int get vehicleId; DateTime get date; int get odometer; double get quantity; double get unitPrice; double get totalCost; String get fuelType; String? get station; bool get fullTank; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of FuelLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FuelLogCopyWith<FuelLog> get copyWith => _$FuelLogCopyWithImpl<FuelLog>(this as FuelLog, _$identity);

  /// Serializes this FuelLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FuelLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FuelLog&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.odometer, _this.odometer) || other.odometer == _this.odometer)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.totalCost, _this.totalCost) || other.totalCost == _this.totalCost)&&(identical(other.fuelType, _this.fuelType) || other.fuelType == _this.fuelType)&&(identical(other.station, _this.station) || other.station == _this.station)&&(identical(other.fullTank, _this.fullTank) || other.fullTank == _this.fullTank)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FuelLog;
  return Object.hash(runtimeType,_this.id,_this.vehicleId,_this.date,_this.odometer,_this.quantity,_this.unitPrice,_this.totalCost,_this.fuelType,_this.station,_this.fullTank,_this.notes,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as FuelLog;
  return 'FuelLog(id: ${_this.id}, vehicleId: ${_this.vehicleId}, date: ${_this.date}, odometer: ${_this.odometer}, quantity: ${_this.quantity}, unitPrice: ${_this.unitPrice}, totalCost: ${_this.totalCost}, fuelType: ${_this.fuelType}, station: ${_this.station}, fullTank: ${_this.fullTank}, notes: ${_this.notes}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $FuelLogCopyWith<$Res>  {
  factory $FuelLogCopyWith(FuelLog value, $Res Function(FuelLog) _then) = _$FuelLogCopyWithImpl;
@useResult
$Res call({
 int? id, int vehicleId, DateTime date, int odometer, double quantity, double unitPrice, double totalCost, String fuelType, String? station, bool fullTank, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$FuelLogCopyWithImpl<$Res>
    implements $FuelLogCopyWith<$Res> {
  _$FuelLogCopyWithImpl(this._self, this._then);

  final FuelLog _self;
  final $Res Function(FuelLog) _then;

/// Create a copy of FuelLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleId = null,Object? date = null,Object? odometer = null,Object? quantity = null,Object? unitPrice = null,Object? totalCost = null,Object? fuelType = null,Object? station = freezed,Object? fullTank = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(FuelLog(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,odometer: null == odometer ? _self.odometer : odometer // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as String,station: freezed == station ? _self.station : station // ignore: cast_nullable_to_non_nullable
as String?,fullTank: null == fullTank ? _self.fullTank : fullTank // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FuelLog].
extension FuelLogPatterns on FuelLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FuelLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FuelLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FuelLog value)  $default,){
final _that = this;
switch (_that) {
case _FuelLog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FuelLog value)?  $default,){
final _that = this;
switch (_that) {
case _FuelLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  DateTime date,  int odometer,  double quantity,  double unitPrice,  double totalCost,  String fuelType,  String? station,  bool fullTank,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FuelLog() when $default != null:
return $default(_that.id,_that.vehicleId,_that.date,_that.odometer,_that.quantity,_that.unitPrice,_that.totalCost,_that.fuelType,_that.station,_that.fullTank,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  DateTime date,  int odometer,  double quantity,  double unitPrice,  double totalCost,  String fuelType,  String? station,  bool fullTank,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FuelLog():
return $default(_that.id,_that.vehicleId,_that.date,_that.odometer,_that.quantity,_that.unitPrice,_that.totalCost,_that.fuelType,_that.station,_that.fullTank,_that.notes,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int vehicleId,  DateTime date,  int odometer,  double quantity,  double unitPrice,  double totalCost,  String fuelType,  String? station,  bool fullTank,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FuelLog() when $default != null:
return $default(_that.id,_that.vehicleId,_that.date,_that.odometer,_that.quantity,_that.unitPrice,_that.totalCost,_that.fuelType,_that.station,_that.fullTank,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FuelLog implements FuelLog {
  const _FuelLog({this.id, required this.vehicleId, required this.date, required this.odometer, required this.quantity, this.unitPrice = 0, this.totalCost = 0, this.fuelType = 'gasoline', this.station, this.fullTank = true, this.notes, required this.createdAt, required this.updatedAt});
  factory _FuelLog.fromJson(Map<String, dynamic> json) => _$FuelLogFromJson(json);

@override final  int? id;
@override final  int vehicleId;
@override final  DateTime date;
@override final  int odometer;
@override final  double quantity;
@override@JsonKey() final  double unitPrice;
@override@JsonKey() final  double totalCost;
@override@JsonKey() final  String fuelType;
@override final  String? station;
@override@JsonKey() final  bool fullTank;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of FuelLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FuelLogCopyWith<_FuelLog> get copyWith => __$FuelLogCopyWithImpl<_FuelLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FuelLogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FuelLog&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.date, date) || other.date == date)&&(identical(other.odometer, odometer) || other.odometer == odometer)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.fuelType, fuelType) || other.fuelType == fuelType)&&(identical(other.station, station) || other.station == station)&&(identical(other.fullTank, fullTank) || other.fullTank == fullTank)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleId,date,odometer,quantity,unitPrice,totalCost,fuelType,station,fullTank,notes,createdAt,updatedAt);
}

@override
String toString() {
    return 'FuelLog(id: $id, vehicleId: $vehicleId, date: $date, odometer: $odometer, quantity: $quantity, unitPrice: $unitPrice, totalCost: $totalCost, fuelType: $fuelType, station: $station, fullTank: $fullTank, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FuelLogCopyWith<$Res> implements $FuelLogCopyWith<$Res> {
  factory _$FuelLogCopyWith(_FuelLog value, $Res Function(_FuelLog) _then) = __$FuelLogCopyWithImpl;
@override @useResult
$Res call({
 int? id, int vehicleId, DateTime date, int odometer, double quantity, double unitPrice, double totalCost, String fuelType, String? station, bool fullTank, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$FuelLogCopyWithImpl<$Res>
    implements _$FuelLogCopyWith<$Res> {
  __$FuelLogCopyWithImpl(this._self, this._then);

  final _FuelLog _self;
  final $Res Function(_FuelLog) _then;

/// Create a copy of FuelLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleId = null,Object? date = null,Object? odometer = null,Object? quantity = null,Object? unitPrice = null,Object? totalCost = null,Object? fuelType = null,Object? station = freezed,Object? fullTank = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_FuelLog(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,odometer: null == odometer ? _self.odometer : odometer // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalCost: null == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double,fuelType: null == fuelType ? _self.fuelType : fuelType // ignore: cast_nullable_to_non_nullable
as String,station: freezed == station ? _self.station : station // ignore: cast_nullable_to_non_nullable
as String?,fullTank: null == fullTank ? _self.fullTank : fullTank // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
