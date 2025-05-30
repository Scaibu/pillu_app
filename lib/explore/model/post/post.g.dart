// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      type: $enumDecode(_$PostTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      appTabId: json['appTabId'] as String,
      appTabType: json['appTabType'] as String,
      text: json['text'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      pollOptions: (json['pollOptions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'appTabId': instance.appTabId,
      'appTabType': instance.appTabType,
      'type': _$PostTypeEnumMap[instance.type]!,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'pollOptions': instance.pollOptions,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$PostTypeEnumMap = {
  PostType.text: 'text',
  PostType.image: 'image',
  PostType.video: 'video',
  PostType.poll: 'poll',
};
