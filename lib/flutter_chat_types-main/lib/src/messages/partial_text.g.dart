// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'partial_text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartialText _$PartialTextFromJson(Map<String, dynamic> json) => PartialText(
      text: json['text'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      previewData: json['previewData'] == null
          ? null
          : PreviewData.fromJson(json['previewData'] as Map<String, dynamic>),
      repliedMessage: json['repliedMessage'] == null
          ? null
          : Message.fromJson(json['repliedMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PartialTextToJson(PartialText instance) =>
    <String, dynamic>{
      'metadata': instance.metadata,
      'previewData': instance.previewData,
      'repliedMessage': instance.repliedMessage,
      'text': instance.text,
    };
