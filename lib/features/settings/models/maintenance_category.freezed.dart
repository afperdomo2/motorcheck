// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaintenanceCategory {

 int? get id; String get key; String get name; String get iconName; String get vehicleType; int get sortOrder; int? get intervalKm; int? get warningKm; int? get intervalMonths; int? get warningDays; DateTime get createdAt;
/// Create a copy of MaintenanceCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceCategoryCopyWith<MaintenanceCategory> get copyWith => _$MaintenanceCategoryCopyWithImpl<MaintenanceCategory>(this as MaintenanceCategory, _$identity);

  /// Serializes this MaintenanceCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MaintenanceCategory;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceCategory&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.iconName, _this.iconName) || other.iconName == _this.iconName)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.intervalKm, _this.intervalKm) || other.intervalKm == _this.intervalKm)&&(identical(other.warningKm, _this.warningKm) || other.warningKm == _this.warningKm)&&(identical(other.intervalMonths, _this.intervalMonths) || other.intervalMonths == _this.intervalMonths)&&(identical(other.warningDays, _this.warningDays) || other.warningDays == _this.warningDays)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MaintenanceCategory;
  return Object.hash(runtimeType,_this.id,_this.key,_this.name,_this.iconName,_this.vehicleType,_this.sortOrder,_this.intervalKm,_this.warningKm,_this.intervalMonths,_this.warningDays,_this.createdAt);
}

@override
String toString() {
  final _this = this as MaintenanceCategory;
  return 'MaintenanceCategory(id: ${_this.id}, key: ${_this.key}, name: ${_this.name}, iconName: ${_this.iconName}, vehicleType: ${_this.vehicleType}, sortOrder: ${_this.sortOrder}, intervalKm: ${_this.intervalKm}, warningKm: ${_this.warningKm}, intervalMonths: ${_this.intervalMonths}, warningDays: ${_this.warningDays}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $MaintenanceCategoryCopyWith<$Res>  {
  factory $MaintenanceCategoryCopyWith(MaintenanceCategory value, $Res Function(MaintenanceCategory) _then) = _$MaintenanceCategoryCopyWithImpl;
@useResult
$Res call({
 int? id, String key, String name, String iconName, String vehicleType, int sortOrder, int? intervalKm, int? warningKm, int? intervalMonths, int? warningDays, DateTime createdAt
});




}
/// @nodoc
class _$MaintenanceCategoryCopyWithImpl<$Res>
    implements $MaintenanceCategoryCopyWith<$Res> {
  _$MaintenanceCategoryCopyWithImpl(this._self, this._then);

  final MaintenanceCategory _self;
  final $Res Function(MaintenanceCategory) _then;

/// Create a copy of MaintenanceCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? key = null,Object? name = null,Object? iconName = null,Object? vehicleType = null,Object? sortOrder = null,Object? intervalKm = freezed,Object? warningKm = freezed,Object? intervalMonths = freezed,Object? warningDays = freezed,Object? createdAt = null,}) {
  return _then(MaintenanceCategory(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,intervalKm: freezed == intervalKm ? _self.intervalKm : intervalKm // ignore: cast_nullable_to_non_nullable
as int?,warningKm: freezed == warningKm ? _self.warningKm : warningKm // ignore: cast_nullable_to_non_nullable
as int?,intervalMonths: freezed == intervalMonths ? _self.intervalMonths : intervalMonths // ignore: cast_nullable_to_non_nullable
as int?,warningDays: freezed == warningDays ? _self.warningDays : warningDays // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceCategory].
extension MaintenanceCategoryPatterns on MaintenanceCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceCategory value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceCategory value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String key,  String name,  String iconName,  String vehicleType,  int sortOrder,  int? intervalKm,  int? warningKm,  int? intervalMonths,  int? warningDays,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceCategory() when $default != null:
return $default(_that.id,_that.key,_that.name,_that.iconName,_that.vehicleType,_that.sortOrder,_that.intervalKm,_that.warningKm,_that.intervalMonths,_that.warningDays,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String key,  String name,  String iconName,  String vehicleType,  int sortOrder,  int? intervalKm,  int? warningKm,  int? intervalMonths,  int? warningDays,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceCategory():
return $default(_that.id,_that.key,_that.name,_that.iconName,_that.vehicleType,_that.sortOrder,_that.intervalKm,_that.warningKm,_that.intervalMonths,_that.warningDays,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String key,  String name,  String iconName,  String vehicleType,  int sortOrder,  int? intervalKm,  int? warningKm,  int? intervalMonths,  int? warningDays,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceCategory() when $default != null:
return $default(_that.id,_that.key,_that.name,_that.iconName,_that.vehicleType,_that.sortOrder,_that.intervalKm,_that.warningKm,_that.intervalMonths,_that.warningDays,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceCategory implements MaintenanceCategory {
  const _MaintenanceCategory({this.id, required this.key, required this.name, this.iconName = 'build', required this.vehicleType, this.sortOrder = 0, this.intervalKm, this.warningKm, this.intervalMonths, this.warningDays, required this.createdAt});
  factory _MaintenanceCategory.fromJson(Map<String, dynamic> json) => _$MaintenanceCategoryFromJson(json);

@override final  int? id;
@override final  String key;
@override final  String name;
@override@JsonKey() final  String iconName;
@override final  String vehicleType;
@override@JsonKey() final  int sortOrder;
@override final  int? intervalKm;
@override final  int? warningKm;
@override final  int? intervalMonths;
@override final  int? warningDays;
@override final  DateTime createdAt;

/// Create a copy of MaintenanceCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceCategoryCopyWith<_MaintenanceCategory> get copyWith => __$MaintenanceCategoryCopyWithImpl<_MaintenanceCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceCategory&&(identical(other.id, id) || other.id == id)&&(identical(other.key, key) || other.key == key)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.intervalKm, intervalKm) || other.intervalKm == intervalKm)&&(identical(other.warningKm, warningKm) || other.warningKm == warningKm)&&(identical(other.intervalMonths, intervalMonths) || other.intervalMonths == intervalMonths)&&(identical(other.warningDays, warningDays) || other.warningDays == warningDays)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,key,name,iconName,vehicleType,sortOrder,intervalKm,warningKm,intervalMonths,warningDays,createdAt);
}

@override
String toString() {
    return 'MaintenanceCategory(id: $id, key: $key, name: $name, iconName: $iconName, vehicleType: $vehicleType, sortOrder: $sortOrder, intervalKm: $intervalKm, warningKm: $warningKm, intervalMonths: $intervalMonths, warningDays: $warningDays, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceCategoryCopyWith<$Res> implements $MaintenanceCategoryCopyWith<$Res> {
  factory _$MaintenanceCategoryCopyWith(_MaintenanceCategory value, $Res Function(_MaintenanceCategory) _then) = __$MaintenanceCategoryCopyWithImpl;
@override @useResult
$Res call({
 int? id, String key, String name, String iconName, String vehicleType, int sortOrder, int? intervalKm, int? warningKm, int? intervalMonths, int? warningDays, DateTime createdAt
});




}
/// @nodoc
class __$MaintenanceCategoryCopyWithImpl<$Res>
    implements _$MaintenanceCategoryCopyWith<$Res> {
  __$MaintenanceCategoryCopyWithImpl(this._self, this._then);

  final _MaintenanceCategory _self;
  final $Res Function(_MaintenanceCategory) _then;

/// Create a copy of MaintenanceCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? key = null,Object? name = null,Object? iconName = null,Object? vehicleType = null,Object? sortOrder = null,Object? intervalKm = freezed,Object? warningKm = freezed,Object? intervalMonths = freezed,Object? warningDays = freezed,Object? createdAt = null,}) {
  return _then(_MaintenanceCategory(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,intervalKm: freezed == intervalKm ? _self.intervalKm : intervalKm // ignore: cast_nullable_to_non_nullable
as int?,warningKm: freezed == warningKm ? _self.warningKm : warningKm // ignore: cast_nullable_to_non_nullable
as int?,intervalMonths: freezed == intervalMonths ? _self.intervalMonths : intervalMonths // ignore: cast_nullable_to_non_nullable
as int?,warningDays: freezed == warningDays ? _self.warningDays : warningDays // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
