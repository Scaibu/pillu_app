// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'sent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SentRequest _$SentRequestFromJson(Map<String, dynamic> json) => SentRequest(
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      receiverImageUrl: json['receiverImageUrl'] as String,
      status: json['status'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SentRequestToJson(SentRequest instance) =>
    <String, dynamic>{
      'receiverId': instance.receiverId,
      'receiverName': instance.receiverName,
      'receiverImageUrl': instance.receiverImageUrl,
      'status': instance.status,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'message': instance.message,
    };
