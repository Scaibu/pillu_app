// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'partial_custom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartialCustom _$PartialCustomFromJson(Map<String, dynamic> json) =>
    PartialCustom(
      metadata: json['metadata'] as Map<String, dynamic>?,
      repliedMessage: json['repliedMessage'] == null
          ? null
          : Message.fromJson(json['repliedMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PartialCustomToJson(PartialCustom instance) =>
    <String, dynamic>{
      'metadata': instance.metadata,
      'repliedMessage': instance.repliedMessage,
    };
