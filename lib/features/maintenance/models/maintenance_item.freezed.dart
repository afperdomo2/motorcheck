// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MaintenanceItem _$MaintenanceItemFromJson(Map<String, dynamic> json) {
  return _MaintenanceItem.fromJson(json);
}

/// @nodoc
mixin _$MaintenanceItem {
  int? get id => throw _privateConstructorUsedError;
  int get maintenanceId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get laborCost => throw _privateConstructorUsedError;
  double get partsCost => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MaintenanceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MaintenanceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaintenanceItemCopyWith<MaintenanceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaintenanceItemCopyWith<$Res> {
  factory $MaintenanceItemCopyWith(
    MaintenanceItem value,
    $Res Function(MaintenanceItem) then,
  ) = _$MaintenanceItemCopyWithImpl<$Res, MaintenanceItem>;
  @useResult
  $Res call({
    int? id,
    int maintenanceId,
    String name,
    String category,
    double laborCost,
    double partsCost,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class _$MaintenanceItemCopyWithImpl<$Res, $Val extends MaintenanceItem>
    implements $MaintenanceItemCopyWith<$Res> {
  _$MaintenanceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MaintenanceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? maintenanceId = null,
    Object? name = null,
    Object? category = null,
    Object? laborCost = null,
    Object? partsCost = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            maintenanceId: null == maintenanceId
                ? _value.maintenanceId
                : maintenanceId // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            laborCost: null == laborCost
                ? _value.laborCost
                : laborCost // ignore: cast_nullable_to_non_nullable
                      as double,
            partsCost: null == partsCost
                ? _value.partsCost
                : partsCost // ignore: cast_nullable_to_non_nullable
                      as double,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$MaintenanceItemImplCopyWith<$Res>
    implements $MaintenanceItemCopyWith<$Res> {
  factory _$$MaintenanceItemImplCopyWith(
    _$MaintenanceItemImpl value,
    $Res Function(_$MaintenanceItemImpl) then,
  ) = __$$MaintenanceItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    int maintenanceId,
    String name,
    String category,
    double laborCost,
    double partsCost,
    String? notes,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$MaintenanceItemImplCopyWithImpl<$Res>
    extends _$MaintenanceItemCopyWithImpl<$Res, _$MaintenanceItemImpl>
    implements _$$MaintenanceItemImplCopyWith<$Res> {
  __$$MaintenanceItemImplCopyWithImpl(
    _$MaintenanceItemImpl _value,
    $Res Function(_$MaintenanceItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MaintenanceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? maintenanceId = null,
    Object? name = null,
    Object? category = null,
    Object? laborCost = null,
    Object? partsCost = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$MaintenanceItemImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        maintenanceId: null == maintenanceId
            ? _value.maintenanceId
            : maintenanceId // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        laborCost: null == laborCost
            ? _value.laborCost
            : laborCost // ignore: cast_nullable_to_non_nullable
                  as double,
        partsCost: null == partsCost
            ? _value.partsCost
            : partsCost // ignore: cast_nullable_to_non_nullable
                  as double,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
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
class _$MaintenanceItemImpl implements _MaintenanceItem {
  const _$MaintenanceItemImpl({
    this.id,
    required this.maintenanceId,
    required this.name,
    this.category = 'other',
    this.laborCost = 0,
    this.partsCost = 0,
    this.notes,
    required this.createdAt,
  });

  factory _$MaintenanceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaintenanceItemImplFromJson(json);

  @override
  final int? id;
  @override
  final int maintenanceId;
  @override
  final String name;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final double laborCost;
  @override
  @JsonKey()
  final double partsCost;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'MaintenanceItem(id: $id, maintenanceId: $maintenanceId, name: $name, category: $category, laborCost: $laborCost, partsCost: $partsCost, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaintenanceItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.maintenanceId, maintenanceId) ||
                other.maintenanceId == maintenanceId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.laborCost, laborCost) ||
                other.laborCost == laborCost) &&
            (identical(other.partsCost, partsCost) ||
                other.partsCost == partsCost) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    maintenanceId,
    name,
    category,
    laborCost,
    partsCost,
    notes,
    createdAt,
  );

  /// Create a copy of MaintenanceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaintenanceItemImplCopyWith<_$MaintenanceItemImpl> get copyWith =>
      __$$MaintenanceItemImplCopyWithImpl<_$MaintenanceItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MaintenanceItemImplToJson(this);
  }
}

abstract class _MaintenanceItem implements MaintenanceItem {
  const factory _MaintenanceItem({
    final int? id,
    required final int maintenanceId,
    required final String name,
    final String category,
    final double laborCost,
    final double partsCost,
    final String? notes,
    required final DateTime createdAt,
  }) = _$MaintenanceItemImpl;

  factory _MaintenanceItem.fromJson(Map<String, dynamic> json) =
      _$MaintenanceItemImpl.fromJson;

  @override
  int? get id;
  @override
  int get maintenanceId;
  @override
  String get name;
  @override
  String get category;
  @override
  double get laborCost;
  @override
  double get partsCost;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of MaintenanceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaintenanceItemImplCopyWith<_$MaintenanceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
