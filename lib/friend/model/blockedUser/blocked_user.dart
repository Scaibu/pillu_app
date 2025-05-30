// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'blocked_user.g.dart';

/// Represents a blocked user.
@JsonSerializable()
@immutable
class BlockedUser {
  const BlockedUser({
    required this.blockedUserId,
    required this.blockedUserName,
    required this.blockedUserImageUrl,
    required this.status,
    required this.createdAt,
  });

  factory BlockedUser.fromJson(final Map<String, dynamic> json) =>
      _$BlockedUserFromJson(json);

  final String blockedUserId;
  final String blockedUserName;
  final String blockedUserImageUrl;
  final String status; // 'blocked'
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$BlockedUserToJson(this);

  BlockedUser copyWith({
    final String? blockedUserId,
    final String? blockedUserName,
    final String? blockedUserImageUrl,
    final String? status,
    final DateTime? createdAt,
  }) =>
      BlockedUser(
        blockedUserId: blockedUserId ?? this.blockedUserId,
        blockedUserName: blockedUserName ?? this.blockedUserName,
        blockedUserImageUrl: blockedUserImageUrl ?? this.blockedUserImageUrl,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );

  List<Object?> get props => <Object?>[
        blockedUserId,
        blockedUserName,
        blockedUserImageUrl,
        status,
        createdAt,
      ];
}
