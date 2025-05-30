// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'friend_request.g.dart';

/// Represents a received friend request.
@JsonSerializable()
@immutable
class FriendRequest {
  const FriendRequest({
    required this.senderId,
    required this.senderName,
    required this.senderImageUrl,
    required this.status,
    required this.createdAt,
    this.message,
  });

  factory FriendRequest.fromJson(final Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);

  final String senderId;
  final String senderName;
  final String senderImageUrl;
  final String status; // e.g., 'pending', 'accepted'
  final DateTime createdAt;
  final String? message;

  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);

  FriendRequest copyWith({
    final String? senderId,
    final String? senderName,
    final String? senderImageUrl,
    final String? status,
    final DateTime? createdAt,
    final String? message,
  }) =>
      FriendRequest(
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        senderImageUrl: senderImageUrl ?? this.senderImageUrl,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        message: message ?? this.message,
      );

  List<Object?> get props => <Object?>[
        senderId,
        senderName,
        senderImageUrl,
        status,
        createdAt,
        message,
      ];
}
