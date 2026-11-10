// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workshop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Workshop {

 int? get id; String get name; String? get location; DateTime get createdAt;
/// Create a copy of Workshop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkshopCopyWith<Workshop> get copyWith => _$WorkshopCopyWithImpl<Workshop>(this as Workshop, _$identity);

  /// Serializes this Workshop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Workshop;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Workshop&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Workshop;
  return Object.hash(runtimeType,_this.id,_this.name,_this.location,_this.createdAt);
}

@override
String toString() {
  final _this = this as Workshop;
  return 'Workshop(id: ${_this.id}, name: ${_this.name}, location: ${_this.location}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $WorkshopCopyWith<$Res>  {
  factory $WorkshopCopyWith(Workshop value, $Res Function(Workshop) _then) = _$WorkshopCopyWithImpl;
@useResult
$Res call({
 int? id, String name, String? location, DateTime createdAt
});




}
/// @nodoc
class _$WorkshopCopyWithImpl<$Res>
    implements $WorkshopCopyWith<$Res> {
  _$WorkshopCopyWithImpl(this._self, this._then);

  final Workshop _self;
  final $Res Function(Workshop) _then;

/// Create a copy of Workshop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? location = freezed,Object? createdAt = null,}) {
  return _then(Workshop(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Workshop].
extension WorkshopPatterns on Workshop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Workshop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Workshop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Workshop value)  $default,){
final _that = this;
switch (_that) {
case _Workshop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Workshop value)?  $default,){
final _that = this;
switch (_that) {
case _Workshop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  String? location,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Workshop() when $default != null:
return $default(_that.id,_that.name,_that.location,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  String? location,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Workshop():
return $default(_that.id,_that.name,_that.location,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  String? location,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Workshop() when $default != null:
return $default(_that.id,_that.name,_that.location,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Workshop implements Workshop {
  const _Workshop({this.id, required this.name, this.location, required this.createdAt});
  factory _Workshop.fromJson(Map<String, dynamic> json) => _$WorkshopFromJson(json);

@override final  int? id;
@override final  String name;
@override final  String? location;
@override final  DateTime createdAt;

/// Create a copy of Workshop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkshopCopyWith<_Workshop> get copyWith => __$WorkshopCopyWithImpl<_Workshop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkshopToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Workshop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.location, location) || other.location == location)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,location,createdAt);
}

@override
String toString() {
    return 'Workshop(id: $id, name: $name, location: $location, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WorkshopCopyWith<$Res> implements $WorkshopCopyWith<$Res> {
  factory _$WorkshopCopyWith(_Workshop value, $Res Function(_Workshop) _then) = __$WorkshopCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, String? location, DateTime createdAt
});




}
/// @nodoc
class __$WorkshopCopyWithImpl<$Res>
    implements _$WorkshopCopyWith<$Res> {
  __$WorkshopCopyWithImpl(this._self, this._then);

  final _Workshop _self;
  final $Res Function(_Workshop) _then;

/// Create a copy of Workshop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? location = freezed,Object? createdAt = null,}) {
  return _then(_Workshop(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
