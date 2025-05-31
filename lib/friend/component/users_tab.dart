import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:pillu_app/core/library/pillu_lib.dart' hide User;
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart';
import 'package:pillu_app/friend/bloc/friend_bloc.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/bloc/friend_state.dart';

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  String _userName(final User user) => <String>[
        (user.firstName ?? user.id).replaceAll(RegExp(r'\s+'), ' ').trim(),
        (user.lastName ?? '').replaceAll(RegExp(r'\s+'), ' ').trim(),
      ].where((final String s) => s.isNotEmpty).join(' ');

  @override
  Widget build(final BuildContext context) {
    context.read<FriendBloc>().add(FriendInitEvent());

    return BlocSelector<PilluAuthBloc, AuthDataState, auth.User?>(
      selector: (final AuthDataState state) => state.user,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.error,
                ),
              ),
            );
          } else if (state.suggestedUsers.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: buildJostTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: state.suggestedUsers.length,
            itemBuilder: (final BuildContext context, final int index) {
              final User user = state.suggestedUsers[index];

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
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundImage: user.imageUrl != null
                        ? NetworkImage(user.imageUrl!)
                        : null,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    radius: 26,
                    child: user.imageUrl == null
                        ? Text(
                            user.firstName!.isNotEmpty
                                ? user.firstName![0].toUpperCase()
                                : '?',
                            style: buildJostTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    _userName(user),
                    style: buildJostTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final User? currentUser =
                          await FirebaseChatCore.instance.user();
                      if (currentUser == null) {
                        return;
                      }

                      if (context.mounted) {
                        final String? result = await showMessageBox(
                          context: context,
                          title: 'Write a message',
                          hint: 'Type your reply here...',
                        );

                        if (context.mounted && result != null) {
                          context.read<FriendBloc>().add(
                                SendFriendRequestEvent(
                                  senderId: currentUser.id,
                                  senderName: _userName(currentUser),
                                  senderImageUrl: currentUser.imageUrl ?? '',
                                  receiverId: user.id,
                                  receiverName: _userName(user),
                                  receiverImageUrl: user.imageUrl ?? '',
                                  message: (result ?? '').isNotEmpty
                                      ? result
                                      : "'Hey, I’d love to connect!'",
                                ),
                              );


                        }
                      }
                    },
                    child: Text(
                      'Add',
                      style: buildJostTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
