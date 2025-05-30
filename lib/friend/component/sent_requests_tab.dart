import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_bloc.dart';
import 'package:pillu_app/auth/bloc/auth_state.dart';
import 'package:pillu_app/friend/bloc/friend_bloc.dart';
import 'package:pillu_app/friend/bloc/friend_event.dart';
import 'package:pillu_app/friend/bloc/friend_state.dart';
import 'package:pillu_app/friend/model/sentRequest/sent_request.dart';

class SentRequestsTab extends StatelessWidget {
  const SentRequestsTab({super.key});

  @override
  Widget build(final BuildContext context) {
    final FriendBloc bloc = BlocProvider.of<FriendBloc>(context);

    return BlocSelector<PilluAuthBloc, AuthLocalState, auth.User?>(
      selector: (final AuthLocalState state) => (state as AuthDataState).user,
      builder: (final BuildContext context, final auth.User? userState) {
        bloc.add(LoadSentFriendRequestsEvent(userState?.uid ?? ''));

        return BlocBuilder<FriendBloc, FriendState>(
          builder: (final BuildContext context, final FriendState state) {
            if (state.status == FriendStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == FriendStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load sent requests',
                ),
              );
            } else if (state.sentRequests.isEmpty) {
              return const Center(child: Text('No sent requests'));
            }
            return ListView.builder(
              itemCount: state.sentRequests.length,
              itemBuilder: (final BuildContext context, final int index) {
                final SentRequest request = state.sentRequests[index];
                return ListTile(
                  title: Text(request.receiverName),
                  subtitle: Text(request.message ?? ''),
                  trailing: const Text('Pending'),
                );
              },
            );
          },
        );
      },
    );
  }
}
