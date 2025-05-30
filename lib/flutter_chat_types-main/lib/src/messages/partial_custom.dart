// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/messages/custom_message.dart';

part 'partial_custom.g.dart';

/// A class that represents a partial custom message.
@JsonSerializable()
@immutable
class PartialCustom {
  /// Creates a partial custom message with metadata variable.
  /// Use [CustomMessage] to create a full message.
  /// You can use [CustomMessage.fromPartial] constructor to create a full
  /// message from a partial one.
  const PartialCustom({
    this.metadata,
    this.repliedMessage,
  });

  /// Creates a partial custom message from a map (decoded JSON).
  factory PartialCustom.fromJson(final Map<String, dynamic> json) =>
      _$PartialCustomFromJson(json);

  /// Additional custom metadata or attributes related to the message.
  final Map<String, dynamic>? metadata;

  /// Message that is being replied to with the current message.
  final Message? repliedMessage;

  /// Converts a partial custom message to the map representation, encodable to
  /// JSON.
  Map<String, dynamic> toJson() => _$PartialCustomToJson(this);
}
