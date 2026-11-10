// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mileage_reading.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MileageReading {

 int? get id; int get vehicleId; DateTime get date; int get mileage; String get source; DateTime get createdAt;
/// Create a copy of MileageReading
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MileageReadingCopyWith<MileageReading> get copyWith => _$MileageReadingCopyWithImpl<MileageReading>(this as MileageReading, _$identity);

  /// Serializes this MileageReading to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MileageReading;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MileageReading&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.mileage, _this.mileage) || other.mileage == _this.mileage)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MileageReading;
  return Object.hash(runtimeType,_this.id,_this.vehicleId,_this.date,_this.mileage,_this.source,_this.createdAt);
}

@override
String toString() {
  final _this = this as MileageReading;
  return 'MileageReading(id: ${_this.id}, vehicleId: ${_this.vehicleId}, date: ${_this.date}, mileage: ${_this.mileage}, source: ${_this.source}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $MileageReadingCopyWith<$Res>  {
  factory $MileageReadingCopyWith(MileageReading value, $Res Function(MileageReading) _then) = _$MileageReadingCopyWithImpl;
@useResult
$Res call({
 int? id, int vehicleId, DateTime date, int mileage, String source, DateTime createdAt
});




}
/// @nodoc
class _$MileageReadingCopyWithImpl<$Res>
    implements $MileageReadingCopyWith<$Res> {
  _$MileageReadingCopyWithImpl(this._self, this._then);

  final MileageReading _self;
  final $Res Function(MileageReading) _then;

/// Create a copy of MileageReading
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleId = null,Object? date = null,Object? mileage = null,Object? source = null,Object? createdAt = null,}) {
  return _then(MileageReading(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,mileage: null == mileage ? _self.mileage : mileage // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MileageReading].
extension MileageReadingPatterns on MileageReading {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MileageReading value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MileageReading() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MileageReading value)  $default,){
final _that = this;
switch (_that) {
case _MileageReading():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MileageReading value)?  $default,){
final _that = this;
switch (_that) {
case _MileageReading() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  DateTime date,  int mileage,  String source,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MileageReading() when $default != null:
return $default(_that.id,_that.vehicleId,_that.date,_that.mileage,_that.source,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int vehicleId,  DateTime date,  int mileage,  String source,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MileageReading():
return $default(_that.id,_that.vehicleId,_that.date,_that.mileage,_that.source,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int vehicleId,  DateTime date,  int mileage,  String source,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MileageReading() when $default != null:
return $default(_that.id,_that.vehicleId,_that.date,_that.mileage,_that.source,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MileageReading implements MileageReading {
  const _MileageReading({this.id, required this.vehicleId, required this.date, required this.mileage, this.source = 'manual', required this.createdAt});
  factory _MileageReading.fromJson(Map<String, dynamic> json) => _$MileageReadingFromJson(json);

@override final  int? id;
@override final  int vehicleId;
@override final  DateTime date;
@override final  int mileage;
@override@JsonKey() final  String source;
@override final  DateTime createdAt;

/// Create a copy of MileageReading
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MileageReadingCopyWith<_MileageReading> get copyWith => __$MileageReadingCopyWithImpl<_MileageReading>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MileageReadingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MileageReading&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.date, date) || other.date == date)&&(identical(other.mileage, mileage) || other.mileage == mileage)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleId,date,mileage,source,createdAt);
}

@override
String toString() {
    return 'MileageReading(id: $id, vehicleId: $vehicleId, date: $date, mileage: $mileage, source: $source, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MileageReadingCopyWith<$Res> implements $MileageReadingCopyWith<$Res> {
  factory _$MileageReadingCopyWith(_MileageReading value, $Res Function(_MileageReading) _then) = __$MileageReadingCopyWithImpl;
@override @useResult
$Res call({
 int? id, int vehicleId, DateTime date, int mileage, String source, DateTime createdAt
});




}
/// @nodoc
class __$MileageReadingCopyWithImpl<$Res>
    implements _$MileageReadingCopyWith<$Res> {
  __$MileageReadingCopyWithImpl(this._self, this._then);

  final _MileageReading _self;
  final $Res Function(_MileageReading) _then;

/// Create a copy of MileageReading
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleId = null,Object? date = null,Object? mileage = null,Object? source = null,Object? createdAt = null,}) {
  return _then(_MileageReading(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,mileage: null == mileage ? _self.mileage : mileage // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
