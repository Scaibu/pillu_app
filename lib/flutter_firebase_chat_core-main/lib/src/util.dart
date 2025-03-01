import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;

/// Extension with one [toShortString] method.
extension RoleToShortString on types.Role {
  /// Converts enum to the string equal to enum's name.
  String toShortString() => toString().split('.').last;
}

/// Extension with one [toShortString] method.
extension RoomTypeToShortString on types.RoomType {
  /// Converts enum to the string equal to enum's name.
  String toShortString() => toString().split('.').last;
}

/// Fetches user from Firebase and returns a promise.
Future<Map<String, dynamic>> fetchUser(
  final FirebaseFirestore instance,
  final String userId,
  final String usersCollectionName, {
  final String? role,
}) async {
  final DocumentSnapshot<Map<String, dynamic>> doc =
      await instance.collection(usersCollectionName).doc(userId).get();

  final Map<String, dynamic> data = doc.data()!;

  data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
  data['id'] = doc.id;
  data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
  data['role'] = role;
  data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

  return data;
}

/// Returns a list of [types.Room] created from Firebase query.
/// If room has 2 participants, sets correct room name and image.
Future<List<types.Room>> processRoomsQuery(
  final User firebaseUser,
  final FirebaseFirestore instance,
  final QuerySnapshot<Map<String, dynamic>> query,
  final String usersCollectionName,
) async {
  final Iterable<Future<types.Room>> futures = query.docs.map(
    (final QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
        processRoomDocument(
      doc,
      firebaseUser,
      instance,
      usersCollectionName,
    ),
  );

  return Future.wait(futures);
}

/// Returns a [types.Room] created from Firebase document.
Future<types.Room> processRoomDocument(
  final DocumentSnapshot<Map<String, dynamic>> doc,
  final User firebaseUser,
  final FirebaseFirestore instance,
  final String usersCollectionName,
) async {
  final Map<String, dynamic> data = doc.data()!;

  data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
  data['id'] = doc.id;
  data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

  String? imageUrl = data['imageUrl'] as String?;
  String? name = data['name'] as String?;
  final String type = data['type'] as String;
  final List<dynamic> userIds = data['userIds'] as List<dynamic>;
  final Map<String, dynamic>? userRoles =
      data['userRoles'] as Map<String, dynamic>?;

  final List<Map<String, dynamic>> users = await Future.wait(
    userIds.map(
      (final dynamic userId) => fetchUser(
        instance,
        userId as String,
        usersCollectionName,
        role: userRoles?[userId] as String?,
      ),
    ),
  );

  if (type == types.RoomType.direct.toShortString()) {
    try {
      final Map<String, dynamic> otherUser = users.firstWhere(
        (final Map<String, dynamic> u) => u['id'] != firebaseUser.uid,
      );

      imageUrl = otherUser['imageUrl'] as String?;
      name = '${otherUser['firstName'] ?? ''} ${otherUser['lastName'] ?? ''}'
          .trim();
    } catch (e) {
      // Do nothing if other user is not found, because he should be found.
      // Consider falling back to some default values.
    }
  }

  data['imageUrl'] = imageUrl;
  data['name'] = name;
  data['users'] = users;

  if (data['lastMessages'] != null) {
    final dynamic lastMessages = data['lastMessages'].map((final dynamic lm) {
      final Map<String, dynamic> author = users.firstWhere(
        (final Map<String, dynamic> u) => u['id'] == lm['authorId'],
        orElse: () => <String, dynamic>{'id': lm['authorId'] as String},
      );

      lm['author'] = author;
      lm['createdAt'] = lm['createdAt']?.millisecondsSinceEpoch;
      lm['id'] = lm['id'] ?? '';
      lm['updatedAt'] = lm['updatedAt']?.millisecondsSinceEpoch;

      return lm;
    }).toList();

    data['lastMessages'] = lastMessages;
  }

  return types.Room.fromJson(data);
}
