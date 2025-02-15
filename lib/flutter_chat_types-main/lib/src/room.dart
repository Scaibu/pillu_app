// @dart = 3.0
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart';

part 'room.g.dart';

/// All possible room types.
enum RoomType { channel, direct, group }

/// A class that represents a room where 2 or more participants can chat.
@JsonSerializable()
@immutable
abstract class Room extends Equatable {
  const factory Room({
    required final String id,
    required final RoomType? type,
    required final List<User> users,
    final int? createdAt,
    final String? imageUrl,
    final List<Message>? lastMessages,
    final Map<String, dynamic>? metadata,
    final String? name,
    final int? updatedAt,
  }) = _Room;

  /// Creates a [Room].
  const Room._({
    required this.id,
    required this.type,
    required this.users,
    this.createdAt,
    this.imageUrl,
    this.lastMessages,
    this.metadata,
    this.name,
    this.updatedAt,
  });

  /// Creates a room from a map (decoded JSON).
  factory Room.fromJson(final Map<String, dynamic> json) =>
      _$RoomFromJson(json);

  /// Created room timestamp, in ms.
  final int? createdAt;

  /// Room's unique ID.
  final String id;

  /// Room's image. In case of the [RoomType.direct] - avatar of the second
  /// person,
  /// otherwise a custom image [RoomType.group].
  final String? imageUrl;

  /// List of last messages this room has received.
  final List<Message>? lastMessages;

  /// Additional custom metadata or attributes related to the room.
  final Map<String, dynamic>? metadata;

  /// Room's name. In case of the [RoomType.direct] - name of the second person,
  /// otherwise a custom name [RoomType.group].
  final String? name;

  /// [RoomType].
  final RoomType? type;

  /// Updated room timestamp, in ms.
  final int? updatedAt;

  /// List of users which are in the room.
  final List<User> users;

  /// Equatable props.
  @override
  List<Object?> get props => <Object?>[
        createdAt,
        id,
        imageUrl,
        lastMessages,
        metadata,
        name,
        type,
        updatedAt,
        users,
      ];

  /// Creates a copy of the room with updated data.
  /// [imageUrl], [name] and [updatedAt] with null values will nullify existing
  /// values,
  /// [metadata] with null value will nullify existing metadata, otherwise
  /// both metadatas will be merged into one Map, where keys from a passed
  /// metadata will overwrite keys from the previous one.
  /// [type] and [users] with null values will be overwritten by previous
  /// values.
  Room copyWith({
    final int? createdAt,
    final String? id,
    final String? imageUrl,
    final List<Message>? lastMessages,
    final Map<String, dynamic>? metadata,
    final String? name,
    final RoomType? type,
    final int? updatedAt,
    final List<User>? users,
  });

  /// Converts room to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => _$RoomToJson(this);
}

/// A utility class to enable better copyWith.
class _Room extends Room {
  const _Room({
    required super.id,
    required super.type,
    required super.users,
    super.createdAt,
    super.imageUrl,
    super.lastMessages,
    super.metadata,
    super.name,
    super.updatedAt,
  }) : super._();

  @override
  Room copyWith({
    final dynamic createdAt = _Unset,
    final String? id,
    final dynamic imageUrl = _Unset,
    final dynamic lastMessages = _Unset,
    final dynamic metadata = _Unset,
    final dynamic name = _Unset,
    final dynamic type = _Unset,
    final dynamic updatedAt = _Unset,
    final List<User>? users,
  }) =>
      _Room(
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        id: id ?? this.id,
        imageUrl: imageUrl == _Unset ? this.imageUrl : imageUrl as String?,
        lastMessages: lastMessages == _Unset
            ? this.lastMessages
            : lastMessages as List<Message>?,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        name: name == _Unset ? this.name : name as String?,
        type: type == _Unset ? this.type : type as RoomType?,
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
        users: users ?? this.users,
      );
}

class _Unset {}
