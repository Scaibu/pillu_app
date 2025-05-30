import 'package:intl/intl.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/bloc/explore_bloc.dart';
import 'package:pillu_app/explore/bloc/explore_event.dart';
import 'package:pillu_app/explore/bloc/explore_state.dart';
import 'package:pillu_app/explore/components/list_of_post_shrimmer.dart';
import 'package:pillu_app/explore/components/post_component.dart';
import 'package:pillu_app/explore/model/postWithUser/post_with_user.dart';

class ListOfPost extends StatelessWidget {
  const ListOfPost({super.key});

  Widget buildPostListView(
    final BuildContext context,
    final List<PostWithUser> posts,
  ) {
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat.yMMMd();
    final ExploreBloc bloc = context.read<ExploreBloc>();
    final String? selectedTabId = bloc.state.selectedTabId;
    final String currentUserId =
        FirebaseChatCore.instance.firebaseUser?.uid ?? '';

    return Column(
      children: posts.map(
        (final PostWithUser post) {
          final bool isOwnedByCurrentUser = post.post.authorId == currentUserId;

          return Column(
            children: <Widget>[
              Dismissible(
                key: ValueKey<String>(post.post.id),
                direction: isOwnedByCurrentUser
                    ? DismissDirection.endToStart
                    : DismissDirection.none,
                background: isOwnedByCurrentUser
                    ? Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        color: theme.colorScheme.error,
                        child: Icon(
                          Icons.delete,
                          color: theme.colorScheme.onError,
                        ),
                      )
                    : const SizedBox.shrink(),
                confirmDismiss: (final _) async => isOwnedByCurrentUser,
                onDismissed: (final _) {
                  if (selectedTabId != null && isOwnedByCurrentUser) {
                    bloc.add(
                      DeletePost(
                        tabId: selectedTabId,
                        postId: post.post.id,
                        imageUrl: post.post.imageUrl,
                      ),
                    );
                  }
                },
                child: PostComponent(
                  theme: theme,
                  dateFormat: dateFormat,
                  post: post,
                ),
              ),
              Divider(
                color: Theme.of(context).primaryColor,
                thickness: 0.2,
              ),
            ],
          );
        },
      ).toList(),
    );
  }

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<ExploreBloc, ExploreState>(
        builder: (
          final BuildContext context,
          final ExploreState state,
        ) {
          final List<PostWithUser> posts =
              state.postsByTabId[state.selectedTabId] ?? <PostWithUser>[];

          if (state.status == ExploreStatus.loading) {
            return const ListOfPostShrimmer();
          }

          return buildPostListView(context, posts);
        },
      );
}
