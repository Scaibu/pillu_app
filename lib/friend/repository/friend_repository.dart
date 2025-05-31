import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/friend/model/blockedUser/blocked_user.dart';
import 'package:pillu_app/friend/model/friendRequest/friend_request.dart';
import 'package:pillu_app/friend/model/sentRequest/sent_request.dart';

class FriendRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<types.User>> getShuffledUserList({
    required final String currentUserId,
  }) async {
    try {
      // Fetch all data concurrently for better performance
      final List<Future<QuerySnapshot<Map<String, dynamic>>>> futures =
          <Future<QuerySnapshot<Map<String, dynamic>>>>[
        _firestore.collection('users').get(),
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('sent_requests')
            .get(),
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friend_requests')
            .get(),
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('blocked_users')
            .get(),
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friends')
            .get(),
      ];

      final List<QuerySnapshot<Map<String, dynamic>>> results =
          await Future.wait(futures);

      final QuerySnapshot<Map<String, dynamic>> allUsersSnapshot = results[0];
      final QuerySnapshot<Map<String, dynamic>> sentRequestsSnapshot =
          results[1];
      final QuerySnapshot<Map<String, dynamic>> receivedRequestsSnapshot =
          results[2];
      final QuerySnapshot<Map<String, dynamic>> blockedUsersSnapshot =
          results[3];
      final QuerySnapshot<Map<String, dynamic>> friendsSnapshot = results[4];

      // Aggregate all IDs to exclude
      final Set<String> excludedUserIds = <String>{
        currentUserId,
        ...sentRequestsSnapshot.docs.map(
          (final QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id,
        ),
        ...receivedRequestsSnapshot.docs.map(
          (final QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id,
        ),
        ...blockedUsersSnapshot.docs.map(
          (final QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id,
        ),
        ...friendsSnapshot.docs.map(
          (final QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.id,
        ),
      };

      // Process and filter users with null safety
      final List<types.User> filteredUsers = allUsersSnapshot.docs
          .where((final QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data = doc.data();
            // Basic validation - ensure required fields exist
            return data.isNotEmpty && (data['id'] != null || doc.id.isNotEmpty);
          })
          .map((final QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            final Map<String, dynamic> data =
                Map<String, dynamic>.from(doc.data());
            // Ensure document ID is available
            if (data['id'] == null || data['id'].toString().isEmpty) {
              data['id'] = doc.id;
            }

            // Convert Firestore Timestamps to milliseconds
            _convertTimestamps(data);

            return types.User.fromJson(data);
          })
          .where((final types.User user) => !excludedUserIds.contains(user.id))
          .toList()
        ..shuffle(Random());

      return filteredUsers;
    } catch (e) {
      throw Exception('Failed to fetch and shuffle users: $e');
    }
  }

  void _convertTimestamps(final Map<String, dynamic> data) {
    final List<String> timestampFields = <String>[
      'createdAt',
      'updatedAt',
      'lastSeen',
    ];

    for (final String field in timestampFields) {
      if (data[field] != null) {
        if (data[field].runtimeType.toString() == 'Timestamp') {
          data[field] = (data[field] as dynamic).millisecondsSinceEpoch as int;
        } else if (data[field] is num) {
          data[field] = (data[field] as num).toInt();
        }
      }
    }
  }

  Future<void> sendFriendRequest({
    required final String senderId,
    required final String senderName,
    required final String senderImageUrl,
    required final String receiverId,
    required final String receiverName,
    required final String receiverImageUrl,
    final String? message,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> senderFriendRef = _firestore
          .collection('users')
          .doc(senderId)
          .collection('friends')
          .doc(receiverId);

      final DocumentReference<Map<String, dynamic>> receiverFriendRef =
          _firestore
              .collection('users')
              .doc(receiverId)
              .collection('friends')
              .doc(senderId);

      final DocumentReference<Map<String, dynamic>> senderSentRequestRef =
          _firestore
              .collection('users')
              .doc(senderId)
              .collection('sent_requests')
              .doc(receiverId);

      final DocumentReference<Map<String, dynamic>> receiverFriendRequestRef =
          _firestore
              .collection('users')
              .doc(receiverId)
              .collection('friend_requests')
              .doc(senderId);

      final DocumentReference<Map<String, dynamic>> senderBlockedRef =
          _firestore
              .collection('users')
              .doc(senderId)
              .collection('blocked_users')
              .doc(receiverId);

      final DocumentReference<Map<String, dynamic>> receiverBlockedRef =
          _firestore
              .collection('users')
              .doc(receiverId)
              .collection('blocked_users')
              .doc(senderId);

      final List<DocumentSnapshot<Map<String, dynamic>>> futures =
          await Future.wait(<Future<DocumentSnapshot<Map<String, dynamic>>>>[
        senderFriendRef.get(),
        receiverFriendRef.get(),
        senderSentRequestRef.get(),
        receiverFriendRequestRef.get(),
        senderBlockedRef.get(),
        receiverBlockedRef.get(),
      ]);

      final DocumentSnapshot<Map<String, dynamic>> senderFriendDoc = futures[0];
      final DocumentSnapshot<Map<String, dynamic>> receiverFriendDoc =
          futures[1];
      final DocumentSnapshot<Map<String, dynamic>> senderSentRequestDoc =
          futures[2];
      final DocumentSnapshot<Map<String, dynamic>> receiverFriendRequestDoc =
          futures[3];
      final DocumentSnapshot<Map<String, dynamic>> senderBlockedDoc =
          futures[4];
      final DocumentSnapshot<Map<String, dynamic>> receiverBlockedDoc =
          futures[5];

      if (senderFriendDoc.exists || receiverFriendDoc.exists) {
        throw Exception('Users are already friends.');
      }

      if (senderSentRequestDoc.exists || receiverFriendRequestDoc.exists) {
        throw Exception('Friend request already pending.');
      }

      if (senderBlockedDoc.exists || receiverBlockedDoc.exists) {
        throw Exception('Cannot send friend request due to block.');
      }

      final FieldValue now = FieldValue.serverTimestamp();

      final WriteBatch batch = _firestore.batch()
        ..set(senderSentRequestRef, <String, Object>{
          'receiverId': receiverId,
          'receiverName': receiverName,
          'receiverImageUrl': receiverImageUrl,
          'status': 'pending',
          'createdAt': now,
          if (message != null) 'message': message,
        })
        ..set(receiverFriendRequestRef, <String, Object>{
          'senderId': senderId,
          'senderName': senderName,
          'senderImageUrl': senderImageUrl,
          'status': 'pending',
          'createdAt': now,
          if (message != null) 'message': message,
        });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  Future<void> acceptFriendRequest({
    required final String receiverId,
    required final String receiverName,
    required final String receiverImageUrl,
    required final String senderId,
    required final String senderName,
    required final String senderImageUrl,
  }) async {
    final DocumentReference<Map<String, dynamic>> receiverRequestRef =
        _firestore
            .collection('users')
            .doc(receiverId)
            .collection('friend_requests')
            .doc(senderId);

    final DocumentReference<Map<String, dynamic>> senderSentRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('sent_requests')
        .doc(receiverId);

    final DocumentReference<Map<String, dynamic>> receiverFriendsRef =
        _firestore
            .collection('users')
            .doc(receiverId)
            .collection('friends')
            .doc(senderId);

    final DocumentReference<Map<String, dynamic>> senderFriendsRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(receiverId);

    final FieldValue now = FieldValue.serverTimestamp();

    final WriteBatch batch = _firestore.batch()
      ..delete(receiverRequestRef)
      ..delete(senderSentRef)
      ..set(receiverFriendsRef, <String, Object>{
        'friendId': senderId,
        'friendName': senderName,
        'friendImageUrl': senderImageUrl,
        'createdAt': now,
      })
      ..set(senderFriendsRef, <String, Object>{
        'friendId': receiverId,
        'friendName': receiverName,
        'friendImageUrl': receiverImageUrl,
        'createdAt': now,
      });

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  Future<List<SentRequest>> getSentFriendRequests(final String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('sent_requests')
              .get();

      return querySnapshot.docs
          .map(
            (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                SentRequest.fromJson(doc.data()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch sent friend requests: $e');
    }
  }

  Future<List<BlockedUser>> getBlockedUsers(final String currentUserId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .get();

      return querySnapshot.docs
          .map(
            (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                BlockedUser.fromJson(doc.data()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch blocked users: $e');
    }
  }

  Future<List<FriendRequest>> getReceivedFriendRequests(
    final String userId,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('friend_requests')
              .get();

      return querySnapshot.docs
          .map(
            (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                FriendRequest.fromJson(doc.data()),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch received friend requests: $e');
    }
  }

  Future<void> declineFriendRequest({
    required final String receiverId,
    required final String senderId,
  }) async {
    final DocumentReference<Map<String, dynamic>> receiverRef = _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friend_requests')
        .doc(senderId);

    final DocumentReference<Map<String, dynamic>> senderRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('sent_requests')
        .doc(receiverId);

    final WriteBatch batch = _firestore.batch()
      ..delete(receiverRef)
      ..delete(senderRef);

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to decline friend request: $e');
    }
  }

  Future<void> blockUser({
    required final String currentUserId,
    required final String blockedUserId,
    required final String blockedUserName,
    required final String blockedUserImageUrl,
  }) async {
    final DocumentReference<Map<String, dynamic>> blockRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blocked_users')
        .doc(blockedUserId);

    final DocumentReference<Map<String, dynamic>> sentRequestRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('sent_requests')
        .doc(blockedUserId);

    final DocumentReference<Map<String, dynamic>> receivedRequestRef =
        _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('friend_requests')
            .doc(blockedUserId);

    final DocumentReference<Map<String, dynamic>> blockedUserSentRef =
        _firestore
            .collection('users')
            .doc(blockedUserId)
            .collection('sent_requests')
            .doc(currentUserId);

    final DocumentReference<Map<String, dynamic>> blockedUserReceivedRef =
        _firestore
            .collection('users')
            .doc(blockedUserId)
            .collection('friend_requests')
            .doc(currentUserId);

    final FieldValue now = FieldValue.serverTimestamp();

    final WriteBatch batch = _firestore.batch()
      ..set(blockRef, <String, Object>{
        'blockedUserId': blockedUserId,
        'blockedUserName': blockedUserName,
        'blockedUserImageUrl': blockedUserImageUrl,
        'status': 'blocked',
        'createdAt': now,
      })
      ..delete(sentRequestRef)
      ..delete(receivedRequestRef)
      ..delete(blockedUserSentRef)
      ..delete(blockedUserReceivedRef);

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  Future<List<types.User>> getFriendsList({
    required final String currentUserId,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> friendsSnapshot =
          await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('friends')
              .get();

      final List<types.User> friends = friendsSnapshot.docs
          .map((final QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        final Map<String, dynamic> data = doc.data();
        return types.User(
          id: data['friendId'] as String,
          firstName: data['friendName'] as String?,
          imageUrl: data['friendImageUrl'] as String?,
        );
      }).toList();

      return friends;
    } catch (e) {
      throw Exception('Failed to fetch friends list: $e');
    }
  }
}
