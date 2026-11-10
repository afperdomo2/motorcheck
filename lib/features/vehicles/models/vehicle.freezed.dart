// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Vehicle {

 int? get id; String get name; String get type; String? get brand; String? get model; int? get year; String? get plate; String? get color; String? get imagePath; int? get currentMileage; DateTime? get mileageUpdatedAt; String? get vin; DateTime? get soatExpiresAt; DateTime? get rtmExpiresAt; bool get isDefault; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleCopyWith<Vehicle> get copyWith => _$VehicleCopyWithImpl<Vehicle>(this as Vehicle, _$identity);

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Vehicle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vehicle&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.model, _this.model) || other.model == _this.model)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.plate, _this.plate) || other.plate == _this.plate)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.imagePath, _this.imagePath) || other.imagePath == _this.imagePath)&&(identical(other.currentMileage, _this.currentMileage) || other.currentMileage == _this.currentMileage)&&(identical(other.mileageUpdatedAt, _this.mileageUpdatedAt) || other.mileageUpdatedAt == _this.mileageUpdatedAt)&&(identical(other.vin, _this.vin) || other.vin == _this.vin)&&(identical(other.soatExpiresAt, _this.soatExpiresAt) || other.soatExpiresAt == _this.soatExpiresAt)&&(identical(other.rtmExpiresAt, _this.rtmExpiresAt) || other.rtmExpiresAt == _this.rtmExpiresAt)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Vehicle;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.brand,_this.model,_this.year,_this.plate,_this.color,_this.imagePath,_this.currentMileage,_this.mileageUpdatedAt,_this.vin,_this.soatExpiresAt,_this.rtmExpiresAt,_this.isDefault,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Vehicle;
  return 'Vehicle(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, brand: ${_this.brand}, model: ${_this.model}, year: ${_this.year}, plate: ${_this.plate}, color: ${_this.color}, imagePath: ${_this.imagePath}, currentMileage: ${_this.currentMileage}, mileageUpdatedAt: ${_this.mileageUpdatedAt}, vin: ${_this.vin}, soatExpiresAt: ${_this.soatExpiresAt}, rtmExpiresAt: ${_this.rtmExpiresAt}, isDefault: ${_this.isDefault}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $VehicleCopyWith<$Res>  {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) _then) = _$VehicleCopyWithImpl;
@useResult
$Res call({
 int? id, String name, String type, String? brand, String? model, int? year, String? plate, String? color, String? imagePath, int? currentMileage, DateTime? mileageUpdatedAt, String? vin, DateTime? soatExpiresAt, DateTime? rtmExpiresAt, bool isDefault, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$VehicleCopyWithImpl<$Res>
    implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._self, this._then);

  final Vehicle _self;
  final $Res Function(Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? type = null,Object? brand = freezed,Object? model = freezed,Object? year = freezed,Object? plate = freezed,Object? color = freezed,Object? imagePath = freezed,Object? currentMileage = freezed,Object? mileageUpdatedAt = freezed,Object? vin = freezed,Object? soatExpiresAt = freezed,Object? rtmExpiresAt = freezed,Object? isDefault = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Vehicle(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,plate: freezed == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,currentMileage: freezed == currentMileage ? _self.currentMileage : currentMileage // ignore: cast_nullable_to_non_nullable
as int?,mileageUpdatedAt: freezed == mileageUpdatedAt ? _self.mileageUpdatedAt : mileageUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vin: freezed == vin ? _self.vin : vin // ignore: cast_nullable_to_non_nullable
as String?,soatExpiresAt: freezed == soatExpiresAt ? _self.soatExpiresAt : soatExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rtmExpiresAt: freezed == rtmExpiresAt ? _self.rtmExpiresAt : rtmExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Vehicle].
extension VehiclePatterns on Vehicle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vehicle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vehicle value)  $default,){
final _that = this;
switch (_that) {
case _Vehicle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vehicle value)?  $default,){
final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  String type,  String? brand,  String? model,  int? year,  String? plate,  String? color,  String? imagePath,  int? currentMileage,  DateTime? mileageUpdatedAt,  String? vin,  DateTime? soatExpiresAt,  DateTime? rtmExpiresAt,  bool isDefault,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.brand,_that.model,_that.year,_that.plate,_that.color,_that.imagePath,_that.currentMileage,_that.mileageUpdatedAt,_that.vin,_that.soatExpiresAt,_that.rtmExpiresAt,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  String type,  String? brand,  String? model,  int? year,  String? plate,  String? color,  String? imagePath,  int? currentMileage,  DateTime? mileageUpdatedAt,  String? vin,  DateTime? soatExpiresAt,  DateTime? rtmExpiresAt,  bool isDefault,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Vehicle():
return $default(_that.id,_that.name,_that.type,_that.brand,_that.model,_that.year,_that.plate,_that.color,_that.imagePath,_that.currentMileage,_that.mileageUpdatedAt,_that.vin,_that.soatExpiresAt,_that.rtmExpiresAt,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  String type,  String? brand,  String? model,  int? year,  String? plate,  String? color,  String? imagePath,  int? currentMileage,  DateTime? mileageUpdatedAt,  String? vin,  DateTime? soatExpiresAt,  DateTime? rtmExpiresAt,  bool isDefault,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Vehicle() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.brand,_that.model,_that.year,_that.plate,_that.color,_that.imagePath,_that.currentMileage,_that.mileageUpdatedAt,_that.vin,_that.soatExpiresAt,_that.rtmExpiresAt,_that.isDefault,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vehicle implements Vehicle {
  const _Vehicle({this.id, required this.name, this.type = 'car', this.brand, this.model, this.year, this.plate, this.color, this.imagePath, this.currentMileage, this.mileageUpdatedAt, this.vin, this.soatExpiresAt, this.rtmExpiresAt, this.isDefault = false, required this.createdAt, required this.updatedAt});
  factory _Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);

@override final  int? id;
@override final  String name;
@override@JsonKey() final  String type;
@override final  String? brand;
@override final  String? model;
@override final  int? year;
@override final  String? plate;
@override final  String? color;
@override final  String? imagePath;
@override final  int? currentMileage;
@override final  DateTime? mileageUpdatedAt;
@override final  String? vin;
@override final  DateTime? soatExpiresAt;
@override final  DateTime? rtmExpiresAt;
@override@JsonKey() final  bool isDefault;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleCopyWith<_Vehicle> get copyWith => __$VehicleCopyWithImpl<_Vehicle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vehicle&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.year, year) || other.year == year)&&(identical(other.plate, plate) || other.plate == plate)&&(identical(other.color, color) || other.color == color)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.currentMileage, currentMileage) || other.currentMileage == currentMileage)&&(identical(other.mileageUpdatedAt, mileageUpdatedAt) || other.mileageUpdatedAt == mileageUpdatedAt)&&(identical(other.vin, vin) || other.vin == vin)&&(identical(other.soatExpiresAt, soatExpiresAt) || other.soatExpiresAt == soatExpiresAt)&&(identical(other.rtmExpiresAt, rtmExpiresAt) || other.rtmExpiresAt == rtmExpiresAt)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,brand,model,year,plate,color,imagePath,currentMileage,mileageUpdatedAt,vin,soatExpiresAt,rtmExpiresAt,isDefault,createdAt,updatedAt);
}

@override
String toString() {
    return 'Vehicle(id: $id, name: $name, type: $type, brand: $brand, model: $model, year: $year, plate: $plate, color: $color, imagePath: $imagePath, currentMileage: $currentMileage, mileageUpdatedAt: $mileageUpdatedAt, vin: $vin, soatExpiresAt: $soatExpiresAt, rtmExpiresAt: $rtmExpiresAt, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VehicleCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$VehicleCopyWith(_Vehicle value, $Res Function(_Vehicle) _then) = __$VehicleCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, String type, String? brand, String? model, int? year, String? plate, String? color, String? imagePath, int? currentMileage, DateTime? mileageUpdatedAt, String? vin, DateTime? soatExpiresAt, DateTime? rtmExpiresAt, bool isDefault, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$VehicleCopyWithImpl<$Res>
    implements _$VehicleCopyWith<$Res> {
  __$VehicleCopyWithImpl(this._self, this._then);

  final _Vehicle _self;
  final $Res Function(_Vehicle) _then;

/// Create a copy of Vehicle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? type = null,Object? brand = freezed,Object? model = freezed,Object? year = freezed,Object? plate = freezed,Object? color = freezed,Object? imagePath = freezed,Object? currentMileage = freezed,Object? mileageUpdatedAt = freezed,Object? vin = freezed,Object? soatExpiresAt = freezed,Object? rtmExpiresAt = freezed,Object? isDefault = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Vehicle(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,plate: freezed == plate ? _self.plate : plate // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,currentMileage: freezed == currentMileage ? _self.currentMileage : currentMileage // ignore: cast_nullable_to_non_nullable
as int?,mileageUpdatedAt: freezed == mileageUpdatedAt ? _self.mileageUpdatedAt : mileageUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vin: freezed == vin ? _self.vin : vin // ignore: cast_nullable_to_non_nullable
as String?,soatExpiresAt: freezed == soatExpiresAt ? _self.soatExpiresAt : soatExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rtmExpiresAt: freezed == rtmExpiresAt ? _self.rtmExpiresAt : rtmExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
