// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'friend_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) =>
    FriendRequest(
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderImageUrl: json['senderImageUrl'] as String,
      status: json['status'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$FriendRequestToJson(FriendRequest instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderImageUrl': instance.senderImageUrl,
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'message': instance.message,
    };
