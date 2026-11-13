// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaintenanceAttachment {

 int? get id; int get maintenanceId; int? get itemId; String get name; String get filePath; DateTime get createdAt;
/// Create a copy of MaintenanceAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceAttachmentCopyWith<MaintenanceAttachment> get copyWith => _$MaintenanceAttachmentCopyWithImpl<MaintenanceAttachment>(this as MaintenanceAttachment, _$identity);

  /// Serializes this MaintenanceAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MaintenanceAttachment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceAttachment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.maintenanceId, _this.maintenanceId) || other.maintenanceId == _this.maintenanceId)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.filePath, _this.filePath) || other.filePath == _this.filePath)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MaintenanceAttachment;
  return Object.hash(runtimeType,_this.id,_this.maintenanceId,_this.itemId,_this.name,_this.filePath,_this.createdAt);
}

@override
String toString() {
  final _this = this as MaintenanceAttachment;
  return 'MaintenanceAttachment(id: ${_this.id}, maintenanceId: ${_this.maintenanceId}, itemId: ${_this.itemId}, name: ${_this.name}, filePath: ${_this.filePath}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $MaintenanceAttachmentCopyWith<$Res>  {
  factory $MaintenanceAttachmentCopyWith(MaintenanceAttachment value, $Res Function(MaintenanceAttachment) _then) = _$MaintenanceAttachmentCopyWithImpl;
@useResult
$Res call({
 int? id, int maintenanceId, int? itemId, String name, String filePath, DateTime createdAt
});




}
/// @nodoc
class _$MaintenanceAttachmentCopyWithImpl<$Res>
    implements $MaintenanceAttachmentCopyWith<$Res> {
  _$MaintenanceAttachmentCopyWithImpl(this._self, this._then);

  final MaintenanceAttachment _self;
  final $Res Function(MaintenanceAttachment) _then;

/// Create a copy of MaintenanceAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? maintenanceId = null,Object? itemId = freezed,Object? name = null,Object? filePath = null,Object? createdAt = null,}) {
  return _then(MaintenanceAttachment(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,maintenanceId: null == maintenanceId ? _self.maintenanceId : maintenanceId // ignore: cast_nullable_to_non_nullable
as int,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceAttachment].
extension MaintenanceAttachmentPatterns on MaintenanceAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceAttachment value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int maintenanceId,  int? itemId,  String name,  String filePath,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceAttachment() when $default != null:
return $default(_that.id,_that.maintenanceId,_that.itemId,_that.name,_that.filePath,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int maintenanceId,  int? itemId,  String name,  String filePath,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceAttachment():
return $default(_that.id,_that.maintenanceId,_that.itemId,_that.name,_that.filePath,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int maintenanceId,  int? itemId,  String name,  String filePath,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceAttachment() when $default != null:
return $default(_that.id,_that.maintenanceId,_that.itemId,_that.name,_that.filePath,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceAttachment implements MaintenanceAttachment {
  const _MaintenanceAttachment({this.id, required this.maintenanceId, this.itemId, required this.name, required this.filePath, required this.createdAt});
  factory _MaintenanceAttachment.fromJson(Map<String, dynamic> json) => _$MaintenanceAttachmentFromJson(json);

@override final  int? id;
@override final  int maintenanceId;
@override final  int? itemId;
@override final  String name;
@override final  String filePath;
@override final  DateTime createdAt;

/// Create a copy of MaintenanceAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceAttachmentCopyWith<_MaintenanceAttachment> get copyWith => __$MaintenanceAttachmentCopyWithImpl<_MaintenanceAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.maintenanceId, maintenanceId) || other.maintenanceId == maintenanceId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,maintenanceId,itemId,name,filePath,createdAt);
}

@override
String toString() {
    return 'MaintenanceAttachment(id: $id, maintenanceId: $maintenanceId, itemId: $itemId, name: $name, filePath: $filePath, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceAttachmentCopyWith<$Res> implements $MaintenanceAttachmentCopyWith<$Res> {
  factory _$MaintenanceAttachmentCopyWith(_MaintenanceAttachment value, $Res Function(_MaintenanceAttachment) _then) = __$MaintenanceAttachmentCopyWithImpl;
@override @useResult
$Res call({
 int? id, int maintenanceId, int? itemId, String name, String filePath, DateTime createdAt
});




}
/// @nodoc
class __$MaintenanceAttachmentCopyWithImpl<$Res>
    implements _$MaintenanceAttachmentCopyWith<$Res> {
  __$MaintenanceAttachmentCopyWithImpl(this._self, this._then);

  final _MaintenanceAttachment _self;
  final $Res Function(_MaintenanceAttachment) _then;

/// Create a copy of MaintenanceAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? maintenanceId = null,Object? itemId = freezed,Object? name = null,Object? filePath = null,Object? createdAt = null,}) {
  return _then(_MaintenanceAttachment(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,maintenanceId: null == maintenanceId ? _self.maintenanceId : maintenanceId // ignore: cast_nullable_to_non_nullable
as int,itemId: freezed == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
