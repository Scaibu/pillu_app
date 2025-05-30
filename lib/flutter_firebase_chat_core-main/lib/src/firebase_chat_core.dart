import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pillu_app/core/library/flutter_chat_types.dart' as types;
import 'package:pillu_app/core/library/pillu_lib.dart';

import 'firebase_chat_core_config.dart';
import 'util.dart';

/// Provides access to Firebase chat data. Singleton, use
/// FirebaseChatCore.instance to aceess methods.
class FirebaseChatCore {
  FirebaseChatCore._privateConstructor() {
    FirebaseAuth.instance.authStateChanges().listen((final User? user) {
      firebaseUser = user;
    });
  }

  /// Config to set custom names for rooms and users collections. Also
  /// see [FirebaseChatCoreConfig].
  FirebaseChatCoreConfig config = const FirebaseChatCoreConfig(
    null,
    'rooms',
    'users',
  );

  /// Current logged in user in Firebase. Does not update automatically.
  /// Use [FirebaseAuth.authStateChanges] to listen to the state changes.
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  /// Singleton instance.
  static final FirebaseChatCore instance =
      FirebaseChatCore._privateConstructor();

  /// Gets proper [FirebaseFirestore] instance.
  FirebaseFirestore getFirebaseFirestore() => config.firebaseAppName != null
      ? FirebaseFirestore.instanceFor(
          app: Firebase.app(config.firebaseAppName!),
        )
      : FirebaseFirestore.instance;

  /// Sets custom config to change default names for rooms
  /// and users collections. Also see [FirebaseChatCoreConfig].
  Future<void> setConfig(
    final FirebaseChatCoreConfig firebaseChatCoreConfig,
  ) async {
    config = firebaseChatCoreConfig;
  }

  /// Creates a chat group room with [users]. Creator is automatically
  /// added to the group. [name] is required and will be used as
  /// a group name. Add an optional [imageUrl] that will be a group avatar
  /// and [metadata] for any additional custom data.
  Future<types.Room> createGroupRoom({
    final types.Role creatorRole = types.Role.admin,
    final String? imageUrl,
    final Map<String, dynamic>? metadata,
    required final String name,
    required final List<types.User> users,
  }) async {
    if (firebaseUser == null) {
      return Future<types.Room>.error('User does not exist');
    }

    final Map<String, dynamic> currentUser = await fetchUser(
      getFirebaseFirestore(),
      firebaseUser!.uid,
      config.usersCollectionName,
      role: creatorRole.toShortString(),
    );

    final List<types.User> roomUsers =
        <types.User>[types.User.fromJson(currentUser)] + users;

    final DocumentReference<Map<String, dynamic>> room =
        await getFirebaseFirestore()
            .collection(config.roomsCollectionName)
            .add(<String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
      'metadata': metadata,
      'name': name,
      'type': types.RoomType.group.toShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userIds': roomUsers.map((final types.User u) => u.id).toList(),
      'userRoles': roomUsers.fold<Map<String, String?>>(
        <String, String?>{},
        (final Map<String, String?> previousValue, final types.User user) =>
            <String, String?>{
          ...previousValue,
          user.id: user.role?.toShortString(),
        },
      ),
    });

    return types.Room(
      id: room.id,
      imageUrl: imageUrl,
      metadata: metadata,
      name: name,
      type: types.RoomType.group,
      users: roomUsers,
    );
  }

  /// Creates a direct chat for 2 people. Add [metadata] for any additional
  /// custom data.
  Future<types.Room> createRoom(
    final types.User otherUser, {
    final Map<String, dynamic>? metadata,
  }) async {
    final User? fu = firebaseUser;

    if (fu == null) {
      return Future<types.Room>.error('User does not exist');
    }

    // Sort two user ids array to always have the same array for both users,
    // this will make it easy to find the room if exist and make one read only.
    final List<String> userIds = <String>[fu.uid, otherUser.id]..sort();

    final QuerySnapshot<Map<String, dynamic>> roomQuery =
        await getFirebaseFirestore()
            .collection(config.roomsCollectionName)
            .where('type', isEqualTo: types.RoomType.direct.toShortString())
            .where('userIds', isEqualTo: userIds)
            .limit(1)
            .get();

    // Check if room already exist.
    if (roomQuery.docs.isNotEmpty) {
      final types.Room room = (await processRoomsQuery(
        fu,
        getFirebaseFirestore(),
        roomQuery,
        config.usersCollectionName,
      ))
          .first;

      return room;
    }

    // To support old chats created without sorted array,
    // try to check the room by reversing user ids array.
    final QuerySnapshot<Map<String, dynamic>> oldRoomQuery =
        await getFirebaseFirestore()
            .collection(config.roomsCollectionName)
            .where('type', isEqualTo: types.RoomType.direct.toShortString())
            .where('userIds', isEqualTo: userIds.reversed.toList())
            .limit(1)
            .get();

    // Check if room already exist.
    if (oldRoomQuery.docs.isNotEmpty) {
      final types.Room room = (await processRoomsQuery(
        fu,
        getFirebaseFirestore(),
        oldRoomQuery,
        config.usersCollectionName,
      ))
          .first;

      return room;
    }

    final Map<String, dynamic> currentUser = await fetchUser(
      getFirebaseFirestore(),
      fu.uid,
      config.usersCollectionName,
    );

    final List<types.User> users = <types.User>[
      types.User.fromJson(currentUser),
      otherUser,
    ];

    // Create new room with sorted user ids array.
    final DocumentReference<Map<String, dynamic>> room =
        await getFirebaseFirestore()
            .collection(config.roomsCollectionName)
            .add(<String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
      'imageUrl': null,
      'metadata': metadata,
      'name': null,
      'type': types.RoomType.direct.toShortString(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userIds': userIds,
      'userRoles': null,
    });

    return types.Room(
      id: room.id,
      metadata: metadata,
      type: types.RoomType.direct,
      users: users,
    );
  }

  /// Creates [types.User] in Firebase to store name and avatar used on
  /// rooms list.
  Future<void> createUserInFirestore(final types.User user) async {
    final Map<String, dynamic> data = <String, dynamic>{
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if ((user.firstName ?? '').trim().isNotEmpty) {
      data['firstName'] = user.firstName;
    }

    if ((user.lastName ?? '').trim().isNotEmpty) {
      data['lastName'] = user.lastName;
    }

    if ((user.imageUrl ?? '').trim().isNotEmpty) {
      data['imageUrl'] = user.imageUrl;
    }

    if ((user.metadata ?? <String, dynamic>{}).isNotEmpty) {
      data['metadata'] = user.metadata;
    }

    if (user.role != null) {
      final String roleString = user.role!.toShortString();
      if (roleString.isNotEmpty) {
        data['role'] = roleString;
      }
    }

    await getFirebaseFirestore()
        .collection(config.usersCollectionName)
        .doc(user.id)
        .set(data, SetOptions(merge: true));
  }

  /// Updates [types.User] fields in Firebase to reflect name and avatar
  /// changes or other relevant metadata without overwriting the entire
  /// document.
  Future<void> updateUserInFirestore({
    required final BuildContext? context,
    required final types.User user,
  }) async {
    try {
      final Map<String, dynamic> dataToUpdate = <String, dynamic>{};

      if (user.firstName != null) {
        dataToUpdate['firstName'] = user.firstName;
      }
      if (user.imageUrl != null) {
        dataToUpdate['imageUrl'] = user.imageUrl;
      }
      if (user.lastName != null) {
        dataToUpdate['lastName'] = user.lastName;
      }
      if (user.metadata != null) {
        dataToUpdate['metadata'] = user.metadata;
      }
      if (user.role != null) {
        dataToUpdate['role'] = user.role!.toShortString();
      }

      // Always update the timestamp if you're making any update
      if (dataToUpdate.isNotEmpty) {
        dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();

        await getFirebaseFirestore()
            .collection(config.usersCollectionName)
            .doc(user.id)
            .update(dataToUpdate);
      }
    } catch (e) {
      if (context != null && context.mounted) {
        toast(context, message: 'Something went wrong!');
      }
    }
  }

  /// Removes message document.
  Future<void> deleteMessage(
    final String roomId,
    final String messageId,
  ) async {
    await getFirebaseFirestore()
        .collection('${config.roomsCollectionName}/$roomId/messages')
        .doc(messageId)
        .delete();
  }

  /// Removes room document.
  Future<void> deleteRoom(final String roomId) async {
    await getFirebaseFirestore()
        .collection(config.roomsCollectionName)
        .doc(roomId)
        .delete();
  }

  /// Removes [types.User] from `users` collection in Firebase.
  Future<void> deleteUserFromFirestore(final String userId) async {
    await getFirebaseFirestore()
        .collection(config.usersCollectionName)
        .doc(userId)
        .delete();
  }

  /// Returns a stream of messages from Firebase for a given room.
  Stream<List<types.Message>> messages(
    final types.Room room, {
    final List<Object?>? endAt,
    final List<Object?>? endBefore,
    final int? limit,
    final List<Object?>? startAfter,
    final List<Object?>? startAt,
  }) {
    Query<Map<String, dynamic>> query = getFirebaseFirestore()
        .collection('${config.roomsCollectionName}/${room.id}/messages')
        .orderBy('createdAt', descending: true);

    if (endAt != null) {
      query = query.endAt(endAt);
    }

    if (endBefore != null) {
      query = query.endBefore(endBefore);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfter(startAfter);
    }

    if (startAt != null) {
      query = query.startAt(startAt);
    }

    return query.snapshots().map(
          (final QuerySnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.docs.fold<List<types.Message>>(
            <types.Message>[],
            (
              final List<types.Message> previousValue,
              final QueryDocumentSnapshot<Map<String, dynamic>> doc,
            ) {
              final Map<String, dynamic> data = doc.data();
              final types.User author = room.users.firstWhere(
                (final types.User u) => u.id == data['authorId'],
                orElse: () => types.User(id: data['authorId'] as String),
              );

              data['author'] = author.toJson();
              data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
              data['id'] = doc.id;
              data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

              return <types.Message>[
                ...previousValue,
                types.Message.fromJson(data),
              ];
            },
          ),
        );
  }

  /// Returns a stream of changes in a room from Firebase.
  Stream<types.Room> room(final String roomId) {
    final User? fu = firebaseUser;

    if (fu == null) {
      return const Stream<types.Room>.empty();
    }

    return getFirebaseFirestore()
        .collection(config.roomsCollectionName)
        .doc(roomId)
        .snapshots()
        .asyncMap(
          (final DocumentSnapshot<Map<String, dynamic>> doc) async =>
              processRoomDocument(
            doc,
            fu,
            getFirebaseFirestore(),
            config.usersCollectionName,
          ),
        );
  }

  /// Returns a stream of rooms from Firebase. Only rooms where current
  /// logged in user exist are returned. [orderByUpdatedAt] is used in case
  /// you want to have last modified rooms on top, there are a couple
  /// of things you will need to do though:
  /// 1) Make sure `updatedAt` exists on all rooms
  /// 2) Write a Cloud Function which will update `updatedAt` of the room
  /// when the room changes or new messages come in
  /// 3) Create an Index (Firestore Database -> Indexes tab) where collection ID
  /// is `rooms`, field indexed are `userIds` (type Arrays) and `updatedAt`
  /// (type Descending), query scope is `Collection`.
  Stream<List<types.Room>> rooms({final bool orderByUpdatedAt = false}) {
    final User? fu = firebaseUser;

    if (fu == null) {
      return const Stream<List<types.Room>>.empty();
    }

    final Query<Map<String, dynamic>> collection = orderByUpdatedAt
        ? getFirebaseFirestore()
            .collection(config.roomsCollectionName)
            .where('userIds', arrayContains: fu.uid)
            .orderBy('updatedAt', descending: true)
        : getFirebaseFirestore()
            .collection(config.roomsCollectionName)
            .where('userIds', arrayContains: fu.uid);

    return collection.snapshots().asyncMap(
          (final QuerySnapshot<Map<String, dynamic>> query) async =>
              processRoomsQuery(
            fu,
            getFirebaseFirestore(),
            query,
            config.usersCollectionName,
          ),
        );
  }

  /// Sends a message to the Firestore. Accepts any partial message and a
  /// room ID. If arbitraty data is provided in the [partialMessage]
  /// does nothing.
  void sendMessage(final dynamic partialMessage, final String roomId) async {
    if (firebaseUser == null) {
      return;
    }

    types.Message? message;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: types.User(id: firebaseUser!.uid),
        id: '',
        partialText: partialMessage,
      );
    }

    if (message != null) {
      final Map<String, dynamic> messageMap = message.toJson()
        ..removeWhere(
          (final String key, final dynamic value) =>
              key == 'author' || key == 'id',
        );
      messageMap['authorId'] = firebaseUser!.uid;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['updatedAt'] = FieldValue.serverTimestamp();

      await getFirebaseFirestore()
          .collection('${config.roomsCollectionName}/$roomId/messages')
          .add(messageMap);

      await getFirebaseFirestore()
          .collection(config.roomsCollectionName)
          .doc(roomId)
          .update(<Object, Object?>{'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  /// Updates a message in the Firestore. Accepts any message and a
  /// room ID. Message will probably be taken from the [messages] stream.
  void updateMessage(final types.Message message, final String roomId) async {
    if (firebaseUser == null) {
      return;
    }
    if (message.author.id != firebaseUser!.uid) {
      return;
    }

    final Map<String, dynamic> messageMap = message.toJson()
      ..removeWhere(
        (final String key, final dynamic value) =>
            key == 'author' || key == 'createdAt' || key == 'id',
      );
    messageMap['authorId'] = message.author.id;
    messageMap['updatedAt'] = FieldValue.serverTimestamp();

    await getFirebaseFirestore()
        .collection('${config.roomsCollectionName}/$roomId/messages')
        .doc(message.id)
        .update(messageMap);
  }

  /// Updates a room in the Firestore. Accepts any room.
  /// Room will probably be taken from the [rooms] stream.
  void updateRoom(final types.Room room) async {
    if (firebaseUser == null) {
      return;
    }

    final Map<String, dynamic> roomMap = room.toJson()
      ..removeWhere(
        (final String key, final dynamic value) =>
            key == 'createdAt' ||
            key == 'id' ||
            key == 'lastMessages' ||
            key == 'users',
      );

    if (room.type == types.RoomType.direct) {
      roomMap['imageUrl'] = null;
      roomMap['name'] = null;
    }

    roomMap['lastMessages'] = room.lastMessages?.map((final types.Message m) {
      final Map<String, dynamic> messageMap = m.toJson()
        ..removeWhere(
          (final String key, final dynamic value) =>
              key == 'author' ||
              key == 'createdAt' ||
              key == 'id' ||
              key == 'updatedAt',
        );

      messageMap['authorId'] = m.author.id;

      return messageMap;
    }).toList();
    roomMap['updatedAt'] = FieldValue.serverTimestamp();
    roomMap['userIds'] = room.users.map((final types.User u) => u.id).toList();

    await getFirebaseFirestore()
        .collection(config.roomsCollectionName)
        .doc(room.id)
        .update(roomMap);
  }

  /// Returns a stream of all users from Firebase.
  Stream<List<types.User>> users() {
    if (firebaseUser == null) {
      return const Stream<List<types.User>>.empty();
    }
    return getFirebaseFirestore()
        .collection(config.usersCollectionName)
        .snapshots()
        .map(
          (final QuerySnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.docs.fold<List<types.User>>(
            <types.User>[],
            (
              final List<types.User> previousValue,
              final QueryDocumentSnapshot<Map<String, dynamic>> doc,
            ) {
              if (firebaseUser!.uid == doc.id) {
                return previousValue;
              }

              final Map<String, dynamic> data = doc.data();

              data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
              data['id'] = doc.id;
              data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
              data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

              return <types.User>[...previousValue, types.User.fromJson(data)];
            },
          ),
        );
  }

  /// Returns a stream of the current user from Firebase.
  Stream<types.User?> currentUser() {
    if (firebaseUser == null) {
      return const Stream<types.User?>.empty();
    }
    return getFirebaseFirestore()
        .collection(config.usersCollectionName)
        .doc(firebaseUser!.uid)
        .snapshots()
        .map(
      (final DocumentSnapshot<Map<String, dynamic>> doc) {
        if (!doc.exists) {
          return null;
        }

        final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

        return types.User(
          id: doc.id,
          firstName: data['firstName'] as String?,
          lastName: data['lastName'] as String?,
          imageUrl: data['imageUrl'] as String?,
          createdAt: data['createdAt']!.millisecondsSinceEpoch as int?,
          lastSeen: data['lastSeen']!.millisecondsSinceEpoch as int?,
          updatedAt: data['updatedAt']!.millisecondsSinceEpoch as int?,
          metadata: data['metadata'] as Map<String, dynamic>?,
        );
      },
    );
  }

  /// Returns the current user from Firebase as a Future.
  Future<types.User?> user() async {
    if (firebaseUser == null) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await getFirebaseFirestore()
            .collection(config.usersCollectionName)
            .doc(firebaseUser!.uid)
            .get();

    if (!doc.exists) {
      return null;
    }

    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    return types.User(
      id: doc.id,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      imageUrl: data['imageUrl'] as String?,
      createdAt: data['createdAt']?.millisecondsSinceEpoch as int?,
      lastSeen: data['lastSeen']?.millisecondsSinceEpoch as int?,
      updatedAt: data['updatedAt']?.millisecondsSinceEpoch as int?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
}
