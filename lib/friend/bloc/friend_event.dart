abstract class FriendEvent {}

class FriendInitEvent extends FriendEvent {}

class LoadShuffledUsersEvent extends FriendEvent {
  LoadShuffledUsersEvent(this.currentUserId);

  final String currentUserId;
}

class LoadSentFriendRequestsEvent extends FriendEvent {
  LoadSentFriendRequestsEvent(this.userId);

  final String userId;
}

class LoadReceivedFriendRequestsEvent extends FriendEvent {
  LoadReceivedFriendRequestsEvent(this.userId);

  final String userId;
}

class LoadBlockedUsersEvent extends FriendEvent {
  LoadBlockedUsersEvent(this.currentUserId);

  final String currentUserId;
}

class LoadFriendsListEvent extends FriendEvent {
  LoadFriendsListEvent(this.currentUserId);

  final String currentUserId;
}

class SendFriendRequestEvent extends FriendEvent {
  SendFriendRequestEvent({
    required this.senderId,
    required this.senderName,
    required this.senderImageUrl,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImageUrl,
    this.message,
  });

  final String senderId;
  final String senderName;
  final String senderImageUrl;
  final String receiverId;
  final String receiverName;
  final String receiverImageUrl;
  final String? message;
}

class AcceptFriendRequestEvent extends FriendEvent {
  AcceptFriendRequestEvent({
    required this.receiverId,
    required this.receiverName,
    required this.receiverImageUrl,
    required this.senderId,
    required this.senderName,
    required this.senderImageUrl,
  });

  final String receiverId;
  final String receiverName;
  final String receiverImageUrl;
  final String senderId;
  final String senderName;
  final String senderImageUrl;
}

class DeclineFriendRequestEvent extends FriendEvent {
  DeclineFriendRequestEvent({
    required this.receiverId,
    required this.senderId,
  });

  final String receiverId;
  final String senderId;
}

class BlockUserEvent extends FriendEvent {
  BlockUserEvent({
    required this.currentUserId,
    required this.blockedUserId,
    required this.blockedUserName,
    required this.blockedUserImageUrl,
  });

  final String currentUserId;
  final String blockedUserId;
  final String blockedUserName;
  final String blockedUserImageUrl;
}
