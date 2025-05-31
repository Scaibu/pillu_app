// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'blocked_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedUser _$BlockedUserFromJson(Map<String, dynamic> json) => BlockedUser(
      blockedUserId: json['blockedUserId'] as String,
      blockedUserName: json['blockedUserName'] as String,
      blockedUserImageUrl: json['blockedUserImageUrl'] as String,
      status: json['status'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$BlockedUserToJson(BlockedUser instance) =>
    <String, dynamic>{
      'blockedUserId': instance.blockedUserId,
      'blockedUserName': instance.blockedUserName,
      'blockedUserImageUrl': instance.blockedUserImageUrl,
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
