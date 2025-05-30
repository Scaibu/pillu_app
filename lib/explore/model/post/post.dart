// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'post.g.dart';

enum PostType { text, image, video, poll }

/// Abstract base class for a post.
@JsonSerializable()
@immutable
abstract class Post {
  const factory Post({
    required final String id,
    required final String authorId,
    required final PostType type,
    required final DateTime createdAt,
    required final String appTabId,
    required final String appTabType,
    final String? text,
    final String? imageUrl,
    final String? videoUrl,
    final List<String>? pollOptions,
  }) = _Post;

  const Post._({
    required this.id,
    required this.authorId,
    required this.appTabId,
    required this.appTabType,
    required this.type,
    required this.createdAt,
    this.text,
    this.imageUrl,
    this.videoUrl,
    this.pollOptions,
  });

  factory Post.fromJson(final Map<String, dynamic> json) =>
      _$PostFromJson(json);

  final String id;
  final String authorId;
  final String appTabId;
  final String appTabType;
  final PostType type;
  final String? text;
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? pollOptions;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$PostToJson(this);

  List<Object?> get props => <Object?>[
        id,
        authorId,
        type,
        text,
        imageUrl,
        videoUrl,
        pollOptions,
        createdAt,
        appTabId,
        appTabType,
      ];

  Post copyWith({
    final String? id,
    final String? authorId,
    final PostType? type,
    final String? text,
    final String? imageUrl,
    final String? videoUrl,
    final List<String>? pollOptions,
    final DateTime? createdAt,
    final String appTabId,
    final String appTabType,
  });
}

class _Post extends Post {
  const _Post({
    required super.id,
    required super.authorId,
    required super.type,
    required super.createdAt,
    required super.appTabId,
    required super.appTabType,
    super.text,
    super.imageUrl,
    super.videoUrl,
    super.pollOptions,
  }) : super._();

  @override
  Post copyWith({
    final String? id,
    final String? authorId,
    final PostType? type,
    final String? text,
    final String? imageUrl,
    final String? videoUrl,
    final List<String>? pollOptions,
    final DateTime? createdAt,
    final String? appTabId,
    final String? appTabType,
  }) =>
      _Post(
        id: id ?? this.id,
        authorId: authorId ?? this.authorId,
        type: type ?? this.type,
        text: text ?? this.text,
        imageUrl: imageUrl ?? this.imageUrl,
        videoUrl: videoUrl ?? this.videoUrl,
        pollOptions: pollOptions ?? this.pollOptions,
        createdAt: createdAt ?? this.createdAt,
        appTabId: appTabId ?? this.appTabId,
        appTabType: appTabType ?? this.appTabType,
      );
}
