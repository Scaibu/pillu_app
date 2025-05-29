// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart';

import 'package:pillu_app/explore/model/post/post.dart';

part 'post_with_user.g.dart';

@JsonSerializable()
@immutable
class PostWithUser {
  const PostWithUser({
    required this.post,
    required this.user,
  });

  factory PostWithUser.fromJson(final Map<String, dynamic> json) =>
      _$PostWithUserFromJson(json);

  final Post post;
  final User user;

  Map<String, dynamic> toJson() => _$PostWithUserToJson(this);

  PostWithUser copyWith({
    final Post? post,
    final User? user,
  }) =>
      PostWithUser(
        post: post ?? this.post,
        user: user ?? this.user,
      );

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is PostWithUser &&
          runtimeType == other.runtimeType &&
          post == other.post &&
          user == other.user;

  @override
  int get hashCode => post.hashCode ^ user.hashCode;
}
