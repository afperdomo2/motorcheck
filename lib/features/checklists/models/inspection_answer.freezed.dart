// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection_answer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InspectionAnswer {

 int? get id; int get runId; int get itemId; String get status; String? get notes;
/// Create a copy of InspectionAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionAnswerCopyWith<InspectionAnswer> get copyWith => _$InspectionAnswerCopyWithImpl<InspectionAnswer>(this as InspectionAnswer, _$identity);

  /// Serializes this InspectionAnswer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as InspectionAnswer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InspectionAnswer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.runId, _this.runId) || other.runId == _this.runId)&&(identical(other.itemId, _this.itemId) || other.itemId == _this.itemId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InspectionAnswer;
  return Object.hash(runtimeType,_this.id,_this.runId,_this.itemId,_this.status,_this.notes);
}

@override
String toString() {
  final _this = this as InspectionAnswer;
  return 'InspectionAnswer(id: ${_this.id}, runId: ${_this.runId}, itemId: ${_this.itemId}, status: ${_this.status}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $InspectionAnswerCopyWith<$Res>  {
  factory $InspectionAnswerCopyWith(InspectionAnswer value, $Res Function(InspectionAnswer) _then) = _$InspectionAnswerCopyWithImpl;
@useResult
$Res call({
 int? id, int runId, int itemId, String status, String? notes
});




}
/// @nodoc
class _$InspectionAnswerCopyWithImpl<$Res>
    implements $InspectionAnswerCopyWith<$Res> {
  _$InspectionAnswerCopyWithImpl(this._self, this._then);

  final InspectionAnswer _self;
  final $Res Function(InspectionAnswer) _then;

/// Create a copy of InspectionAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? runId = null,Object? itemId = null,Object? status = null,Object? notes = freezed,}) {
  return _then(InspectionAnswer(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as int,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InspectionAnswer].
extension InspectionAnswerPatterns on InspectionAnswer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InspectionAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InspectionAnswer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InspectionAnswer value)  $default,){
final _that = this;
switch (_that) {
case _InspectionAnswer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InspectionAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _InspectionAnswer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int runId,  int itemId,  String status,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InspectionAnswer() when $default != null:
return $default(_that.id,_that.runId,_that.itemId,_that.status,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int runId,  int itemId,  String status,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _InspectionAnswer():
return $default(_that.id,_that.runId,_that.itemId,_that.status,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int runId,  int itemId,  String status,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _InspectionAnswer() when $default != null:
return $default(_that.id,_that.runId,_that.itemId,_that.status,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InspectionAnswer implements InspectionAnswer {
  const _InspectionAnswer({this.id, required this.runId, required this.itemId, this.status = 'ok', this.notes});
  factory _InspectionAnswer.fromJson(Map<String, dynamic> json) => _$InspectionAnswerFromJson(json);

@override final  int? id;
@override final  int runId;
@override final  int itemId;
@override@JsonKey() final  String status;
@override final  String? notes;

/// Create a copy of InspectionAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionAnswerCopyWith<_InspectionAnswer> get copyWith => __$InspectionAnswerCopyWithImpl<_InspectionAnswer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionAnswerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _InspectionAnswer&&(identical(other.id, id) || other.id == id)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,runId,itemId,status,notes);
}

@override
String toString() {
    return 'InspectionAnswer(id: $id, runId: $runId, itemId: $itemId, status: $status, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$InspectionAnswerCopyWith<$Res> implements $InspectionAnswerCopyWith<$Res> {
  factory _$InspectionAnswerCopyWith(_InspectionAnswer value, $Res Function(_InspectionAnswer) _then) = __$InspectionAnswerCopyWithImpl;
@override @useResult
$Res call({
 int? id, int runId, int itemId, String status, String? notes
});




}
/// @nodoc
class __$InspectionAnswerCopyWithImpl<$Res>
    implements _$InspectionAnswerCopyWith<$Res> {
  __$InspectionAnswerCopyWithImpl(this._self, this._then);

  final _InspectionAnswer _self;
  final $Res Function(_InspectionAnswer) _then;

/// Create a copy of InspectionAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? runId = null,Object? itemId = null,Object? status = null,Object? notes = freezed,}) {
  return _then(_InspectionAnswer(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as int,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
