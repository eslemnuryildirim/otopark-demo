// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_expertiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VehicleExpertizImpl _$$VehicleExpertizImplFromJson(
        Map<String, dynamic> json) =>
    _$VehicleExpertizImpl(
      vehicleId: json['vehicleId'] as String,
      id: json['id'] as String,
      partStatuses: (json['partStatuses'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$CarPartEnumMap, k),
            $enumDecode(_$ExpertizStatusEnumMap, e)),
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      inspectorName: json['inspectorName'] as String?,
      photos:
          (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$VehicleExpertizImplToJson(
        _$VehicleExpertizImpl instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'id': instance.id,
      'partStatuses': instance.partStatuses.map((k, e) =>
          MapEntry(_$CarPartEnumMap[k]!, _$ExpertizStatusEnumMap[e]!)),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'inspectorName': instance.inspectorName,
      'photos': instance.photos,
    };

const _$ExpertizStatusEnumMap = {
  ExpertizStatus.original: 'original',
  ExpertizStatus.localPainted: 'localPainted',
  ExpertizStatus.painted: 'painted',
  ExpertizStatus.replaced: 'replaced',
  ExpertizStatus.damaged: 'damaged',
  ExpertizStatus.scratched: 'scratched',
};

const _$CarPartEnumMap = {
  CarPart.frontBumper: 'frontBumper',
  CarPart.frontLeftLight: 'frontLeftLight',
  CarPart.frontRightLight: 'frontRightLight',
  CarPart.rearBumper: 'rearBumper',
  CarPart.rearLeftLight: 'rearLeftLight',
  CarPart.rearRightLight: 'rearRightLight',
  CarPart.frontLeftDoor: 'frontLeftDoor',
  CarPart.frontLeftFender: 'frontLeftFender',
  CarPart.rearLeftDoor: 'rearLeftDoor',
  CarPart.rearLeftFender: 'rearLeftFender',
  CarPart.frontRightDoor: 'frontRightDoor',
  CarPart.frontRightFender: 'frontRightFender',
  CarPart.rearRightDoor: 'rearRightDoor',
  CarPart.rearRightFender: 'rearRightFender',
  CarPart.hood: 'hood',
  CarPart.roof: 'roof',
  CarPart.trunk: 'trunk',
  CarPart.frontWindshield: 'frontWindshield',
  CarPart.rearWindshield: 'rearWindshield',
  CarPart.frontLeftWindow: 'frontLeftWindow',
  CarPart.frontRightWindow: 'frontRightWindow',
  CarPart.rearLeftWindow: 'rearLeftWindow',
  CarPart.rearRightWindow: 'rearRightWindow',
};

_$ExpertizPartStatusImpl _$$ExpertizPartStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$ExpertizPartStatusImpl(
      part: $enumDecode(_$CarPartEnumMap, json['part']),
      status: $enumDecode(_$ExpertizStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      inspectedAt: json['inspectedAt'] == null
          ? null
          : DateTime.parse(json['inspectedAt'] as String),
      inspectorName: json['inspectorName'] as String?,
    );

Map<String, dynamic> _$$ExpertizPartStatusImplToJson(
        _$ExpertizPartStatusImpl instance) =>
    <String, dynamic>{
      'part': _$CarPartEnumMap[instance.part]!,
      'status': _$ExpertizStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'inspectedAt': instance.inspectedAt?.toIso8601String(),
      'inspectorName': instance.inspectorName,
    };

_$ExpertizStatsImpl _$$ExpertizStatsImplFromJson(Map<String, dynamic> json) =>
    _$ExpertizStatsImpl(
      totalParts: (json['totalParts'] as num).toInt(),
      originalParts: (json['originalParts'] as num).toInt(),
      paintedParts: (json['paintedParts'] as num).toInt(),
      replacedParts: (json['replacedParts'] as num).toInt(),
      damagedParts: (json['damagedParts'] as num).toInt(),
      scratchedParts: (json['scratchedParts'] as num).toInt(),
      overallCondition: (json['overallCondition'] as num).toDouble(),
    );

Map<String, dynamic> _$$ExpertizStatsImplToJson(_$ExpertizStatsImpl instance) =>
    <String, dynamic>{
      'totalParts': instance.totalParts,
      'originalParts': instance.originalParts,
      'paintedParts': instance.paintedParts,
      'replacedParts': instance.replacedParts,
      'damagedParts': instance.damagedParts,
      'scratchedParts': instance.scratchedParts,
      'overallCondition': instance.overallCondition,
    };
