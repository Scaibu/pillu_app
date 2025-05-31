import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/friend/bloc/friend_bloc.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/bloc/friend_state.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final FriendBloc bloc = BlocProvider.of<FriendBloc>(context);

    return BlocSelector<PilluAuthBloc, AuthDataState, auth.User?>(
      selector: (final AuthDataState state) => state.user,
      builder: (final BuildContext context, final auth.User? userState) {
        bloc.add(LoadFriendsListEvent(userState?.uid ?? ''));

        return BlocBuilder<FriendBloc, FriendState>(
          builder: (final BuildContext context, final FriendState state) {
            if (state.status == FriendStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == FriendStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load friends',
                  style: buildJostTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            } else if (state.friends.isEmpty) {
              return Center(
                child: Text(
                  'No friends',
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
              itemCount: state.friends.length,
              itemBuilder: (final BuildContext context, final int index) {
                final types.User friend = state.friends[index];

                final String cleanName = <String>[
                  (friend.firstName ?? friend.id)
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim(),
                  (friend.lastName ?? '').replaceAll(RegExp(r'\s+'), ' ').trim()
                ].where((final String s) => s.isNotEmpty).join(' ');

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
                      backgroundImage: NetworkImage(friend.imageUrl ?? ''),
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      radius: 26,
                    ),
                    title: Text(
                      cleanName,
                      style: buildJostTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Friend', // You can make this dynamic later
                      style: buildJostTextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
