// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.0

part of 'post_with_user.dart';


// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostWithUser _$PostWithUserFromJson(Map<String, dynamic> json) => PostWithUser(
      post: Post.fromJson(json['post'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostWithUserToJson(PostWithUser instance) =>
    <String, dynamic>{
      'post': instance.post,
      'user': instance.user,
    };
