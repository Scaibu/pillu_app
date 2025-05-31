import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/bloc/friend_state.dart';
import 'package:pillu_app/friend/model/blockedUser/blocked_user.dart';
import 'package:pillu_app/friend/model/friendRequest/friend_request.dart';
import 'package:pillu_app/friend/model/sentRequest/sent_request.dart';
import 'package:pillu_app/friend/repository/friend_repository.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc({required this.repository}) : super(const FriendState()) {
    on<FriendInitEvent>(_onInit);
    on<LoadShuffledUsersEvent>(_onLoadShuffledUsers);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<DeclineFriendRequestEvent>(_onDeclineFriendRequest);
    on<BlockUserEvent>(_onBlockUser);
    on<LoadSentFriendRequestsEvent>(_onLoadSentRequests);
    on<LoadBlockedUsersEvent>(_onLoadBlockedUsers);
    on<LoadReceivedFriendRequestsEvent>(_onLoadReceivedRequests);
    on<LoadFriendsListEvent>(_onLoadFriendsList);
  }

  final FriendRepository repository;

  Future<void> _onInit(
    final FriendInitEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));

    try {
      final auth.User? currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(
          state.copyWith(
            status: FriendStatus.failure,
            errorMessage: 'User not logged in',
          ),
        );
        return;
      }

      final List<User> suggestedUsers = await repository.getShuffledUserList(
        currentUserId: currentUser.uid,
      );

      emit(
        state.copyWith(
          status: FriendStatus.success,
          suggestedUsers: suggestedUsers,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadShuffledUsers(
    final LoadShuffledUsersEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      final List<User> users = await repository.getShuffledUserList(
        currentUserId: event.currentUserId,
      );
      emit(
        state.copyWith(
          suggestedUsers: users,
          status: FriendStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to fetch suggested users',
        ),
      );
    }
  }

  Future<void> _onSendFriendRequest(
    final SendFriendRequestEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      await repository.sendFriendRequest(
        senderId: event.senderId,
        senderName: event.senderName,
        senderImageUrl: event.senderImageUrl,
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        receiverImageUrl: event.receiverImageUrl,
        message: event.message,
      );
      emit(state.copyWith(status: FriendStatus.success));

      add(FriendInitEvent());
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to send friend request',
        ),
      );
    }
  }

  Future<void> _onAcceptFriendRequest(
    final AcceptFriendRequestEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      await repository.acceptFriendRequest(
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        receiverImageUrl: event.receiverImageUrl,
        senderId: event.senderId,
        senderName: event.senderName,
        senderImageUrl: event.senderImageUrl,
      );
      emit(state.copyWith(status: FriendStatus.success));

      add(LoadReceivedFriendRequestsEvent(event.senderId ?? ''));
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to accept friend request',
        ),
      );
    }
  }

  Future<void> _onDeclineFriendRequest(
    final DeclineFriendRequestEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      await repository.declineFriendRequest(
        receiverId: event.receiverId,
        senderId: event.senderId,
      );
      emit(state.copyWith(status: FriendStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to decline friend request',
        ),
      );
    }
  }

  Future<void> _onBlockUser(
    final BlockUserEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      await repository.blockUser(
        currentUserId: event.currentUserId,
        blockedUserId: event.blockedUserId,
        blockedUserName: event.blockedUserName,
        blockedUserImageUrl: event.blockedUserImageUrl,
      );
      emit(state.copyWith(status: FriendStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to block user',
        ),
      );
    }
  }

  Future<void> _onLoadSentRequests(
    final LoadSentFriendRequestsEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      final List<SentRequest> requests =
          await repository.getSentFriendRequests(event.userId);
      emit(
        state.copyWith(
          sentRequests: requests,
          status: FriendStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to load sent friend requests',
        ),
      );
    }
  }

  Future<void> _onLoadBlockedUsers(
    final LoadBlockedUsersEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      final List<BlockedUser> blocked =
          await repository.getBlockedUsers(event.currentUserId);
      emit(
        state.copyWith(
          blockedUsers: blocked,
          status: FriendStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to load blocked users',
        ),
      );
    }
  }

  Future<void> _onLoadReceivedRequests(
    final LoadReceivedFriendRequestsEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      final List<FriendRequest> received =
          await repository.getReceivedFriendRequests(event.userId);
      emit(
        state.copyWith(
          receivedRequests: received,
          status: FriendStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to load received friend requests',
        ),
      );
    }
  }

  Future<void> _onLoadFriendsList(
    final LoadFriendsListEvent event,
    final Emitter<FriendState> emit,
  ) async {
    emit(state.copyWith(status: FriendStatus.loading));
    try {
      final List<User> friends = await repository.getFriendsList(
        currentUserId: event.currentUserId,
      );
      emit(
        state.copyWith(
          friends: friends,
          status: FriendStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FriendStatus.failure,
          errorMessage: 'Failed to load friends list',
        ),
      );
    }
  }
}
