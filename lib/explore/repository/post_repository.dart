import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart';
import 'package:pillu_app/explore/model/post/post.dart';
import 'package:pillu_app/explore/model/postWithUser/post_with_user.dart';
import 'package:uuid/uuid.dart';

class PostRepository {
  Future<void> createPost(final Post post) async {
    final DocumentReference<Map<String, dynamic>> docRef =
        FirebaseFirestore.instance.collection('posts').doc(post.id);

    final Map<String, dynamic> data = <String, dynamic>{
      'id': post.id,
      'authorId': post.authorId,
      'appTabId': post.appTabId,
      'appTabType': post.appTabType,
      'type': post.type.name,
      'createdAt': post.createdAt.millisecondsSinceEpoch,
      if (post.text != null) 'text': post.text,
      if (post.imageUrl != null) 'imageUrl': post.imageUrl,
      if (post.videoUrl != null) 'videoUrl': post.videoUrl,
      if (post.pollOptions != null) 'pollOptions': post.pollOptions,
    };

    await docRef.set(data);
  }

  Future<void> updatePost(final Post post) async {
    final DocumentReference<Map<String, dynamic>> docRef =
        FirebaseFirestore.instance.collection('posts').doc(post.id);
    await docRef.update(<Object, Object?>{
      'text': post.text,
      'imageUrl': post.imageUrl,
      'videoUrl': post.videoUrl,
      'pollOptions': post.pollOptions,
      'type': post.type.name,
    });
  }

  Future<void> deletePost(final String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  Future<List<PostWithUser>> getPaginatedPosts({
    final DocumentSnapshot<Map<String, dynamic>>? startAfter,
    final int limit = 50,
  }) async {
    final Query<Map<String, dynamic>> postsQuery = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final Query<Map<String, dynamic>> query = startAfter != null
        ? postsQuery.startAfterDocument(startAfter)
        : postsQuery;

    final QuerySnapshot<Map<String, dynamic>> postsSnapshot = await query.get();
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> postDocs =
        postsSnapshot.docs;

    if (postDocs.isEmpty) {
      return <PostWithUser>[];
    }

    final Set<String> authorIds = postDocs
        .map(
          (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              doc.data()['authorId'] as String,
        )
        .toSet();

    final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: authorIds.toList())
            .get();

    final Map<String, Map<String, dynamic>> usersMap =
        <String, Map<String, dynamic>>{
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in usersSnapshot.docs)
        doc.id: doc.data(),
    };

    final List<PostWithUser> results = <PostWithUser>[];

    for (final QueryDocumentSnapshot<Map<String, dynamic>> postDoc
        in postDocs) {
      final Map<String, dynamic> postData = postDoc.data();
      final String authorId = postData['authorId'] as String;

      final Map<String, dynamic> userData =
          usersMap[authorId] ?? <String, dynamic>{};

      final Post post = Post(
        id: postData['id'] as String,
        authorId: authorId,
        appTabType: postData['appTabType'] as String,
        appTabId: postData['appTabId'] as String,
        type: PostType.values
            .firstWhere((final PostType e) => e.name == postData['type']),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(postData['createdAt'] as int),
        text: postData['text'] as String?,
        imageUrl: postData['imageUrl'] as String?,
        videoUrl: postData['videoUrl'] as String?,
        pollOptions:
            (postData['pollOptions'] as List<dynamic>?)?.cast<String>(),
      );

      final User user = User(
        id: userData['id'] as String? ?? '',
        firstName: userData['firstName'] as String?,
        lastName: userData['lastName'] as String?,
        imageUrl: userData['imageUrl'] as String?,
        metadata: userData['metadata'] as Map<String, dynamic>?,
        role: userData['role'] != null
            ? Role.values
                .firstWhere((final Role r) => r.name == userData['role'])
            : null,
      );

      results.add(PostWithUser(post: post, user: user));
    }

    return results;
  }

  Future<List<PostWithUser>> getPaginatedPostsByAppBarType({
    final DocumentSnapshot<Map<String, dynamic>>? startAfter,
    final int limit = 50,
    final String? appTabType, // NEW
  }) async {
    Query<Map<String, dynamic>> postsQuery = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (appTabType != null) {
      postsQuery = postsQuery.where('appTabType', isEqualTo: appTabType);
    }

    final Query<Map<String, dynamic>> query = startAfter != null
        ? postsQuery.startAfterDocument(startAfter)
        : postsQuery;

    final QuerySnapshot<Map<String, dynamic>> postsSnapshot = await query.get();
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> postDocs =
        postsSnapshot.docs;

    if (postDocs.isEmpty) {
      return <PostWithUser>[];
    }

    final Set<String> authorIds = postDocs
        .map((final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            doc.data()['authorId'] as String)
        .toSet();

    final QuerySnapshot<Map<String, dynamic>> usersSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: authorIds.toList())
            .get();

    final Map<String, Map<String, dynamic>> usersMap =
        <String, Map<String, dynamic>>{
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in usersSnapshot.docs)
        doc.id: doc.data(),
    };

    return postDocs
        .map((final QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> postData = doc.data();
      final String authorId = postData['authorId'] as String;

      final Post post = Post(
        id: postData['id'] as String,
        authorId: authorId,
        appTabType: postData['appTabType'] as String,
        appTabId: postData['appTabId'] as String,
        type: PostType.values
            .firstWhere((final PostType e) => e.name == postData['type']),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(postData['createdAt'] as int),
        text: postData['text'] as String?,
        imageUrl: postData['imageUrl'] as String?,
        videoUrl: postData['videoUrl'] as String?,
        pollOptions:
            (postData['pollOptions'] as List<dynamic>?)?.cast<String>(),
      );

      final Map<String, dynamic> userData =
          usersMap[authorId] ?? <String, dynamic>{};
      final User user = User(
        id: userData['id'] as String? ?? '',
        firstName: userData['firstName'] as String?,
        lastName: userData['lastName'] as String?,
        imageUrl: userData['imageUrl'] as String?,
        metadata: userData['metadata'] as Map<String, dynamic>?,
        role: userData['role'] != null
            ? Role.values
                .firstWhere((final Role r) => r.name == userData['role'])
            : null,
      );

      return PostWithUser(post: post, user: user);
    }).toList();
  }

  Future<String?> uploadImageToFirebase(
    final File imageFile,
    final String userId,
  ) async {
    try {
      final String uniqueImageName = '${const Uuid().v4()}.jpg';
      final String filePath = 'user/$userId/posts/images/$uniqueImageName';

      final Reference storageRef =
          FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (error) {
      debugPrint('Image upload failed: $error');
      return null;
    }
  }

  Future<void> deleteImageFromFirebase({required final String imageUrl}) async {
    try {
      final Reference storageRef =
          FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
      debugPrint('Image deleted successfully.');
    } catch (error) {
      debugPrint('Image deletion failed: $error');
    }
  }
}
