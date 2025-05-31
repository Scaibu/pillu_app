import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/friend/bloc/friend_bloc.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/bloc/friend_state.dart';
import 'package:pillu_app/friend/model/friendRequest/friend_request.dart';
import 'package:pillu_app/shared/text_styles.dart';

class FriendRequestsTab extends StatelessWidget {
  const FriendRequestsTab({super.key});

  @override
  Widget build(final BuildContext context) {
    final FriendBloc bloc = BlocProvider.of<FriendBloc>(context);
    final ThemeData theme = Theme.of(context);

    return BlocSelector<PilluAuthBloc, AuthDataState, auth.User?>(
      selector: (final AuthDataState state) => state.user,
      builder: (final BuildContext context, final auth.User? userState) {
        bloc.add(LoadReceivedFriendRequestsEvent(userState?.uid ?? ''));

        return BlocBuilder<FriendBloc, FriendState>(
          builder: (final BuildContext context, final FriendState state) {
            if (state.status == FriendStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == FriendStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load friend requests',
                  style: buildJostTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            } else if (state.receivedRequests.isEmpty) {
              return Center(
                child: Text(
                  'No friend requests',
                  style: buildJostTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.receivedRequests.length,
              itemBuilder: (final BuildContext context, final int index) {
                final FriendRequest request = state.receivedRequests[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(request.senderImageUrl),
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      radius: 26,
                    ),
                    title: Text(
                      request.senderName,
                      style: buildJostTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle:
                        request.message != null && request.message!.isNotEmpty
                            ? Text(
                                request.message!,
                                style: buildJostTextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              )
                            : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                          onPressed: () {
                            bloc.add(
                              AcceptFriendRequestEvent(
                                receiverId: userState?.uid ?? '',
                                receiverName:
                                    userState?.displayName ?? 'Current User',
                                receiverImageUrl: userState?.photoURL ?? '',
                                senderId: request.senderId,
                                senderName: request.senderName,
                                senderImageUrl: request.senderImageUrl,
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            textStyle: buildJostTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            bloc.add(
                              DeclineFriendRequestEvent(
                                receiverId: userState?.uid ?? '',
                                senderId: request.senderId,
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            textStyle: buildJostTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          child: const Text('Decline'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
