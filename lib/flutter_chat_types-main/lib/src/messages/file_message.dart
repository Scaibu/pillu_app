// @dart=3.0

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../message.dart';
import '../user.dart' show User;
import 'partial_file.dart';

part 'file_message.g.dart';

/// A class that represents a file message.
@JsonSerializable()
@immutable
abstract class FileMessage extends Message {
  const factory FileMessage({
    required final String id,
    required final String name,
    required final num size,
    required final String uri,
    required final User author,
    final int? createdAt,
    final bool? isLoading,
    final Map<String, dynamic>? metadata,
    final String? mimeType,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final MessageType? type,
    final int? updatedAt,
  }) = _FileMessage;

  /// Creates a file message.
  const FileMessage._({
    required super.id,
    required this.name,
    required this.size,
    required this.uri,
    required super.author,
    super.createdAt,
    this.isLoading,
    super.metadata,
    this.mimeType,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    final MessageType? type,
    super.updatedAt,
  }) : super(type: type ?? MessageType.file);

  /// Creates a file message from a map (decoded JSON).
  factory FileMessage.fromJson(final Map<String, dynamic> json) =>
      _$FileMessageFromJson(json);

  /// Creates a full file message from a partial one.
  factory FileMessage.fromPartial({
    required final User author,
    required final String id,
    required final PartialFile partialFile,
    final int? createdAt,
    final bool? isLoading,
    final String? remoteId,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final int? updatedAt,
  }) =>
      _FileMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        isLoading: isLoading,
        metadata: partialFile.metadata,
        mimeType: partialFile.mimeType,
        name: partialFile.name,
        remoteId: remoteId,
        repliedMessage: partialFile.repliedMessage,
        roomId: roomId,
        showStatus: showStatus,
        size: partialFile.size,
        status: status,
        type: MessageType.file,
        updatedAt: updatedAt,
        uri: partialFile.uri,
      );

  /// Specify whether the message content is currently being loaded.
  final bool? isLoading;

  /// Media type.
  final String? mimeType;

  /// The name of the file.
  final String name;

  /// Size of the file in bytes.
  final num size;

  /// The file source (either a remote URL or a local resource).
  final String uri;

  /// Equatable props.
  @override
  List<Object?> get props => <Object?>[
        author,
        createdAt,
        id,
        isLoading,
        metadata,
        mimeType,
        name,
        remoteId,
        repliedMessage,
        roomId,
        showStatus,
        size,
        status,
        updatedAt,
        uri,
      ];

  @override
  Message copyWith({
    final User? author,
    final int? createdAt,
    final String? id,
    final bool? isLoading,
    final Map<String, dynamic>? metadata,
    final String? mimeType,
    final String? name,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final num? size,
    final Status? status,
    final int? updatedAt,
    final String? uri,
  });

  /// Converts a file message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$FileMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _FileMessage extends FileMessage {
  const _FileMessage({
    required super.id,
    required super.name,
    required super.size,
    required super.uri,
    required super.author,
    super.createdAt,
    super.isLoading,
    super.metadata,
    super.mimeType,
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
    final dynamic isLoading = _Unset,
    final dynamic metadata = _Unset,
    final dynamic mimeType = _Unset,
    final String? name,
    final dynamic remoteId = _Unset,
    final dynamic repliedMessage = _Unset,
    final dynamic roomId = _Unset,
    final dynamic showStatus = _Unset,
    final num? size,
    final dynamic status = _Unset,
    final dynamic updatedAt = _Unset,
    final String? uri,
  }) =>
      _FileMessage(
        author: author ?? this.author,
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        id: id ?? this.id,
        isLoading: isLoading == _Unset ? this.isLoading : isLoading as bool?,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        mimeType: mimeType == _Unset ? this.mimeType : mimeType as String?,
        name: name ?? this.name,
        remoteId: remoteId == _Unset ? this.remoteId : remoteId as String?,
        repliedMessage: repliedMessage! == _Unset
            ? this.repliedMessage
            : repliedMessage as Message?,
        roomId: roomId == _Unset ? this.roomId : roomId as String?,
        showStatus:
            showStatus == _Unset ? this.showStatus : showStatus as bool?,
        size: size ?? this.size,
        status: status == _Unset ? this.status : status as Status?,
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
        uri: uri ?? this.uri,
      );
}

class _Unset {}
