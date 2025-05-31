// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/shared/converter/timestamp_converter.dart';

part 'sent_request.g.dart';

/// Represents a friend request sent by current user.
@JsonSerializable()
@immutable
class SentRequest {
  const SentRequest({
    required this.receiverId,
    required this.receiverName,
    required this.receiverImageUrl,
    required this.status,
    required this.createdAt,
    this.message,
  });

  factory SentRequest.fromJson(final Map<String, dynamic> json) =>
      _$SentRequestFromJson(json);

  final String receiverId;
  final String receiverName;
  final String receiverImageUrl;
  final String status;

  @TimestampConverter()
  final DateTime createdAt;
  final String? message;

  Map<String, dynamic> toJson() => _$SentRequestToJson(this);

  SentRequest copyWith({
    final String? receiverId,
    final String? receiverName,
    final String? receiverImageUrl,
    final String? status,
    final DateTime? createdAt,
    final String? message,
  }) =>
      SentRequest(
        receiverId: receiverId ?? this.receiverId,
        receiverName: receiverName ?? this.receiverName,
        receiverImageUrl: receiverImageUrl ?? this.receiverImageUrl,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        message: message ?? this.message,
      );

  List<Object?> get props => <Object?>[
        receiverId,
        receiverName,
        receiverImageUrl,
        status,
        createdAt,
        message,
      ];
}
