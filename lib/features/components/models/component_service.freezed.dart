// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'component_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComponentService {

 int? get id; int get componentId; DateTime get date; int? get odometer; double get cost; String? get notes; bool get resetInterval; DateTime get createdAt;
/// Create a copy of ComponentService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComponentServiceCopyWith<ComponentService> get copyWith => _$ComponentServiceCopyWithImpl<ComponentService>(this as ComponentService, _$identity);

  /// Serializes this ComponentService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ComponentService;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComponentService&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.componentId, _this.componentId) || other.componentId == _this.componentId)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.odometer, _this.odometer) || other.odometer == _this.odometer)&&(identical(other.cost, _this.cost) || other.cost == _this.cost)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.resetInterval, _this.resetInterval) || other.resetInterval == _this.resetInterval)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ComponentService;
  return Object.hash(runtimeType,_this.id,_this.componentId,_this.date,_this.odometer,_this.cost,_this.notes,_this.resetInterval,_this.createdAt);
}

@override
String toString() {
  final _this = this as ComponentService;
  return 'ComponentService(id: ${_this.id}, componentId: ${_this.componentId}, date: ${_this.date}, odometer: ${_this.odometer}, cost: ${_this.cost}, notes: ${_this.notes}, resetInterval: ${_this.resetInterval}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $ComponentServiceCopyWith<$Res>  {
  factory $ComponentServiceCopyWith(ComponentService value, $Res Function(ComponentService) _then) = _$ComponentServiceCopyWithImpl;
@useResult
$Res call({
 int? id, int componentId, DateTime date, int? odometer, double cost, String? notes, bool resetInterval, DateTime createdAt
});




}
/// @nodoc
class _$ComponentServiceCopyWithImpl<$Res>
    implements $ComponentServiceCopyWith<$Res> {
  _$ComponentServiceCopyWithImpl(this._self, this._then);

  final ComponentService _self;
  final $Res Function(ComponentService) _then;

/// Create a copy of ComponentService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? componentId = null,Object? date = null,Object? odometer = freezed,Object? cost = null,Object? notes = freezed,Object? resetInterval = null,Object? createdAt = null,}) {
  return _then(ComponentService(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,componentId: null == componentId ? _self.componentId : componentId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,odometer: freezed == odometer ? _self.odometer : odometer // ignore: cast_nullable_to_non_nullable
as int?,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,resetInterval: null == resetInterval ? _self.resetInterval : resetInterval // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ComponentService].
extension ComponentServicePatterns on ComponentService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComponentService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComponentService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComponentService value)  $default,){
final _that = this;
switch (_that) {
case _ComponentService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComponentService value)?  $default,){
final _that = this;
switch (_that) {
case _ComponentService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int componentId,  DateTime date,  int? odometer,  double cost,  String? notes,  bool resetInterval,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComponentService() when $default != null:
return $default(_that.id,_that.componentId,_that.date,_that.odometer,_that.cost,_that.notes,_that.resetInterval,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int componentId,  DateTime date,  int? odometer,  double cost,  String? notes,  bool resetInterval,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ComponentService():
return $default(_that.id,_that.componentId,_that.date,_that.odometer,_that.cost,_that.notes,_that.resetInterval,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int componentId,  DateTime date,  int? odometer,  double cost,  String? notes,  bool resetInterval,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ComponentService() when $default != null:
return $default(_that.id,_that.componentId,_that.date,_that.odometer,_that.cost,_that.notes,_that.resetInterval,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComponentService implements ComponentService {
  const _ComponentService({this.id, required this.componentId, required this.date, this.odometer, this.cost = 0, this.notes, this.resetInterval = false, required this.createdAt});
  factory _ComponentService.fromJson(Map<String, dynamic> json) => _$ComponentServiceFromJson(json);

@override final  int? id;
@override final  int componentId;
@override final  DateTime date;
@override final  int? odometer;
@override@JsonKey() final  double cost;
@override final  String? notes;
@override@JsonKey() final  bool resetInterval;
@override final  DateTime createdAt;

/// Create a copy of ComponentService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComponentServiceCopyWith<_ComponentService> get copyWith => __$ComponentServiceCopyWithImpl<_ComponentService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComponentServiceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComponentService&&(identical(other.id, id) || other.id == id)&&(identical(other.componentId, componentId) || other.componentId == componentId)&&(identical(other.date, date) || other.date == date)&&(identical(other.odometer, odometer) || other.odometer == odometer)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.resetInterval, resetInterval) || other.resetInterval == resetInterval)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,componentId,date,odometer,cost,notes,resetInterval,createdAt);
}

@override
String toString() {
    return 'ComponentService(id: $id, componentId: $componentId, date: $date, odometer: $odometer, cost: $cost, notes: $notes, resetInterval: $resetInterval, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ComponentServiceCopyWith<$Res> implements $ComponentServiceCopyWith<$Res> {
  factory _$ComponentServiceCopyWith(_ComponentService value, $Res Function(_ComponentService) _then) = __$ComponentServiceCopyWithImpl;
@override @useResult
$Res call({
 int? id, int componentId, DateTime date, int? odometer, double cost, String? notes, bool resetInterval, DateTime createdAt
});




}
/// @nodoc
class __$ComponentServiceCopyWithImpl<$Res>
    implements _$ComponentServiceCopyWith<$Res> {
  __$ComponentServiceCopyWithImpl(this._self, this._then);

  final _ComponentService _self;
  final $Res Function(_ComponentService) _then;

/// Create a copy of ComponentService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? componentId = null,Object? date = null,Object? odometer = freezed,Object? cost = null,Object? notes = freezed,Object? resetInterval = null,Object? createdAt = null,}) {
  return _then(_ComponentService(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,componentId: null == componentId ? _self.componentId : componentId // ignore: cast_nullable_to_non_nullable
as int,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,odometer: freezed == odometer ? _self.odometer : odometer // ignore: cast_nullable_to_non_nullable
as int?,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,resetInterval: null == resetInterval ? _self.resetInterval : resetInterval // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
