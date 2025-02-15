// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/messages/partial_text.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/preview_data.dart'
    show PreviewData;
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart' show User;

part 'text_message.g.dart';

/// A class that represents a text message.
@JsonSerializable()
@immutable
abstract class TextMessage extends Message {
  const factory TextMessage({
    required final String id,
    required final String text,
    required final User author,
    final int? createdAt,
    final Map<String, dynamic>? metadata,
    final PreviewData? previewData,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final MessageType? type,
    final int? updatedAt,
  }) = _TextMessage;

  /// Creates a text message.
  const TextMessage._({
    required super.id,
    required this.text,
    required super.author,
    super.createdAt,
    super.metadata,
    this.previewData,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    final MessageType? type,
    super.updatedAt,
  }) : super(type: type ?? MessageType.text);

  /// Creates a text message from a map (decoded JSON).
  factory TextMessage.fromJson(final Map<String, dynamic> json) =>
      _$TextMessageFromJson(json);

  /// Creates a full text message from a partial one.
  factory TextMessage.fromPartial({
    required final User author,
    required final String id,
    required final PartialText partialText,
    final int? createdAt,
    final String? remoteId,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final int? updatedAt,
  }) =>
      _TextMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        metadata: partialText.metadata,
        previewData: partialText.previewData,
        remoteId: remoteId,
        repliedMessage: partialText.repliedMessage,
        roomId: roomId,
        showStatus: showStatus,
        status: status,
        text: partialText.text,
        type: MessageType.text,
        updatedAt: updatedAt,
      );

  /// See [PreviewData].
  final PreviewData? previewData;

  /// User's message.
  final String text;

  /// Equatable props.
  @override
  List<Object?> get props => <Object?>[
        author,
        createdAt,
        id,
        metadata,
        previewData,
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
    final PreviewData? previewData,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final String? text,
    final int? updatedAt,
  });

  /// Converts a text message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$TextMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _TextMessage extends TextMessage {
  const _TextMessage({
    required super.id,
    required super.text,
    required super.author,
    super.createdAt,
    super.metadata,
    super.previewData,
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
    final dynamic previewData = _Unset,
    final dynamic remoteId = _Unset,
    final dynamic repliedMessage = _Unset,
    final dynamic roomId = _Unset,
    final dynamic showStatus = _Unset,
    final dynamic status = _Unset,
    final String? text,
    final dynamic updatedAt = _Unset,
  }) =>
      _TextMessage(
        author: author ?? this.author,
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        id: id ?? this.id,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        previewData: previewData == _Unset
            ? this.previewData
            : previewData as PreviewData?,
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
