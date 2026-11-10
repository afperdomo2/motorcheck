// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_restriction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleRestriction {

 int? get id; int get vehicleId; bool get enabled; String? get city; List<int> get days; String get startTime; String get endTime; bool get exempt; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of VehicleRestriction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleRestrictionCopyWith<VehicleRestriction> get copyWith => _$VehicleRestrictionCopyWithImpl<VehicleRestriction>(this as VehicleRestriction, _$identity);

  /// Serializes this VehicleRestriction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VehicleRestriction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleRestriction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.city, _this.city) || other.city == _this.city)&&const DeepCollectionEquality().equals(other.days, _this.days)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.endTime, _this.endTime) || other.endTime == _this.endTime)&&(identical(other.exempt, _this.exempt) || other.exempt == _this.exempt)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VehicleRestriction;
  return Object.hash(runtimeType,_this.id,_this.vehicleId,_this.enabled,_this.city,const DeepCollectionEquality().hash(_this.days),_this.startTime,_this.endTime,_this.exempt,_this.notes,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as VehicleRestriction;
  return 'VehicleRestriction(id: ${_this.id}, vehicleId: ${_this.vehicleId}, enabled: ${_this.enabled}, city: ${_this.city}, days: ${_this.days}, startTime: ${_this.startTime}, endTime: ${_this.endTime}, exempt: ${_this.exempt}, notes: ${_this.notes}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $VehicleRestrictionCopyWith<$Res>  {
  factory $VehicleRestrictionCopyWith(VehicleRestriction value, $Res Function(VehicleRestriction) _then) = _$VehicleRestrictionCopyWithImpl;
@useResult
$Res call({
 int? id, int vehicleId, bool enabled, String? city, List<int> days, String startTime, String endTime, bool exempt, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$VehicleRestrictionCopyWithImpl<$Res>
    implements $VehicleRestrictionCopyWith<$Res> {
  _$VehicleRestrictionCopyWithImpl(this._self, this._then);

  final VehicleRestriction _self;
  final $Res Function(VehicleRestriction) _then;

/// Create a copy of VehicleRestriction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleId = null,Object? enabled = null,Object? city = freezed,Object? days = null,Object? startTime = null,Object? endTime = null,Object? exempt = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(VehicleRestriction(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<int>,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,exempt: null == exempt ? _self.exempt : exempt // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleRestriction].
extension VehicleRestrictionPatterns on VehicleRestriction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleRestriction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleRestriction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleRestriction value)  $default,){
final _that = this;
switch (_that) {
case _VehicleRestriction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleRestriction value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleRestriction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  bool enabled,  String? city,  List<int> days,  String startTime,  String endTime,  bool exempt,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleRestriction() when $default != null:
return $default(_that.id,_that.vehicleId,_that.enabled,_that.city,_that.days,_that.startTime,_that.endTime,_that.exempt,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  bool enabled,  String? city,  List<int> days,  String startTime,  String endTime,  bool exempt,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _VehicleRestriction():
return $default(_that.id,_that.vehicleId,_that.enabled,_that.city,_that.days,_that.startTime,_that.endTime,_that.exempt,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int vehicleId,  bool enabled,  String? city,  List<int> days,  String startTime,  String endTime,  bool exempt,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _VehicleRestriction() when $default != null:
return $default(_that.id,_that.vehicleId,_that.enabled,_that.city,_that.days,_that.startTime,_that.endTime,_that.exempt,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleRestriction implements VehicleRestriction {
  const _VehicleRestriction({this.id, required this.vehicleId, this.enabled = false, this.city,  List<int> days = const <int>[], this.startTime = '06:00', this.endTime = '21:00', this.exempt = false, this.notes, required this.createdAt, required this.updatedAt}): _days = days;
  factory _VehicleRestriction.fromJson(Map<String, dynamic> json) => _$VehicleRestrictionFromJson(json);

@override final  int? id;
@override final  int vehicleId;
@override@JsonKey() final  bool enabled;
@override final  String? city;
 final  List<int> _days;
@override@JsonKey() List<int> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override@JsonKey() final  String startTime;
@override@JsonKey() final  String endTime;
@override@JsonKey() final  bool exempt;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of VehicleRestriction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleRestrictionCopyWith<_VehicleRestriction> get copyWith => __$VehicleRestrictionCopyWithImpl<_VehicleRestriction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleRestrictionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleRestriction&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.days, _days)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.exempt, exempt) || other.exempt == exempt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleId,enabled,city,const DeepCollectionEquality().hash(_days),startTime,endTime,exempt,notes,createdAt,updatedAt);
}

@override
String toString() {
    return 'VehicleRestriction(id: $id, vehicleId: $vehicleId, enabled: $enabled, city: $city, days: $days, startTime: $startTime, endTime: $endTime, exempt: $exempt, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VehicleRestrictionCopyWith<$Res> implements $VehicleRestrictionCopyWith<$Res> {
  factory _$VehicleRestrictionCopyWith(_VehicleRestriction value, $Res Function(_VehicleRestriction) _then) = __$VehicleRestrictionCopyWithImpl;
@override @useResult
$Res call({
 int? id, int vehicleId, bool enabled, String? city, List<int> days, String startTime, String endTime, bool exempt, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$VehicleRestrictionCopyWithImpl<$Res>
    implements _$VehicleRestrictionCopyWith<$Res> {
  __$VehicleRestrictionCopyWithImpl(this._self, this._then);

  final _VehicleRestriction _self;
  final $Res Function(_VehicleRestriction) _then;

/// Create a copy of VehicleRestriction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleId = null,Object? enabled = null,Object? city = freezed,Object? days = null,Object? startTime = null,Object? endTime = null,Object? exempt = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_VehicleRestriction(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<int>,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,exempt: null == exempt ? _self.exempt : exempt // ignore: cast_nullable_to_non_nullable
as bool,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
