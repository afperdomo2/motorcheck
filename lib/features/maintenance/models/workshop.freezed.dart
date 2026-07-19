// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workshop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Workshop _$WorkshopFromJson(Map<String, dynamic> json) {
  return _Workshop.fromJson(json);
}

/// @nodoc
mixin _$Workshop {
  int? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Workshop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Workshop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkshopCopyWith<Workshop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkshopCopyWith<$Res> {
  factory $WorkshopCopyWith(Workshop value, $Res Function(Workshop) then) =
      _$WorkshopCopyWithImpl<$Res, Workshop>;
  @useResult
  $Res call({int? id, String name, String? location, DateTime createdAt});
}

/// @nodoc
class _$WorkshopCopyWithImpl<$Res, $Val extends Workshop>
    implements $WorkshopCopyWith<$Res> {
  _$WorkshopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Workshop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? location = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkshopImplCopyWith<$Res>
    implements $WorkshopCopyWith<$Res> {
  factory _$$WorkshopImplCopyWith(
    _$WorkshopImpl value,
    $Res Function(_$WorkshopImpl) then,
  ) = __$$WorkshopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String name, String? location, DateTime createdAt});
}

/// @nodoc
class __$$WorkshopImplCopyWithImpl<$Res>
    extends _$WorkshopCopyWithImpl<$Res, _$WorkshopImpl>
    implements _$$WorkshopImplCopyWith<$Res> {
  __$$WorkshopImplCopyWithImpl(
    _$WorkshopImpl _value,
    $Res Function(_$WorkshopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Workshop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? location = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$WorkshopImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkshopImpl implements _Workshop {
  const _$WorkshopImpl({
    this.id,
    required this.name,
    this.location,
    required this.createdAt,
  });

  factory _$WorkshopImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkshopImplFromJson(json);

  @override
  final int? id;
  @override
  final String name;
  @override
  final String? location;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Workshop(id: $id, name: $name, location: $location, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkshopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, location, createdAt);

  /// Create a copy of Workshop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkshopImplCopyWith<_$WorkshopImpl> get copyWith =>
      __$$WorkshopImplCopyWithImpl<_$WorkshopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkshopImplToJson(this);
  }
}

abstract class _Workshop implements Workshop {
  const factory _Workshop({
    final int? id,
    required final String name,
    final String? location,
    required final DateTime createdAt,
  }) = _$WorkshopImpl;

  factory _Workshop.fromJson(Map<String, dynamic> json) =
      _$WorkshopImpl.fromJson;

  @override
  int? get id;
  @override
  String get name;
  @override
  String? get location;
  @override
  DateTime get createdAt;

  /// Create a copy of Workshop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkshopImplCopyWith<_$WorkshopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
