// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Maintenance {

 int? get id; int get vehicleId; DateTime get date; int? get mileage; double get maintenanceCost; double get totalPartsCost; int? get workshopId; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Maintenance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceCopyWith<Maintenance> get copyWith => _$MaintenanceCopyWithImpl<Maintenance>(this as Maintenance, _$identity);

  /// Serializes this Maintenance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Maintenance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Maintenance&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.mileage, _this.mileage) || other.mileage == _this.mileage)&&(identical(other.maintenanceCost, _this.maintenanceCost) || other.maintenanceCost == _this.maintenanceCost)&&(identical(other.totalPartsCost, _this.totalPartsCost) || other.totalPartsCost == _this.totalPartsCost)&&(identical(other.workshopId, _this.workshopId) || other.workshopId == _this.workshopId)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Maintenance;
  return Object.hash(runtimeType,_this.id,_this.vehicleId,_this.date,_this.mileage,_this.maintenanceCost,_this.totalPartsCost,_this.workshopId,_this.notes,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Maintenance;
  return 'Maintenance(id: ${_this.id}, vehicleId: ${_this.vehicleId}, date: ${_this.date}, mileage: ${_this.mileage}, maintenanceCost: ${_this.maintenanceCost}, totalPartsCost: ${_this.totalPartsCost}, workshopId: ${_this.workshopId}, notes: ${_this.notes}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $MaintenanceCopyWith<$Res>  {
  factory $MaintenanceCopyWith(Maintenance value, $Res Function(Maintenance) _then) = _$MaintenanceCopyWithImpl;
@useResult
$Res call({
 int? id, int vehicleId, DateTime date, int? mileage, double maintenanceCost, double totalPartsCost, int? workshopId, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$MaintenanceCopyWithImpl<$Res>
    implements $MaintenanceCopyWith<$Res> {
  _$MaintenanceCopyWithImpl(this._self, this._then);

  final Maintenance _self;
  final $Res Function(Maintenance) _then;

/// Create a copy of Maintenance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleId = null,Object? date = null,Object? mileage = freezed,Object? maintenanceCost = null,Object? totalPartsCost = null,Object? workshopId = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Maintenance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,mileage: freezed == mileage ? _self.mileage : mileage // ignore: cast_nullable_to_non_nullable
as int?,maintenanceCost: null == maintenanceCost ? _self.maintenanceCost : maintenanceCost // ignore: cast_nullable_to_non_nullable
as double,totalPartsCost: null == totalPartsCost ? _self.totalPartsCost : totalPartsCost // ignore: cast_nullable_to_non_nullable
as double,workshopId: freezed == workshopId ? _self.workshopId : workshopId // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Maintenance].
extension MaintenancePatterns on Maintenance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Maintenance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Maintenance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Maintenance value)  $default,){
final _that = this;
switch (_that) {
case _Maintenance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Maintenance value)?  $default,){
final _that = this;
switch (_that) {
case _Maintenance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  DateTime date,  int? mileage,  double maintenanceCost,  double totalPartsCost,  int? workshopId,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Maintenance() when $default != null:
return $default(_that.id,_that.vehicleId,_that.date,_that.mileage,_that.maintenanceCost,_that.totalPartsCost,_that.workshopId,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  DateTime date,  int? mileage,  double maintenanceCost,  double totalPartsCost,  int? workshopId,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Maintenance():
return $default(_that.id,_that.vehicleId,_that.date,_that.mileage,_that.maintenanceCost,_that.totalPartsCost,_that.workshopId,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int vehicleId,  DateTime date,  int? mileage,  double maintenanceCost,  double totalPartsCost,  int? workshopId,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Maintenance() when $default != null:
return $default(_that.id,_that.vehicleId,_that.date,_that.mileage,_that.maintenanceCost,_that.totalPartsCost,_that.workshopId,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Maintenance implements Maintenance {
  const _Maintenance({this.id, required this.vehicleId, required this.date, this.mileage, this.maintenanceCost = 0, this.totalPartsCost = 0, this.workshopId, this.notes, required this.createdAt, required this.updatedAt});
  factory _Maintenance.fromJson(Map<String, dynamic> json) => _$MaintenanceFromJson(json);

@override final  int? id;
@override final  int vehicleId;
@override final  DateTime date;
@override final  int? mileage;
@override@JsonKey() final  double maintenanceCost;
@override@JsonKey() final  double totalPartsCost;
@override final  int? workshopId;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Maintenance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceCopyWith<_Maintenance> get copyWith => __$MaintenanceCopyWithImpl<_Maintenance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Maintenance&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.date, date) || other.date == date)&&(identical(other.mileage, mileage) || other.mileage == mileage)&&(identical(other.maintenanceCost, maintenanceCost) || other.maintenanceCost == maintenanceCost)&&(identical(other.totalPartsCost, totalPartsCost) || other.totalPartsCost == totalPartsCost)&&(identical(other.workshopId, workshopId) || other.workshopId == workshopId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleId,date,mileage,maintenanceCost,totalPartsCost,workshopId,notes,createdAt,updatedAt);
}

@override
String toString() {
    return 'Maintenance(id: $id, vehicleId: $vehicleId, date: $date, mileage: $mileage, maintenanceCost: $maintenanceCost, totalPartsCost: $totalPartsCost, workshopId: $workshopId, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceCopyWith<$Res> implements $MaintenanceCopyWith<$Res> {
  factory _$MaintenanceCopyWith(_Maintenance value, $Res Function(_Maintenance) _then) = __$MaintenanceCopyWithImpl;
@override @useResult
$Res call({
 int? id, int vehicleId, DateTime date, int? mileage, double maintenanceCost, double totalPartsCost, int? workshopId, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$MaintenanceCopyWithImpl<$Res>
    implements _$MaintenanceCopyWith<$Res> {
  __$MaintenanceCopyWithImpl(this._self, this._then);

  final _Maintenance _self;
  final $Res Function(_Maintenance) _then;

/// Create a copy of Maintenance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleId = null,Object? date = null,Object? mileage = freezed,Object? maintenanceCost = null,Object? totalPartsCost = null,Object? workshopId = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Maintenance(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,mileage: freezed == mileage ? _self.mileage : mileage // ignore: cast_nullable_to_non_nullable
as int?,maintenanceCost: null == maintenanceCost ? _self.maintenanceCost : maintenanceCost // ignore: cast_nullable_to_non_nullable
as double,totalPartsCost: null == totalPartsCost ? _self.totalPartsCost : totalPartsCost // ignore: cast_nullable_to_non_nullable
as double,workshopId: freezed == workshopId ? _self.workshopId : workshopId // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
