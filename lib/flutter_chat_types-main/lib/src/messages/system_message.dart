// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart' show User;

part 'system_message.g.dart';

/// A class that represents a system message (anything around chat management).
/// Use [metadata] to store anything you want.
@JsonSerializable()
@immutable
abstract class SystemMessage extends Message {
  // Default value applied here

  const factory SystemMessage({
    required final String id,
    required final String text,
    final User? author,
    final int? createdAt,
    final Map<String, dynamic>? metadata,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final MessageType? type,
    final int? updatedAt,
  }) = _SystemMessage;

  /// Creates a custom message.
  const SystemMessage._({
    required super.id,
    required this.text,
    final User? author, // Change this to be nullable
    super.createdAt,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    final MessageType? type,
    super.updatedAt,
  }) : super(
          author: author ?? const User(id: 'system'),
          type: type ?? MessageType.system,
        );

  /// Creates a custom message from a map (decoded JSON).
  factory SystemMessage.fromJson(final Map<String, dynamic> json) =>
      _$SystemMessageFromJson(json);

  /// System message content (could be text or translation key).
  final String text;

  /// Equatable props.
  @override
  List<Object?> get props => <Object?>[
        author,
        createdAt,
        id,
        metadata,
        remoteId,
        repliedMessage,
        roomId,
        showStatus,
        status,
        text,
        updatedAt,
      ];

  @override
  Message copyWith({
    final User? author,
    final int? createdAt,
    final String? id,
    final Map<String, dynamic>? metadata,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final String? text,
    final int? updatedAt,
  });

  /// Converts a custom message to the map representation,
  /// encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$SystemMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _SystemMessage extends SystemMessage {
  const _SystemMessage({
    required super.id,
    required super.text,
    super.author, // Change this to be nullable

    super.createdAt,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    super.type,
    super.updatedAt,
  }) : super._();

  @override
  Message copyWith({
    final User? author,
    final dynamic createdAt = _Unset,
    final String? id,
    final dynamic metadata = _Unset,
    final dynamic remoteId = _Unset,
    final dynamic repliedMessage = _Unset,
    final dynamic roomId = _Unset,
    final dynamic showStatus = _Unset,
    final dynamic status = _Unset,
    final String? text,
    final dynamic updatedAt = _Unset,
  }) =>
      _SystemMessage(
        author: author ?? this.author,
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        id: id ?? this.id,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        remoteId: remoteId == _Unset ? this.remoteId : remoteId as String?,
        repliedMessage: repliedMessage == _Unset
            ? this.repliedMessage
            : repliedMessage as Message?,
        roomId: roomId == _Unset ? this.roomId : roomId as String?,
        showStatus:
            showStatus == _Unset ? this.showStatus : showStatus as bool?,
        status: status == _Unset ? this.status : status as Status?,
        text: text ?? this.text,
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
      );
}

class _Unset {}
