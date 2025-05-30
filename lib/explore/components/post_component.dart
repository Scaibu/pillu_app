import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:pillu_app/core/library/pillu_lib.dart';
import 'package:pillu_app/explore/model/postWithUser/post_with_user.dart';

class PostComponent extends StatelessWidget {
  const PostComponent({
    required this.theme,
    required this.dateFormat,
    required this.post,
    super.key,
  });

  final ThemeData theme;
  final DateFormat dateFormat;
  final PostWithUser post;

  @override
  Widget build(final BuildContext context) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "${post.user.firstName ?? ''}"
                              " ${post.user.lastName ?? ''}",
                          style: buildJostTextStyle(
                            fontSize: 8,
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                      Text(
                        dateFormat.format(post.post.createdAt),
                        style: buildJostTextStyle(
                          fontSize: 8,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (post.post.text != null && post.post.text!.isNotEmpty)
                    Text(
                      post.post.text!,
                      style: buildJostTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  if (post.post.imageUrl != null)
                    LayoutBuilder(
                      builder: (final BuildContext context,
                          final BoxConstraints constraints) {
                        final double width = constraints.maxWidth;
                        final double height = constraints.maxHeight;

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: post.post.imageUrl!,
                            cacheKey: post.post.imageUrl!,
                            memCacheWidth: width.isFinite
                                ? width.toInt()
                                : null,
                            memCacheHeight: height.isFinite
                                ? height.toInt()
                                : null,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),

                  if (post.post.pollOptions != null &&
                      post.post.pollOptions!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: post.post.pollOptions!
                          .map(
                            (final String option) =>
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
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

        ],
      );
}
