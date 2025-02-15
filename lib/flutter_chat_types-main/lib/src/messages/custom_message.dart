// @dart=3.0

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/messages/partial_custom.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart' show User;

part 'custom_message.g.dart';

/// A class that represents custom message. Use [metadata] to store anything
/// you want.
@JsonSerializable()
@immutable
abstract class CustomMessage extends Message {
  const factory CustomMessage({
    required final User author,
    required final String id,
    final int? createdAt,
    final Map<String, dynamic>? metadata,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final MessageType? type,
    final int? updatedAt,
  }) = _CustomMessage;

  /// Creates a custom message.
  const CustomMessage._({
    required super.author,
    required super.id,
    super.createdAt,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    final MessageType? type,
    super.updatedAt,
  }) : super(type: type ?? MessageType.custom);

  /// Creates a custom message from a map (decoded JSON).
  factory CustomMessage.fromJson(final Map<String, dynamic> json) =>
      _$CustomMessageFromJson(json);

  /// Creates a full custom message from a partial one.
  factory CustomMessage.fromPartial({
    required final String id,
    required final PartialCustom partialCustom,
    required final User author,
    final int? createdAt,
    final String? remoteId,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final int? updatedAt,
  }) =>
      _CustomMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        metadata: partialCustom.metadata,
        remoteId: remoteId,
        repliedMessage: partialCustom.repliedMessage,
        roomId: roomId,
        showStatus: showStatus,
        status: status,
        type: MessageType.custom,
        updatedAt: updatedAt,
      );

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
    final int? updatedAt,
  });

  /// Converts a custom message to the map representation,
  /// encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$CustomMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _CustomMessage extends CustomMessage {
  const _CustomMessage({
    required super.author,
    required super.id,
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
    final dynamic updatedAt = _Unset,
  }) =>
      _CustomMessage(
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
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
      );
}

class _Unset {}
