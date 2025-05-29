import 'package:intl/intl.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/bloc/explore_bloc.dart';
import 'package:pillu_app/explore/bloc/explore_state.dart';
import 'package:pillu_app/explore/model/post/post.dart';

class ListOfPost extends StatelessWidget {
  const ListOfPost({super.key});

  Widget buildPostListView(final BuildContext context, final List<Post> posts) {
    final ThemeData theme = Theme.of(context);
    final DateFormat dateFormat = DateFormat.yMMMd();

    return Column(
      children: posts
          .map(
            (final Post post) => Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          dateFormat.format(post.createdAt),
                          style: buildJostTextStyle(
                            fontSize: 8,
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (post.text != null && post.text!.isNotEmpty)
                          Text(
                            post.text!,
                            style: buildJostTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        if (post.imageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              post.imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (post.pollOptions != null &&
                            post.pollOptions!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: post.pollOptions!
                                .map(
                                  (final String option) => Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  '• $option',
                                  style: buildJostTextStyle(fontSize: 13),
                                ),
                              ),
                            )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                Divider(color: Theme.of(context).primaryColor,thickness: 0.2),
              ],
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<ExploreBloc, ExploreState>(
        builder: (
          final BuildContext context,
          final ExploreState state,
        ) {
          final List<Post> posts =
              state.postsByTabId[state.selectedTabId] ?? <Post>[];

          return buildPostListView(context, posts);
        },
      );
}
