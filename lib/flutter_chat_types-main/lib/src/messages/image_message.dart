// @dart=3.0

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/messages/partial_image.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart' show User;

part 'image_message.g.dart';

/// A class that represents an image message.
@JsonSerializable()
@immutable
abstract class ImageMessage extends Message {
  const factory ImageMessage({
    required final String id,
    required final String name,
    required final num size,
    required final String uri,
    required final User author,
    final int? createdAt,
    final double? height,
    final Map<String, dynamic>? metadata,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final MessageType? type,
    final int? updatedAt,
    final double? width,
  }) = _ImageMessage;

  /// Creates an image message.
  const ImageMessage._({
    required super.author,
    required super.id,
    required this.name,
    required this.size,
    required this.uri,
    super.createdAt,
    this.height,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    final MessageType? type,
    super.updatedAt,
    this.width,
  }) : super(type: type ?? MessageType.image);

  /// Creates an image message from a map (decoded JSON).
  factory ImageMessage.fromJson(final Map<String, dynamic> json) =>
      _$ImageMessageFromJson(json);

  /// Creates a full image message from a partial one.
  factory ImageMessage.fromPartial({
    required final User author,
    required final String id,
    required final PartialImage partialImage,
    final int? createdAt,
    final String? remoteId,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final int? updatedAt,
  }) =>
      _ImageMessage(
        author: author,
        createdAt: createdAt,
        height: partialImage.height,
        id: id,
        metadata: partialImage.metadata,
        name: partialImage.name,
        remoteId: remoteId,
        repliedMessage: partialImage.repliedMessage,
        roomId: roomId,
        showStatus: showStatus,
        size: partialImage.size,
        status: status,
        type: MessageType.image,
        updatedAt: updatedAt,
        uri: partialImage.uri,
        width: partialImage.width,
      );

  /// Image height in pixels.
  final double? height;

  /// The name of the image.
  final String name;

  /// Size of the image in bytes.
  final num size;

  /// The image source (either a remote URL or a local resource).
  final String uri;

  /// Image width in pixels.
  final double? width;

  /// Equatable props.
  @override
  List<Object?> get props => <Object?>[
        author,
        createdAt,
        height,
        id,
        metadata,
        name,
        remoteId,
        repliedMessage,
        roomId,
        showStatus,
        size,
        status,
        updatedAt,
        uri,
        width,
      ];

  @override
  Message copyWith({
    final User? author,
    final int? createdAt,
    final double? height,
    final String? id,
    final Map<String, dynamic>? metadata,
    final String? name,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final num? size,
    final Status? status,
    final int? updatedAt,
    final String? uri,
    final double? width,
  });

  /// Converts an image message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$ImageMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _ImageMessage extends ImageMessage {
  const _ImageMessage({
    required super.id,
    required super.name,
    required super.size,
    required super.uri,
    required super.author,
    super.createdAt,
    super.height,
    super.metadata,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    super.type,
    super.updatedAt,
    super.width,
  }) : super._();

  @override
  Message copyWith({
    final User? author,
    final dynamic createdAt = _Unset,
    final dynamic height = _Unset,
    final String? id,
    final dynamic metadata = _Unset,
    final String? name,
    final dynamic remoteId = _Unset,
    final dynamic repliedMessage = _Unset,
    final dynamic roomId = _Unset,
    final dynamic showStatus = _Unset,
    final num? size,
    final dynamic status = _Unset,
    final dynamic updatedAt = _Unset,
    final String? uri,
    final dynamic width = _Unset,
  }) =>
      _ImageMessage(
        author: author ?? this.author,
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        height: height == _Unset ? this.height : height as double?,
        id: id ?? this.id,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        name: name ?? this.name,
        remoteId: remoteId == _Unset ? this.remoteId : remoteId as String?,
        repliedMessage: repliedMessage == _Unset
            ? this.repliedMessage
            : repliedMessage as Message?,
        roomId: roomId == _Unset ? this.roomId : roomId as String?,
        showStatus:
            showStatus == _Unset ? this.showStatus : showStatus as bool?,
        size: size ?? this.size,
        status: status == _Unset ? this.status : status as Status?,
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
        uri: uri ?? this.uri,
        width: width == _Unset ? this.width : width as double?,
      );
}

class _Unset {}
