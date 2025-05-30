import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:pillu_app/core/library/pillu_lib.dart' hide User;
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart';
import 'package:pillu_app/friend/bloc/friend_bloc.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/bloc/friend_state.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<PilluAuthBloc, AuthLocalState, auth.User?>(
        selector: (final AuthLocalState state) => (state as AuthDataState).user,
        builder: (final BuildContext context, final auth.User? userState) =>
            BlocBuilder<FriendBloc, FriendState>(
          builder: (final BuildContext context, final FriendState state) {
            final ThemeData theme = Theme.of(context);

            if (state.status == FriendStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == FriendStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load users',
                  style: buildJostTextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              );
            } else if (state.suggestedUsers.isEmpty) {
              return Center(
                child: Text(
                  'No users found',
                  style: buildJostTextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              );
            }

            return ListView.separated(
              itemCount: state.suggestedUsers.length,
              separatorBuilder: (final BuildContext context, final int index) =>
                  Divider(
                color: Theme.of(context).primaryColor,
                thickness: 0.2,
              ),
              itemBuilder: (final BuildContext context, final int index) {
                final User user = state.suggestedUsers[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.imageUrl ?? ''),
                        maxRadius: 25,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${user.firstName ?? user.id}${user.lastName ?? ''}",
                          style: buildJostTextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final User? currentUser =
                              await FirebaseChatCore.instance.user();
                          if (currentUser == null) {
                            return;
                          }

                          if (context.mounted) {
                            context.read<FriendBloc>().add(
                                  SendFriendRequestEvent(
                                    senderId: currentUser.id,
                                    senderName:
                                        currentUser.firstName ?? 'Unknown',
                                    senderImageUrl: currentUser.imageUrl ?? '',
                                    receiverId: user.id,
                                    receiverName: user.firstName ?? 'NoName',
                                    receiverImageUrl: user.imageUrl ?? '',
                                    message: "Let's connect!",
                                  ),
                                );
                          }
                        },
                        child: Text(
                          'Add',
                          style: buildJostTextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
}
