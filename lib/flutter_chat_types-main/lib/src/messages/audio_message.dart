// @dart=3.0

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/messages/partial_audio.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/user.dart' show User;

part 'audio_message.g.dart';

/// A class that represents audio message.
@JsonSerializable()
@immutable
abstract class AudioMessage extends Message {
  const factory AudioMessage({
    required final User author,
    required final Duration duration,
    required final String id,
    required final String name,
    required final num size,
    required final String uri,
    final int? createdAt,
    final Map<String, dynamic>? metadata,
    final String? mimeType,
    final String? remoteId,
    final Message? repliedMessage,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final MessageType? type,
    final int? updatedAt,
    final List<double>? waveForm,
  }) = _AudioMessage;

  /// Creates an audio message.
  const AudioMessage._({
    required super.author,
    required this.duration,
    required super.id,
    required this.name,
    required this.size,
    required this.uri,
    super.createdAt,
    super.metadata,
    this.mimeType,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    final MessageType? type,
    super.updatedAt,
    this.waveForm,
  }) : super(type: type ?? MessageType.audio);

  /// Creates an audio message from a map (decoded JSON).
  factory AudioMessage.fromJson(final Map<String, dynamic> json) =>
      _$AudioMessageFromJson(json);

  /// Creates a full audio message from a partial one.
  factory AudioMessage.fromPartial({
    required final User author,
    required final String id,
    required final PartialAudio partialAudio,
    final int? createdAt,
    final String? remoteId,
    final String? roomId,
    final bool? showStatus,
    final Status? status,
    final int? updatedAt,
  }) =>
      _AudioMessage(
        author: author,
        createdAt: createdAt,
        duration: partialAudio.duration,
        id: id,
        metadata: partialAudio.metadata,
        mimeType: partialAudio.mimeType,
        name: partialAudio.name,
        remoteId: remoteId,
        repliedMessage: partialAudio.repliedMessage,
        roomId: roomId,
        showStatus: showStatus,
        size: partialAudio.size,
        status: status,
        type: MessageType.audio,
        updatedAt: updatedAt,
        uri: partialAudio.uri,
        waveForm: partialAudio.waveForm,
      );

  /// The length of the audio.
  final Duration duration;

  /// Media type of the audio file.
  final String? mimeType;

  /// The name of the audio.
  final String name;

  /// Size of the audio in bytes.
  final num size;

  /// The audio file source (either a remote URL or a local resource).
  final String uri;

  /// Wave form represented as a list of decibel levels.
  final List<double>? waveForm;

  /// Equatable props.
  @override
  List<Object?> get props => <Object?>[
        author,
        createdAt,
        duration,
        id,
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
        waveForm,
      ];

  @override
  Message copyWith({
    final User? author,
    final int? createdAt,
    final Duration? duration,
    final String? id,
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
    final List<double>? waveForm,
  });

  /// Converts an audio message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$AudioMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _AudioMessage extends AudioMessage {
  const _AudioMessage({
    required super.author,
    required super.duration,
    required super.id,
    required super.name,
    required super.size,
    required super.uri,
    super.createdAt,
    super.metadata,
    super.mimeType,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    super.status,
    super.type,
    super.updatedAt,
    super.waveForm,
  }) : super._();

  @override
  Message copyWith({
    final User? author,
    final dynamic createdAt = _Unset,
    final Duration? duration,
    final String? id,
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
    final dynamic waveForm = _Unset,
  }) =>
      _AudioMessage(
        author: author ?? this.author,
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        duration: duration ?? this.duration,
        id: id ?? this.id,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        mimeType: mimeType == _Unset ? this.mimeType : mimeType as String?,
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
        waveForm:
            waveForm == _Unset ? this.waveForm : waveForm as List<double>?,
      );
}

class _Unset {}
