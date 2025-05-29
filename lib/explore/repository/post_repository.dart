import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart';
import 'package:pillu_app/explore/model/post/post.dart';
import 'package:pillu_app/explore/model/postWithUser/post_with_user.dart';

class PostRepository {
  Future<void> createPost(final Post post) async {
    final DocumentReference<Map<String, dynamic>> docRef =
        FirebaseFirestore.instance.collection('posts').doc(post.id);

    final Map<String, dynamic> data = <String, dynamic>{
      'id': post.id,
      'authorId': post.authorId,
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
        createdAt: userData['createdAt'] as int?,
        firstName: userData['firstName'] as String?,
        lastName: userData['lastName'] as String?,
        imageUrl: userData['imageUrl'] as String?,
        lastSeen: userData['lastSeen'] as int?,
        metadata: userData['metadata'] as Map<String, dynamic>?,
        role: userData['role'] != null
            ? Role.values
                .firstWhere((final Role r) => r.name == userData['role'])
            : null,
        updatedAt: userData['updatedAt'] as int?,
      );

      results.add(PostWithUser(post: post, user: user));
    }

    return results;
  }
}
