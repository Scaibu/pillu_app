// File: partial_audio.dart
// Specify the Dart language version to ensure compatibility with all parts.

// @dart = 3.0
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:pillu_app/flutter_chat_types-main/lib/src/message.dart';

part 'partial_audio.g.dart';

/// A class that represents a partial audio message.
@JsonSerializable()
@immutable
class PartialAudio {
  const PartialAudio({
    required this.name,
    required this.size,
    required this.uri,
    required this.duration,
    this.metadata,
    this.mimeType,
    this.repliedMessage,
    this.waveForm,
  });

  /// Creates a partial audio message from a map (decoded JSON).
  factory PartialAudio.fromJson(final Map<String, dynamic> json) =>
      _$PartialAudioFromJson(json);

  /// The length of the audio.
  final Duration duration;

  /// Additional custom metadata or attributes related to the message.
  final Map<String, dynamic>? metadata;

  /// Media type of the audio file.
  final String? mimeType;

  /// The name of the audio.
  final String name;

  /// Message that is being replied to with the current message.
  final Message? repliedMessage;

  /// Size of the audio in bytes.
  final int size; // Changed to int for better type consistency

  /// The audio file source (either a remote URL or a local resource).
  final String uri;

  /// Wave form represented as a list of decibel levels.
  final List<double>? waveForm;

  /// Converts a partial audio message to the map representation, encodable to
  /// JSON.
  Map<String, dynamic> toJson() => _$PartialAudioToJson(this);
}
