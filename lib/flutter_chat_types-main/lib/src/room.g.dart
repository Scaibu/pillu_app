// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
      id: json['id'] as String,
      type: $enumDecodeNullable(_$RoomTypeEnumMap, json['type']),
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: (json['createdAt'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      lastMessages: (json['lastMessages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      name: json['name'] as String?,
      updatedAt: (json['updatedAt'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'createdAt': instance.createdAt,
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'lastMessages': instance.lastMessages,
      'metadata': instance.metadata,
      'name': instance.name,
      'type': _$RoomTypeEnumMap[instance.type],
      'updatedAt': instance.updatedAt,
      'users': instance.users,
    };

const _$RoomTypeEnumMap = {
  RoomType.channel: 'channel',
  RoomType.direct: 'direct',
  RoomType.group: 'group',
};
