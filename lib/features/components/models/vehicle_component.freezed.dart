// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_component.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleComponent {

 int? get id; int get vehicleId; String get name; String get type; String? get position; DateTime get installedAt; int? get installedKm; int? get intervalKm; int? get intervalMonths; int? get warningKm; int? get warningDays; String? get notes; bool get active; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of VehicleComponent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleComponentCopyWith<VehicleComponent> get copyWith => _$VehicleComponentCopyWithImpl<VehicleComponent>(this as VehicleComponent, _$identity);

  /// Serializes this VehicleComponent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VehicleComponent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleComponent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.installedAt, _this.installedAt) || other.installedAt == _this.installedAt)&&(identical(other.installedKm, _this.installedKm) || other.installedKm == _this.installedKm)&&(identical(other.intervalKm, _this.intervalKm) || other.intervalKm == _this.intervalKm)&&(identical(other.intervalMonths, _this.intervalMonths) || other.intervalMonths == _this.intervalMonths)&&(identical(other.warningKm, _this.warningKm) || other.warningKm == _this.warningKm)&&(identical(other.warningDays, _this.warningDays) || other.warningDays == _this.warningDays)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.active, _this.active) || other.active == _this.active)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VehicleComponent;
  return Object.hash(runtimeType,_this.id,_this.vehicleId,_this.name,_this.type,_this.position,_this.installedAt,_this.installedKm,_this.intervalKm,_this.intervalMonths,_this.warningKm,_this.warningDays,_this.notes,_this.active,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as VehicleComponent;
  return 'VehicleComponent(id: ${_this.id}, vehicleId: ${_this.vehicleId}, name: ${_this.name}, type: ${_this.type}, position: ${_this.position}, installedAt: ${_this.installedAt}, installedKm: ${_this.installedKm}, intervalKm: ${_this.intervalKm}, intervalMonths: ${_this.intervalMonths}, warningKm: ${_this.warningKm}, warningDays: ${_this.warningDays}, notes: ${_this.notes}, active: ${_this.active}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $VehicleComponentCopyWith<$Res>  {
  factory $VehicleComponentCopyWith(VehicleComponent value, $Res Function(VehicleComponent) _then) = _$VehicleComponentCopyWithImpl;
@useResult
$Res call({
 int? id, int vehicleId, String name, String type, String? position, DateTime installedAt, int? installedKm, int? intervalKm, int? intervalMonths, int? warningKm, int? warningDays, String? notes, bool active, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$VehicleComponentCopyWithImpl<$Res>
    implements $VehicleComponentCopyWith<$Res> {
  _$VehicleComponentCopyWithImpl(this._self, this._then);

  final VehicleComponent _self;
  final $Res Function(VehicleComponent) _then;

/// Create a copy of VehicleComponent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleId = null,Object? name = null,Object? type = null,Object? position = freezed,Object? installedAt = null,Object? installedKm = freezed,Object? intervalKm = freezed,Object? intervalMonths = freezed,Object? warningKm = freezed,Object? warningDays = freezed,Object? notes = freezed,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(VehicleComponent(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,installedAt: null == installedAt ? _self.installedAt : installedAt // ignore: cast_nullable_to_non_nullable
as DateTime,installedKm: freezed == installedKm ? _self.installedKm : installedKm // ignore: cast_nullable_to_non_nullable
as int?,intervalKm: freezed == intervalKm ? _self.intervalKm : intervalKm // ignore: cast_nullable_to_non_nullable
as int?,intervalMonths: freezed == intervalMonths ? _self.intervalMonths : intervalMonths // ignore: cast_nullable_to_non_nullable
as int?,warningKm: freezed == warningKm ? _self.warningKm : warningKm // ignore: cast_nullable_to_non_nullable
as int?,warningDays: freezed == warningDays ? _self.warningDays : warningDays // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleComponent].
extension VehicleComponentPatterns on VehicleComponent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleComponent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleComponent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleComponent value)  $default,){
final _that = this;
switch (_that) {
case _VehicleComponent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleComponent value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleComponent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  String name,  String type,  String? position,  DateTime installedAt,  int? installedKm,  int? intervalKm,  int? intervalMonths,  int? warningKm,  int? warningDays,  String? notes,  bool active,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleComponent() when $default != null:
return $default(_that.id,_that.vehicleId,_that.name,_that.type,_that.position,_that.installedAt,_that.installedKm,_that.intervalKm,_that.intervalMonths,_that.warningKm,_that.warningDays,_that.notes,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  String name,  String type,  String? position,  DateTime installedAt,  int? installedKm,  int? intervalKm,  int? intervalMonths,  int? warningKm,  int? warningDays,  String? notes,  bool active,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _VehicleComponent():
return $default(_that.id,_that.vehicleId,_that.name,_that.type,_that.position,_that.installedAt,_that.installedKm,_that.intervalKm,_that.intervalMonths,_that.warningKm,_that.warningDays,_that.notes,_that.active,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int vehicleId,  String name,  String type,  String? position,  DateTime installedAt,  int? installedKm,  int? intervalKm,  int? intervalMonths,  int? warningKm,  int? warningDays,  String? notes,  bool active,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _VehicleComponent() when $default != null:
return $default(_that.id,_that.vehicleId,_that.name,_that.type,_that.position,_that.installedAt,_that.installedKm,_that.intervalKm,_that.intervalMonths,_that.warningKm,_that.warningDays,_that.notes,_that.active,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleComponent implements VehicleComponent {
  const _VehicleComponent({this.id, required this.vehicleId, required this.name, this.type = 'other', this.position, required this.installedAt, this.installedKm, this.intervalKm, this.intervalMonths, this.warningKm, this.warningDays, this.notes, this.active = true, required this.createdAt, required this.updatedAt});
  factory _VehicleComponent.fromJson(Map<String, dynamic> json) => _$VehicleComponentFromJson(json);

@override final  int? id;
@override final  int vehicleId;
@override final  String name;
@override@JsonKey() final  String type;
@override final  String? position;
@override final  DateTime installedAt;
@override final  int? installedKm;
@override final  int? intervalKm;
@override final  int? intervalMonths;
@override final  int? warningKm;
@override final  int? warningDays;
@override final  String? notes;
@override@JsonKey() final  bool active;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of VehicleComponent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleComponentCopyWith<_VehicleComponent> get copyWith => __$VehicleComponentCopyWithImpl<_VehicleComponent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleComponentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleComponent&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.position, position) || other.position == position)&&(identical(other.installedAt, installedAt) || other.installedAt == installedAt)&&(identical(other.installedKm, installedKm) || other.installedKm == installedKm)&&(identical(other.intervalKm, intervalKm) || other.intervalKm == intervalKm)&&(identical(other.intervalMonths, intervalMonths) || other.intervalMonths == intervalMonths)&&(identical(other.warningKm, warningKm) || other.warningKm == warningKm)&&(identical(other.warningDays, warningDays) || other.warningDays == warningDays)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.active, active) || other.active == active)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleId,name,type,position,installedAt,installedKm,intervalKm,intervalMonths,warningKm,warningDays,notes,active,createdAt,updatedAt);
}

@override
String toString() {
    return 'VehicleComponent(id: $id, vehicleId: $vehicleId, name: $name, type: $type, position: $position, installedAt: $installedAt, installedKm: $installedKm, intervalKm: $intervalKm, intervalMonths: $intervalMonths, warningKm: $warningKm, warningDays: $warningDays, notes: $notes, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VehicleComponentCopyWith<$Res> implements $VehicleComponentCopyWith<$Res> {
  factory _$VehicleComponentCopyWith(_VehicleComponent value, $Res Function(_VehicleComponent) _then) = __$VehicleComponentCopyWithImpl;
@override @useResult
$Res call({
 int? id, int vehicleId, String name, String type, String? position, DateTime installedAt, int? installedKm, int? intervalKm, int? intervalMonths, int? warningKm, int? warningDays, String? notes, bool active, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$VehicleComponentCopyWithImpl<$Res>
    implements _$VehicleComponentCopyWith<$Res> {
  __$VehicleComponentCopyWithImpl(this._self, this._then);

  final _VehicleComponent _self;
  final $Res Function(_VehicleComponent) _then;

/// Create a copy of VehicleComponent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleId = null,Object? name = null,Object? type = null,Object? position = freezed,Object? installedAt = null,Object? installedKm = freezed,Object? intervalKm = freezed,Object? intervalMonths = freezed,Object? warningKm = freezed,Object? warningDays = freezed,Object? notes = freezed,Object? active = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_VehicleComponent(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,position: freezed == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as String?,installedAt: null == installedAt ? _self.installedAt : installedAt // ignore: cast_nullable_to_non_nullable
as DateTime,installedKm: freezed == installedKm ? _self.installedKm : installedKm // ignore: cast_nullable_to_non_nullable
as int?,intervalKm: freezed == intervalKm ? _self.intervalKm : intervalKm // ignore: cast_nullable_to_non_nullable
as int?,intervalMonths: freezed == intervalMonths ? _self.intervalMonths : intervalMonths // ignore: cast_nullable_to_non_nullable
as int?,warningKm: freezed == warningKm ? _self.warningKm : warningKm // ignore: cast_nullable_to_non_nullable
as int?,warningDays: freezed == warningDays ? _self.warningDays : warningDays // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
