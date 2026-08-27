// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MaintenanceCategory _$MaintenanceCategoryFromJson(Map<String, dynamic> json) {
  return _MaintenanceCategory.fromJson(json);
}

/// @nodoc
mixin _$MaintenanceCategory {
  int? get id => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get iconName => throw _privateConstructorUsedError;
  String get vehicleType => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  int? get intervalKm => throw _privateConstructorUsedError;
  int? get warningKm => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MaintenanceCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaintenanceCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaintenanceCategoryCopyWith<MaintenanceCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaintenanceCategoryCopyWith<$Res> {
  factory $MaintenanceCategoryCopyWith(
    MaintenanceCategory value,
    $Res Function(MaintenanceCategory) then,
  ) = _$MaintenanceCategoryCopyWithImpl<$Res, MaintenanceCategory>;
  @useResult
  $Res call({
    int? id,
    String key,
    String name,
    String iconName,
    String vehicleType,
    int sortOrder,
    int? intervalKm,
    int? warningKm,
    DateTime createdAt,
  });
}

/// @nodoc
class _$MaintenanceCategoryCopyWithImpl<$Res, $Val extends MaintenanceCategory>
    implements $MaintenanceCategoryCopyWith<$Res> {
  _$MaintenanceCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaintenanceCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? key = null,
    Object? name = null,
    Object? iconName = null,
    Object? vehicleType = null,
    Object? sortOrder = null,
    Object? intervalKm = freezed,
    Object? warningKm = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            key: null == key
                ? _value.key
                : key // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            iconName: null == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                      as String,
            vehicleType: null == vehicleType
                ? _value.vehicleType
                : vehicleType // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            intervalKm: freezed == intervalKm
                ? _value.intervalKm
                : intervalKm // ignore: cast_nullable_to_non_nullable
                      as int?,
            warningKm: freezed == warningKm
                ? _value.warningKm
                : warningKm // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$MaintenanceCategoryImplCopyWith<$Res>
    implements $MaintenanceCategoryCopyWith<$Res> {
  factory _$$MaintenanceCategoryImplCopyWith(
    _$MaintenanceCategoryImpl value,
    $Res Function(_$MaintenanceCategoryImpl) then,
  ) = __$$MaintenanceCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String key,
    String name,
    String iconName,
    String vehicleType,
    int sortOrder,
    int? intervalKm,
    int? warningKm,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$MaintenanceCategoryImplCopyWithImpl<$Res>
    extends _$MaintenanceCategoryCopyWithImpl<$Res, _$MaintenanceCategoryImpl>
    implements _$$MaintenanceCategoryImplCopyWith<$Res> {
  __$$MaintenanceCategoryImplCopyWithImpl(
    _$MaintenanceCategoryImpl _value,
    $Res Function(_$MaintenanceCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MaintenanceCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? key = null,
    Object? name = null,
    Object? iconName = null,
    Object? vehicleType = null,
    Object? sortOrder = null,
    Object? intervalKm = freezed,
    Object? warningKm = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$MaintenanceCategoryImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        key: null == key
            ? _value.key
            : key // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        iconName: null == iconName
            ? _value.iconName
            : iconName // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleType: null == vehicleType
            ? _value.vehicleType
            : vehicleType // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        intervalKm: freezed == intervalKm
            ? _value.intervalKm
            : intervalKm // ignore: cast_nullable_to_non_nullable
                  as int?,
        warningKm: freezed == warningKm
            ? _value.warningKm
            : warningKm // ignore: cast_nullable_to_non_nullable
                  as int?,
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
class _$MaintenanceCategoryImpl implements _MaintenanceCategory {
  const _$MaintenanceCategoryImpl({
    this.id,
    required this.key,
    required this.name,
    this.iconName = 'build',
    required this.vehicleType,
    this.sortOrder = 0,
    this.intervalKm,
    this.warningKm,
    required this.createdAt,
  });

  factory _$MaintenanceCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaintenanceCategoryImplFromJson(json);

  @override
  final int? id;
  @override
  final String key;
  @override
  final String name;
  @override
  @JsonKey()
  final String iconName;
  @override
  final String vehicleType;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final int? intervalKm;
  @override
  final int? warningKm;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MaintenanceCategory(id: $id, key: $key, name: $name, iconName: $iconName, vehicleType: $vehicleType, sortOrder: $sortOrder, intervalKm: $intervalKm, warningKm: $warningKm, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaintenanceCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.intervalKm, intervalKm) ||
                other.intervalKm == intervalKm) &&
            (identical(other.warningKm, warningKm) ||
                other.warningKm == warningKm) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    key,
    name,
    iconName,
    vehicleType,
    sortOrder,
    intervalKm,
    warningKm,
    createdAt,
  );

  /// Create a copy of MaintenanceCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaintenanceCategoryImplCopyWith<_$MaintenanceCategoryImpl> get copyWith =>
      __$$MaintenanceCategoryImplCopyWithImpl<_$MaintenanceCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MaintenanceCategoryImplToJson(this);
  }
}

abstract class _MaintenanceCategory implements MaintenanceCategory {
  const factory _MaintenanceCategory({
    final int? id,
    required final String key,
    required final String name,
    final String iconName,
    required final String vehicleType,
    final int sortOrder,
    final int? intervalKm,
    final int? warningKm,
    required final DateTime createdAt,
  }) = _$MaintenanceCategoryImpl;

  factory _MaintenanceCategory.fromJson(Map<String, dynamic> json) =
      _$MaintenanceCategoryImpl.fromJson;

  @override
  int? get id;
  @override
  String get key;
  @override
  String get name;
  @override
  String get iconName;
  @override
  String get vehicleType;
  @override
  int get sortOrder;
  @override
  int? get intervalKm;
  @override
  int? get warningKm;
  @override
  DateTime get createdAt;

  /// Create a copy of MaintenanceCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaintenanceCategoryImplCopyWith<_$MaintenanceCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
