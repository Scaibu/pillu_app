import 'package:equatable/equatable.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/friend/model/blockedUser/blocked_user.dart';
import 'package:pillu_app/friend/model/friendRequest/friend_request.dart';
import 'package:pillu_app/friend/model/sentRequest/sent_request.dart';

enum FriendStatus {
  initial,
  loading,
  success,
  failure,
}

class FriendState extends Equatable {
  const FriendState({
    this.status = FriendStatus.initial,
    this.suggestedUsers = const <types.User>[],
    this.friends = const <types.User>[],
    this.receivedRequests = const <FriendRequest>[],
    this.sentRequests = const <SentRequest>[],
    this.blockedUsers = const <BlockedUser>[],
    this.errorMessage,
  });

  final FriendStatus status;
  final List<types.User> suggestedUsers;
  final List<types.User> friends;
  final List<FriendRequest> receivedRequests;
  final List<SentRequest> sentRequests;
  final List<BlockedUser> blockedUsers;
  final String? errorMessage;

  FriendState copyWith({
    final FriendStatus? status,
    final List<types.User>? suggestedUsers,
    final List<types.User>? friends,
    final List<FriendRequest>? receivedRequests,
    final List<SentRequest>? sentRequests,
    final List<BlockedUser>? blockedUsers,
    final String? errorMessage,
  }) =>
      FriendState(
        status: status ?? this.status,
        suggestedUsers: suggestedUsers ?? this.suggestedUsers,
        friends: friends ?? this.friends,
        receivedRequests: receivedRequests ?? this.receivedRequests,
        sentRequests: sentRequests ?? this.sentRequests,
        blockedUsers: blockedUsers ?? this.blockedUsers,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => <Object?>[
        status,
        suggestedUsers,
        friends,
        receivedRequests,
        sentRequests,
        blockedUsers,
        errorMessage,
      ];
}
