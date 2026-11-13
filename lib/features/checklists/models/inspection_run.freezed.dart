// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InspectionRun {

 int? get id; int get vehicleId; int get checklistId; DateTime get date; int? get odometer; String? get notes; DateTime get createdAt;
/// Create a copy of InspectionRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionRunCopyWith<InspectionRun> get copyWith => _$InspectionRunCopyWithImpl<InspectionRun>(this as InspectionRun, _$identity);

  /// Serializes this InspectionRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InspectionRun;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionRun&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.checklistId, _this.checklistId) || other.checklistId == _this.checklistId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.odometer, _this.odometer) || other.odometer == _this.odometer)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InspectionRun;
  return Object.hash(runtimeType,_this.id,_this.vehicleId,_this.checklistId,_this.date,_this.odometer,_this.notes,_this.createdAt);
}

@override
String toString() {
  final _this = this as InspectionRun;
  return 'InspectionRun(id: ${_this.id}, vehicleId: ${_this.vehicleId}, checklistId: ${_this.checklistId}, date: ${_this.date}, odometer: ${_this.odometer}, notes: ${_this.notes}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $InspectionRunCopyWith<$Res>  {
  factory $InspectionRunCopyWith(InspectionRun value, $Res Function(InspectionRun) _then) = _$InspectionRunCopyWithImpl;
@useResult
$Res call({
 int? id, int vehicleId, int checklistId, DateTime date, int? odometer, String? notes, DateTime createdAt
});




}
/// @nodoc
class _$InspectionRunCopyWithImpl<$Res>
    implements $InspectionRunCopyWith<$Res> {
  _$InspectionRunCopyWithImpl(this._self, this._then);

  final InspectionRun _self;
  final $Res Function(InspectionRun) _then;

/// Create a copy of InspectionRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleId = null,Object? checklistId = null,Object? date = null,Object? odometer = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(InspectionRun(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,checklistId: null == checklistId ? _self.checklistId : checklistId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,odometer: freezed == odometer ? _self.odometer : odometer // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionRun].
extension InspectionRunPatterns on InspectionRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionRun value)  $default,){
final _that = this;
switch (_that) {
case _InspectionRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionRun value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  int checklistId,  DateTime date,  int? odometer,  String? notes,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionRun() when $default != null:
return $default(_that.id,_that.vehicleId,_that.checklistId,_that.date,_that.odometer,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  int checklistId,  DateTime date,  int? odometer,  String? notes,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InspectionRun():
return $default(_that.id,_that.vehicleId,_that.checklistId,_that.date,_that.odometer,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int vehicleId,  int checklistId,  DateTime date,  int? odometer,  String? notes,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InspectionRun() when $default != null:
return $default(_that.id,_that.vehicleId,_that.checklistId,_that.date,_that.odometer,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionRun implements InspectionRun {
  const _InspectionRun({this.id, required this.vehicleId, required this.checklistId, required this.date, this.odometer, this.notes, required this.createdAt});
  factory _InspectionRun.fromJson(Map<String, dynamic> json) => _$InspectionRunFromJson(json);

@override final  int? id;
@override final  int vehicleId;
@override final  int checklistId;
@override final  DateTime date;
@override final  int? odometer;
@override final  String? notes;
@override final  DateTime createdAt;

/// Create a copy of InspectionRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionRunCopyWith<_InspectionRun> get copyWith => __$InspectionRunCopyWithImpl<_InspectionRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionRunToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionRun&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.checklistId, checklistId) || other.checklistId == checklistId)&&(identical(other.date, date) || other.date == date)&&(identical(other.odometer, odometer) || other.odometer == odometer)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleId,checklistId,date,odometer,notes,createdAt);
}

@override
String toString() {
    return 'InspectionRun(id: $id, vehicleId: $vehicleId, checklistId: $checklistId, date: $date, odometer: $odometer, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InspectionRunCopyWith<$Res> implements $InspectionRunCopyWith<$Res> {
  factory _$InspectionRunCopyWith(_InspectionRun value, $Res Function(_InspectionRun) _then) = __$InspectionRunCopyWithImpl;
@override @useResult
$Res call({
 int? id, int vehicleId, int checklistId, DateTime date, int? odometer, String? notes, DateTime createdAt
});




}
/// @nodoc
class __$InspectionRunCopyWithImpl<$Res>
    implements _$InspectionRunCopyWith<$Res> {
  __$InspectionRunCopyWithImpl(this._self, this._then);

  final _InspectionRun _self;
  final $Res Function(_InspectionRun) _then;

/// Create a copy of InspectionRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleId = null,Object? checklistId = null,Object? date = null,Object? odometer = freezed,Object? notes = freezed,Object? createdAt = null,}) {
  return _then(_InspectionRun(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,checklistId: null == checklistId ? _self.checklistId : checklistId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,odometer: freezed == odometer ? _self.odometer : odometer // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
