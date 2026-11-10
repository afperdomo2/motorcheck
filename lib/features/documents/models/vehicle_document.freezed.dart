// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleDocument {

 int? get id; int? get vehicleId; String get type; String? get name; String? get number; DateTime? get issuedAt; DateTime get expiresAt; String? get filePath; String? get notes; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of VehicleDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleDocumentCopyWith<VehicleDocument> get copyWith => _$VehicleDocumentCopyWithImpl<VehicleDocument>(this as VehicleDocument, _$identity);

  /// Serializes this VehicleDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VehicleDocument;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleDocument&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.issuedAt, _this.issuedAt) || other.issuedAt == _this.issuedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.filePath, _this.filePath) || other.filePath == _this.filePath)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VehicleDocument;
  return Object.hash(runtimeType,_this.id,_this.vehicleId,_this.type,_this.name,_this.number,_this.issuedAt,_this.expiresAt,_this.filePath,_this.notes,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as VehicleDocument;
  return 'VehicleDocument(id: ${_this.id}, vehicleId: ${_this.vehicleId}, type: ${_this.type}, name: ${_this.name}, number: ${_this.number}, issuedAt: ${_this.issuedAt}, expiresAt: ${_this.expiresAt}, filePath: ${_this.filePath}, notes: ${_this.notes}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $VehicleDocumentCopyWith<$Res>  {
  factory $VehicleDocumentCopyWith(VehicleDocument value, $Res Function(VehicleDocument) _then) = _$VehicleDocumentCopyWithImpl;
@useResult
$Res call({
 int? id, int? vehicleId, String type, String? name, String? number, DateTime? issuedAt, DateTime expiresAt, String? filePath, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$VehicleDocumentCopyWithImpl<$Res>
    implements $VehicleDocumentCopyWith<$Res> {
  _$VehicleDocumentCopyWithImpl(this._self, this._then);

  final VehicleDocument _self;
  final $Res Function(VehicleDocument) _then;

/// Create a copy of VehicleDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? vehicleId = freezed,Object? type = null,Object? name = freezed,Object? number = freezed,Object? issuedAt = freezed,Object? expiresAt = null,Object? filePath = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(VehicleDocument(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,issuedAt: freezed == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleDocument].
extension VehicleDocumentPatterns on VehicleDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleDocument value)  $default,){
final _that = this;
switch (_that) {
case _VehicleDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleDocument value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? vehicleId,  String type,  String? name,  String? number,  DateTime? issuedAt,  DateTime expiresAt,  String? filePath,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleDocument() when $default != null:
return $default(_that.id,_that.vehicleId,_that.type,_that.name,_that.number,_that.issuedAt,_that.expiresAt,_that.filePath,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? vehicleId,  String type,  String? name,  String? number,  DateTime? issuedAt,  DateTime expiresAt,  String? filePath,  String? notes,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _VehicleDocument():
return $default(_that.id,_that.vehicleId,_that.type,_that.name,_that.number,_that.issuedAt,_that.expiresAt,_that.filePath,_that.notes,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? vehicleId,  String type,  String? name,  String? number,  DateTime? issuedAt,  DateTime expiresAt,  String? filePath,  String? notes,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _VehicleDocument() when $default != null:
return $default(_that.id,_that.vehicleId,_that.type,_that.name,_that.number,_that.issuedAt,_that.expiresAt,_that.filePath,_that.notes,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleDocument implements VehicleDocument {
  const _VehicleDocument({this.id, this.vehicleId, required this.type, this.name, this.number, this.issuedAt, required this.expiresAt, this.filePath, this.notes, required this.createdAt, required this.updatedAt});
  factory _VehicleDocument.fromJson(Map<String, dynamic> json) => _$VehicleDocumentFromJson(json);

@override final  int? id;
@override final  int? vehicleId;
@override final  String type;
@override final  String? name;
@override final  String? number;
@override final  DateTime? issuedAt;
@override final  DateTime expiresAt;
@override final  String? filePath;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of VehicleDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleDocumentCopyWith<_VehicleDocument> get copyWith => __$VehicleDocumentCopyWithImpl<_VehicleDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.number, number) || other.number == number)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleId,type,name,number,issuedAt,expiresAt,filePath,notes,createdAt,updatedAt);
}

@override
String toString() {
    return 'VehicleDocument(id: $id, vehicleId: $vehicleId, type: $type, name: $name, number: $number, issuedAt: $issuedAt, expiresAt: $expiresAt, filePath: $filePath, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$VehicleDocumentCopyWith<$Res> implements $VehicleDocumentCopyWith<$Res> {
  factory _$VehicleDocumentCopyWith(_VehicleDocument value, $Res Function(_VehicleDocument) _then) = __$VehicleDocumentCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? vehicleId, String type, String? name, String? number, DateTime? issuedAt, DateTime expiresAt, String? filePath, String? notes, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$VehicleDocumentCopyWithImpl<$Res>
    implements _$VehicleDocumentCopyWith<$Res> {
  __$VehicleDocumentCopyWithImpl(this._self, this._then);

  final _VehicleDocument _self;
  final $Res Function(_VehicleDocument) _then;

/// Create a copy of VehicleDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? vehicleId = freezed,Object? type = null,Object? name = freezed,Object? number = freezed,Object? issuedAt = freezed,Object? expiresAt = null,Object? filePath = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_VehicleDocument(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,vehicleId: freezed == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as int?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,number: freezed == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as String?,issuedAt: freezed == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
