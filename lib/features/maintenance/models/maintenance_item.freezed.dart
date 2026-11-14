// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaintenanceItem {

 int? get id; int get maintenanceId; String get category; double get partsCost; String? get notes; int? get componentId; DateTime get createdAt;
/// Create a copy of MaintenanceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceItemCopyWith<MaintenanceItem> get copyWith => _$MaintenanceItemCopyWithImpl<MaintenanceItem>(this as MaintenanceItem, _$identity);

  /// Serializes this MaintenanceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MaintenanceItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.maintenanceId, _this.maintenanceId) || other.maintenanceId == _this.maintenanceId)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.partsCost, _this.partsCost) || other.partsCost == _this.partsCost)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.componentId, _this.componentId) || other.componentId == _this.componentId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MaintenanceItem;
  return Object.hash(runtimeType,_this.id,_this.maintenanceId,_this.category,_this.partsCost,_this.notes,_this.componentId,_this.createdAt);
}

@override
String toString() {
  final _this = this as MaintenanceItem;
  return 'MaintenanceItem(id: ${_this.id}, maintenanceId: ${_this.maintenanceId}, category: ${_this.category}, partsCost: ${_this.partsCost}, notes: ${_this.notes}, componentId: ${_this.componentId}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $MaintenanceItemCopyWith<$Res>  {
  factory $MaintenanceItemCopyWith(MaintenanceItem value, $Res Function(MaintenanceItem) _then) = _$MaintenanceItemCopyWithImpl;
@useResult
$Res call({
 int? id, int maintenanceId, String category, double partsCost, String? notes, int? componentId, DateTime createdAt
});




}
/// @nodoc
class _$MaintenanceItemCopyWithImpl<$Res>
    implements $MaintenanceItemCopyWith<$Res> {
  _$MaintenanceItemCopyWithImpl(this._self, this._then);

  final MaintenanceItem _self;
  final $Res Function(MaintenanceItem) _then;

/// Create a copy of MaintenanceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? maintenanceId = null,Object? category = null,Object? partsCost = null,Object? notes = freezed,Object? componentId = freezed,Object? createdAt = null,}) {
  return _then(MaintenanceItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,maintenanceId: null == maintenanceId ? _self.maintenanceId : maintenanceId // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,partsCost: null == partsCost ? _self.partsCost : partsCost // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,componentId: freezed == componentId ? _self.componentId : componentId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceItem].
extension MaintenanceItemPatterns on MaintenanceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceItem value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceItem value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int maintenanceId,  String category,  double partsCost,  String? notes,  int? componentId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceItem() when $default != null:
return $default(_that.id,_that.maintenanceId,_that.category,_that.partsCost,_that.notes,_that.componentId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int maintenanceId,  String category,  double partsCost,  String? notes,  int? componentId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceItem():
return $default(_that.id,_that.maintenanceId,_that.category,_that.partsCost,_that.notes,_that.componentId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int maintenanceId,  String category,  double partsCost,  String? notes,  int? componentId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceItem() when $default != null:
return $default(_that.id,_that.maintenanceId,_that.category,_that.partsCost,_that.notes,_that.componentId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceItem implements MaintenanceItem {
  const _MaintenanceItem({this.id, required this.maintenanceId, this.category = 'general', this.partsCost = 0, this.notes, this.componentId, required this.createdAt});
  factory _MaintenanceItem.fromJson(Map<String, dynamic> json) => _$MaintenanceItemFromJson(json);

@override final  int? id;
@override final  int maintenanceId;
@override@JsonKey() final  String category;
@override@JsonKey() final  double partsCost;
@override final  String? notes;
@override final  int? componentId;
@override final  DateTime createdAt;

/// Create a copy of MaintenanceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceItemCopyWith<_MaintenanceItem> get copyWith => __$MaintenanceItemCopyWithImpl<_MaintenanceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceItem&&(identical(other.id, id) || other.id == id)&&(identical(other.maintenanceId, maintenanceId) || other.maintenanceId == maintenanceId)&&(identical(other.category, category) || other.category == category)&&(identical(other.partsCost, partsCost) || other.partsCost == partsCost)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.componentId, componentId) || other.componentId == componentId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,maintenanceId,category,partsCost,notes,componentId,createdAt);
}

@override
String toString() {
    return 'MaintenanceItem(id: $id, maintenanceId: $maintenanceId, category: $category, partsCost: $partsCost, notes: $notes, componentId: $componentId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceItemCopyWith<$Res> implements $MaintenanceItemCopyWith<$Res> {
  factory _$MaintenanceItemCopyWith(_MaintenanceItem value, $Res Function(_MaintenanceItem) _then) = __$MaintenanceItemCopyWithImpl;
@override @useResult
$Res call({
 int? id, int maintenanceId, String category, double partsCost, String? notes, int? componentId, DateTime createdAt
});




}
/// @nodoc
class __$MaintenanceItemCopyWithImpl<$Res>
    implements _$MaintenanceItemCopyWith<$Res> {
  __$MaintenanceItemCopyWithImpl(this._self, this._then);

  final _MaintenanceItem _self;
  final $Res Function(_MaintenanceItem) _then;

/// Create a copy of MaintenanceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? maintenanceId = null,Object? category = null,Object? partsCost = null,Object? notes = freezed,Object? componentId = freezed,Object? createdAt = null,}) {
  return _then(_MaintenanceItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,maintenanceId: null == maintenanceId ? _self.maintenanceId : maintenanceId // ignore: cast_nullable_to_non_nullable
as int,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,partsCost: null == partsCost ? _self.partsCost : partsCost // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,componentId: freezed == componentId ? _self.componentId : componentId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
