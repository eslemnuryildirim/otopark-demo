// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_expertiz.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VehicleExpertiz _$VehicleExpertizFromJson(Map<String, dynamic> json) {
  return _VehicleExpertiz.fromJson(json);
}

/// @nodoc
mixin _$VehicleExpertiz {
  String get vehicleId => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  Map<CarPart, ExpertizStatus> get partStatuses =>
      throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get inspectorName => throw _privateConstructorUsedError;
  List<String>? get photos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VehicleExpertizCopyWith<VehicleExpertiz> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleExpertizCopyWith<$Res> {
  factory $VehicleExpertizCopyWith(
          VehicleExpertiz value, $Res Function(VehicleExpertiz) then) =
      _$VehicleExpertizCopyWithImpl<$Res, VehicleExpertiz>;
  @useResult
  $Res call(
      {String vehicleId,
      String id,
      Map<CarPart, ExpertizStatus> partStatuses,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt,
      String? inspectorName,
      List<String>? photos});
}

/// @nodoc
class _$VehicleExpertizCopyWithImpl<$Res, $Val extends VehicleExpertiz>
    implements $VehicleExpertizCopyWith<$Res> {
  _$VehicleExpertizCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vehicleId = null,
    Object? id = null,
    Object? partStatuses = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? inspectorName = freezed,
    Object? photos = freezed,
  }) {
    return _then(_value.copyWith(
      vehicleId: null == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      partStatuses: null == partStatuses
          ? _value.partStatuses
          : partStatuses // ignore: cast_nullable_to_non_nullable
              as Map<CarPart, ExpertizStatus>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      inspectorName: freezed == inspectorName
          ? _value.inspectorName
          : inspectorName // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: freezed == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VehicleExpertizImplCopyWith<$Res>
    implements $VehicleExpertizCopyWith<$Res> {
  factory _$$VehicleExpertizImplCopyWith(_$VehicleExpertizImpl value,
          $Res Function(_$VehicleExpertizImpl) then) =
      __$$VehicleExpertizImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String vehicleId,
      String id,
      Map<CarPart, ExpertizStatus> partStatuses,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt,
      String? inspectorName,
      List<String>? photos});
}

/// @nodoc
class __$$VehicleExpertizImplCopyWithImpl<$Res>
    extends _$VehicleExpertizCopyWithImpl<$Res, _$VehicleExpertizImpl>
    implements _$$VehicleExpertizImplCopyWith<$Res> {
  __$$VehicleExpertizImplCopyWithImpl(
      _$VehicleExpertizImpl _value, $Res Function(_$VehicleExpertizImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vehicleId = null,
    Object? id = null,
    Object? partStatuses = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? inspectorName = freezed,
    Object? photos = freezed,
  }) {
    return _then(_$VehicleExpertizImpl(
      vehicleId: null == vehicleId
          ? _value.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      partStatuses: null == partStatuses
          ? _value._partStatuses
          : partStatuses // ignore: cast_nullable_to_non_nullable
              as Map<CarPart, ExpertizStatus>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      inspectorName: freezed == inspectorName
          ? _value.inspectorName
          : inspectorName // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: freezed == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VehicleExpertizImpl implements _VehicleExpertiz {
  const _$VehicleExpertizImpl(
      {required this.vehicleId,
      required this.id,
      required final Map<CarPart, ExpertizStatus> partStatuses,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.inspectorName,
      final List<String>? photos})
      : _partStatuses = partStatuses,
        _photos = photos;

  factory _$VehicleExpertizImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleExpertizImplFromJson(json);

  @override
  final String vehicleId;
  @override
  final String id;
  final Map<CarPart, ExpertizStatus> _partStatuses;
  @override
  Map<CarPart, ExpertizStatus> get partStatuses {
    if (_partStatuses is EqualUnmodifiableMapView) return _partStatuses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_partStatuses);
  }

  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? inspectorName;
  final List<String>? _photos;
  @override
  List<String>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'VehicleExpertiz(vehicleId: $vehicleId, id: $id, partStatuses: $partStatuses, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, inspectorName: $inspectorName, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleExpertizImpl &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._partStatuses, _partStatuses) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.inspectorName, inspectorName) ||
                other.inspectorName == inspectorName) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      vehicleId,
      id,
      const DeepCollectionEquality().hash(_partStatuses),
      notes,
      createdAt,
      updatedAt,
      inspectorName,
      const DeepCollectionEquality().hash(_photos));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleExpertizImplCopyWith<_$VehicleExpertizImpl> get copyWith =>
      __$$VehicleExpertizImplCopyWithImpl<_$VehicleExpertizImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleExpertizImplToJson(
      this,
    );
  }
}

abstract class _VehicleExpertiz implements VehicleExpertiz {
  const factory _VehicleExpertiz(
      {required final String vehicleId,
      required final String id,
      required final Map<CarPart, ExpertizStatus> partStatuses,
      final String? notes,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? inspectorName,
      final List<String>? photos}) = _$VehicleExpertizImpl;

  factory _VehicleExpertiz.fromJson(Map<String, dynamic> json) =
      _$VehicleExpertizImpl.fromJson;

  @override
  String get vehicleId;
  @override
  String get id;
  @override
  Map<CarPart, ExpertizStatus> get partStatuses;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get inspectorName;
  @override
  List<String>? get photos;
  @override
  @JsonKey(ignore: true)
  _$$VehicleExpertizImplCopyWith<_$VehicleExpertizImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExpertizPartStatus _$ExpertizPartStatusFromJson(Map<String, dynamic> json) {
  return _ExpertizPartStatus.fromJson(json);
}

/// @nodoc
mixin _$ExpertizPartStatus {
  CarPart get part => throw _privateConstructorUsedError;
  ExpertizStatus get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get inspectedAt => throw _privateConstructorUsedError;
  String? get inspectorName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExpertizPartStatusCopyWith<ExpertizPartStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpertizPartStatusCopyWith<$Res> {
  factory $ExpertizPartStatusCopyWith(
          ExpertizPartStatus value, $Res Function(ExpertizPartStatus) then) =
      _$ExpertizPartStatusCopyWithImpl<$Res, ExpertizPartStatus>;
  @useResult
  $Res call(
      {CarPart part,
      ExpertizStatus status,
      String? notes,
      DateTime? inspectedAt,
      String? inspectorName});
}

/// @nodoc
class _$ExpertizPartStatusCopyWithImpl<$Res, $Val extends ExpertizPartStatus>
    implements $ExpertizPartStatusCopyWith<$Res> {
  _$ExpertizPartStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? part = null,
    Object? status = null,
    Object? notes = freezed,
    Object? inspectedAt = freezed,
    Object? inspectorName = freezed,
  }) {
    return _then(_value.copyWith(
      part: null == part
          ? _value.part
          : part // ignore: cast_nullable_to_non_nullable
              as CarPart,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExpertizStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      inspectedAt: freezed == inspectedAt
          ? _value.inspectedAt
          : inspectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      inspectorName: freezed == inspectorName
          ? _value.inspectorName
          : inspectorName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpertizPartStatusImplCopyWith<$Res>
    implements $ExpertizPartStatusCopyWith<$Res> {
  factory _$$ExpertizPartStatusImplCopyWith(_$ExpertizPartStatusImpl value,
          $Res Function(_$ExpertizPartStatusImpl) then) =
      __$$ExpertizPartStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CarPart part,
      ExpertizStatus status,
      String? notes,
      DateTime? inspectedAt,
      String? inspectorName});
}

/// @nodoc
class __$$ExpertizPartStatusImplCopyWithImpl<$Res>
    extends _$ExpertizPartStatusCopyWithImpl<$Res, _$ExpertizPartStatusImpl>
    implements _$$ExpertizPartStatusImplCopyWith<$Res> {
  __$$ExpertizPartStatusImplCopyWithImpl(_$ExpertizPartStatusImpl _value,
      $Res Function(_$ExpertizPartStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? part = null,
    Object? status = null,
    Object? notes = freezed,
    Object? inspectedAt = freezed,
    Object? inspectorName = freezed,
  }) {
    return _then(_$ExpertizPartStatusImpl(
      part: null == part
          ? _value.part
          : part // ignore: cast_nullable_to_non_nullable
              as CarPart,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExpertizStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      inspectedAt: freezed == inspectedAt
          ? _value.inspectedAt
          : inspectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      inspectorName: freezed == inspectorName
          ? _value.inspectorName
          : inspectorName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpertizPartStatusImpl implements _ExpertizPartStatus {
  const _$ExpertizPartStatusImpl(
      {required this.part,
      required this.status,
      this.notes,
      this.inspectedAt,
      this.inspectorName});

  factory _$ExpertizPartStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpertizPartStatusImplFromJson(json);

  @override
  final CarPart part;
  @override
  final ExpertizStatus status;
  @override
  final String? notes;
  @override
  final DateTime? inspectedAt;
  @override
  final String? inspectorName;

  @override
  String toString() {
    return 'ExpertizPartStatus(part: $part, status: $status, notes: $notes, inspectedAt: $inspectedAt, inspectorName: $inspectorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpertizPartStatusImpl &&
            (identical(other.part, part) || other.part == part) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.inspectedAt, inspectedAt) ||
                other.inspectedAt == inspectedAt) &&
            (identical(other.inspectorName, inspectorName) ||
                other.inspectorName == inspectorName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, part, status, notes, inspectedAt, inspectorName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpertizPartStatusImplCopyWith<_$ExpertizPartStatusImpl> get copyWith =>
      __$$ExpertizPartStatusImplCopyWithImpl<_$ExpertizPartStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpertizPartStatusImplToJson(
      this,
    );
  }
}

abstract class _ExpertizPartStatus implements ExpertizPartStatus {
  const factory _ExpertizPartStatus(
      {required final CarPart part,
      required final ExpertizStatus status,
      final String? notes,
      final DateTime? inspectedAt,
      final String? inspectorName}) = _$ExpertizPartStatusImpl;

  factory _ExpertizPartStatus.fromJson(Map<String, dynamic> json) =
      _$ExpertizPartStatusImpl.fromJson;

  @override
  CarPart get part;
  @override
  ExpertizStatus get status;
  @override
  String? get notes;
  @override
  DateTime? get inspectedAt;
  @override
  String? get inspectorName;
  @override
  @JsonKey(ignore: true)
  _$$ExpertizPartStatusImplCopyWith<_$ExpertizPartStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExpertizStats _$ExpertizStatsFromJson(Map<String, dynamic> json) {
  return _ExpertizStats.fromJson(json);
}

/// @nodoc
mixin _$ExpertizStats {
  int get totalParts => throw _privateConstructorUsedError;
  int get originalParts => throw _privateConstructorUsedError;
  int get paintedParts => throw _privateConstructorUsedError;
  int get replacedParts => throw _privateConstructorUsedError;
  int get damagedParts => throw _privateConstructorUsedError;
  int get scratchedParts => throw _privateConstructorUsedError;
  double get overallCondition => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExpertizStatsCopyWith<ExpertizStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpertizStatsCopyWith<$Res> {
  factory $ExpertizStatsCopyWith(
          ExpertizStats value, $Res Function(ExpertizStats) then) =
      _$ExpertizStatsCopyWithImpl<$Res, ExpertizStats>;
  @useResult
  $Res call(
      {int totalParts,
      int originalParts,
      int paintedParts,
      int replacedParts,
      int damagedParts,
      int scratchedParts,
      double overallCondition});
}

/// @nodoc
class _$ExpertizStatsCopyWithImpl<$Res, $Val extends ExpertizStats>
    implements $ExpertizStatsCopyWith<$Res> {
  _$ExpertizStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalParts = null,
    Object? originalParts = null,
    Object? paintedParts = null,
    Object? replacedParts = null,
    Object? damagedParts = null,
    Object? scratchedParts = null,
    Object? overallCondition = null,
  }) {
    return _then(_value.copyWith(
      totalParts: null == totalParts
          ? _value.totalParts
          : totalParts // ignore: cast_nullable_to_non_nullable
              as int,
      originalParts: null == originalParts
          ? _value.originalParts
          : originalParts // ignore: cast_nullable_to_non_nullable
              as int,
      paintedParts: null == paintedParts
          ? _value.paintedParts
          : paintedParts // ignore: cast_nullable_to_non_nullable
              as int,
      replacedParts: null == replacedParts
          ? _value.replacedParts
          : replacedParts // ignore: cast_nullable_to_non_nullable
              as int,
      damagedParts: null == damagedParts
          ? _value.damagedParts
          : damagedParts // ignore: cast_nullable_to_non_nullable
              as int,
      scratchedParts: null == scratchedParts
          ? _value.scratchedParts
          : scratchedParts // ignore: cast_nullable_to_non_nullable
              as int,
      overallCondition: null == overallCondition
          ? _value.overallCondition
          : overallCondition // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpertizStatsImplCopyWith<$Res>
    implements $ExpertizStatsCopyWith<$Res> {
  factory _$$ExpertizStatsImplCopyWith(
          _$ExpertizStatsImpl value, $Res Function(_$ExpertizStatsImpl) then) =
      __$$ExpertizStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalParts,
      int originalParts,
      int paintedParts,
      int replacedParts,
      int damagedParts,
      int scratchedParts,
      double overallCondition});
}

/// @nodoc
class __$$ExpertizStatsImplCopyWithImpl<$Res>
    extends _$ExpertizStatsCopyWithImpl<$Res, _$ExpertizStatsImpl>
    implements _$$ExpertizStatsImplCopyWith<$Res> {
  __$$ExpertizStatsImplCopyWithImpl(
      _$ExpertizStatsImpl _value, $Res Function(_$ExpertizStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalParts = null,
    Object? originalParts = null,
    Object? paintedParts = null,
    Object? replacedParts = null,
    Object? damagedParts = null,
    Object? scratchedParts = null,
    Object? overallCondition = null,
  }) {
    return _then(_$ExpertizStatsImpl(
      totalParts: null == totalParts
          ? _value.totalParts
          : totalParts // ignore: cast_nullable_to_non_nullable
              as int,
      originalParts: null == originalParts
          ? _value.originalParts
          : originalParts // ignore: cast_nullable_to_non_nullable
              as int,
      paintedParts: null == paintedParts
          ? _value.paintedParts
          : paintedParts // ignore: cast_nullable_to_non_nullable
              as int,
      replacedParts: null == replacedParts
          ? _value.replacedParts
          : replacedParts // ignore: cast_nullable_to_non_nullable
              as int,
      damagedParts: null == damagedParts
          ? _value.damagedParts
          : damagedParts // ignore: cast_nullable_to_non_nullable
              as int,
      scratchedParts: null == scratchedParts
          ? _value.scratchedParts
          : scratchedParts // ignore: cast_nullable_to_non_nullable
              as int,
      overallCondition: null == overallCondition
          ? _value.overallCondition
          : overallCondition // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpertizStatsImpl implements _ExpertizStats {
  const _$ExpertizStatsImpl(
      {required this.totalParts,
      required this.originalParts,
      required this.paintedParts,
      required this.replacedParts,
      required this.damagedParts,
      required this.scratchedParts,
      required this.overallCondition});

  factory _$ExpertizStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpertizStatsImplFromJson(json);

  @override
  final int totalParts;
  @override
  final int originalParts;
  @override
  final int paintedParts;
  @override
  final int replacedParts;
  @override
  final int damagedParts;
  @override
  final int scratchedParts;
  @override
  final double overallCondition;

  @override
  String toString() {
    return 'ExpertizStats(totalParts: $totalParts, originalParts: $originalParts, paintedParts: $paintedParts, replacedParts: $replacedParts, damagedParts: $damagedParts, scratchedParts: $scratchedParts, overallCondition: $overallCondition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpertizStatsImpl &&
            (identical(other.totalParts, totalParts) ||
                other.totalParts == totalParts) &&
            (identical(other.originalParts, originalParts) ||
                other.originalParts == originalParts) &&
            (identical(other.paintedParts, paintedParts) ||
                other.paintedParts == paintedParts) &&
            (identical(other.replacedParts, replacedParts) ||
                other.replacedParts == replacedParts) &&
            (identical(other.damagedParts, damagedParts) ||
                other.damagedParts == damagedParts) &&
            (identical(other.scratchedParts, scratchedParts) ||
                other.scratchedParts == scratchedParts) &&
            (identical(other.overallCondition, overallCondition) ||
                other.overallCondition == overallCondition));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalParts,
      originalParts,
      paintedParts,
      replacedParts,
      damagedParts,
      scratchedParts,
      overallCondition);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpertizStatsImplCopyWith<_$ExpertizStatsImpl> get copyWith =>
      __$$ExpertizStatsImplCopyWithImpl<_$ExpertizStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpertizStatsImplToJson(
      this,
    );
  }
}

abstract class _ExpertizStats implements ExpertizStats {
  const factory _ExpertizStats(
      {required final int totalParts,
      required final int originalParts,
      required final int paintedParts,
      required final int replacedParts,
      required final int damagedParts,
      required final int scratchedParts,
      required final double overallCondition}) = _$ExpertizStatsImpl;

  factory _ExpertizStats.fromJson(Map<String, dynamic> json) =
      _$ExpertizStatsImpl.fromJson;

  @override
  int get totalParts;
  @override
  int get originalParts;
  @override
  int get paintedParts;
  @override
  int get replacedParts;
  @override
  int get damagedParts;
  @override
  int get scratchedParts;
  @override
  double get overallCondition;
  @override
  @JsonKey(ignore: true)
  _$$ExpertizStatsImplCopyWith<_$ExpertizStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
