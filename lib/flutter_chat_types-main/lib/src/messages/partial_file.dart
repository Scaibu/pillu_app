// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/messages/file_message.dart';

part 'partial_file.g.dart';

/// A class that represents a partial file message.
@JsonSerializable()
@immutable
class PartialFile {
  /// Creates a partial file message with all variables a file can have.
  /// Use [FileMessage] to create a full message.
  /// You can use [FileMessage.fromPartial] constructor to create a full
  /// message from a partial one.
  const PartialFile({
    required this.name,
    required this.size,
    required this.uri,
    this.metadata,
    this.mimeType,
    this.repliedMessage,
  });

  /// Creates a partial file message from a map (decoded JSON).
  factory PartialFile.fromJson(final Map<String, dynamic> json) =>
      _$PartialFileFromJson(json);

  /// Additional custom metadata or attributes related to the message.
  final Map<String, dynamic>? metadata;

  /// Media type of the file.
  final String? mimeType;

  /// The name of the file.
  final String name;

  /// Message that is being replied to with the current message.
  final Message? repliedMessage;

  /// Size of the file in bytes.
  final num size;

  /// The file source (either a remote URL or a local resource).
  final String uri;

  /// Converts a partial file message to the map representation, encodable to
  /// JSON.
  Map<String, dynamic> toJson() => _$PartialFileToJson(this);
}
