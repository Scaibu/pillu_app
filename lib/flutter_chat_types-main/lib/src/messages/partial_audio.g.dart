// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'partial_audio.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartialAudio _$PartialAudioFromJson(Map<String, dynamic> json) => PartialAudio(
      name: json['name'] as String,
      size: (json['size'] as num).toInt(),
      uri: json['uri'] as String,
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      metadata: json['metadata'] as Map<String, dynamic>?,
      mimeType: json['mimeType'] as String?,
      repliedMessage: json['repliedMessage'] == null
          ? null
          : Message.fromJson(json['repliedMessage'] as Map<String, dynamic>),
      waveForm: (json['waveForm'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$PartialAudioToJson(PartialAudio instance) =>
    <String, dynamic>{
      'duration': instance.duration.inMicroseconds,
      'metadata': instance.metadata,
      'mimeType': instance.mimeType,
      'name': instance.name,
      'repliedMessage': instance.repliedMessage,
      'size': instance.size,
      'uri': instance.uri,
      'waveForm': instance.waveForm,
    };
