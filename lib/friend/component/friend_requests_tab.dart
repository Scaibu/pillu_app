import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/friend/bloc/friend_bloc.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/bloc/friend_state.dart';
import 'package:pillu_app/friend/model/friendRequest/friend_request.dart';

class FriendRequestsTab extends StatelessWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<PilluAuthBloc, AuthLocalState, auth.User?>(
        selector: (final AuthLocalState state) => (state as AuthDataState).user,
        builder: (final BuildContext context, final auth.User? userState) {
          final FriendBloc bloc = BlocProvider.of<FriendBloc>(context)
            ..add(LoadReceivedFriendRequestsEvent(userState?.uid ?? ''));

          return BlocBuilder<FriendBloc, FriendState>(
            builder: (final BuildContext context, final FriendState state) {
              if (state.status == FriendStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status == FriendStatus.failure) {
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Failed to load friend requests',
                  ),
                );
              } else if (state.receivedRequests.isEmpty) {
                return const Center(child: Text('No friend requests'));
              }
              return ListView.builder(
                itemCount: state.receivedRequests.length,
                itemBuilder: (final BuildContext context, final int index) {
                  final FriendRequest request = state.receivedRequests[index];
                  return ListTile(
                    title: Text(request.senderName),
                    subtitle: Text(request.message ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            bloc.add(
                              AcceptFriendRequestEvent(
                                receiverId: 'currentUserId',
                                receiverName: 'Current User',
                                receiverImageUrl: '',
                                senderId: request.senderId,
                                senderName: request.senderName,
                                senderImageUrl: request.senderImageUrl,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            bloc.add(
                              DeclineFriendRequestEvent(
                                receiverId: 'currentUserId',
                                senderId: request.senderId,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
}
