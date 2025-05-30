import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart';
import 'package:pillu_app/friend/bloc/friend_bloc.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/bloc/friend_state.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<PilluAuthBloc, AuthLocalState, auth.User?>(
        selector: (final AuthLocalState state) => (state as AuthDataState).user,
        builder: (final BuildContext context, final auth.User? userState) {
          BlocProvider.of<FriendBloc>(context)
              .add(LoadFriendsListEvent(userState?.uid ?? ''));

          return BlocBuilder<FriendBloc, FriendState>(
            builder: (final BuildContext context, final FriendState state) {
              if (state.status == FriendStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state.status == FriendStatus.failure) {
                return Center(
                  child: Text(state.errorMessage ?? 'Failed to load friends'),
                );
              } else if (state.friends.isEmpty) {
                return const Center(child: Text('No friends'));
              }
              return ListView.builder(
                itemCount: state.friends.length,
                itemBuilder: (final BuildContext context, final int index) {
                  final User friend = state.friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(friend.imageUrl ?? ''),
                    ),
                    title: Text(friend.firstName ?? friend.id),
                    subtitle: Text(friend.lastName ?? ''),
                  );
                },
              );
            },
          );
        },
      );
}
