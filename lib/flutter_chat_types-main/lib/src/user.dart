// @dart = 3.0
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'user.g.dart';

/// All possible roles a user can have.
enum Role { admin, agent, moderator, user }

/// A class that represents a user.
@JsonSerializable()
@immutable
abstract class User extends Equatable {
  const factory User({
    required final String id,
    final int? createdAt,
    final String? firstName,
    final String? imageUrl,
    final String? lastName,
    final int? lastSeen,
    final Map<String, dynamic>? metadata,
    final Role? role,
    final int? updatedAt,
  }) = _User;

  /// Creates a user.
  const User._({
    required this.id,
    this.createdAt,
    this.firstName,
    this.imageUrl,
    this.lastName,
    this.lastSeen,
    this.metadata,
    this.role,
    this.updatedAt,
  });

  /// Creates a user from a map (decoded JSON).
  factory User.fromJson(final Map<String, dynamic> json) =>
      _$UserFromJson(json);

  /// Created user timestamp, in ms.
  final int? createdAt;

  /// First name of the user.
  final String? firstName;

  /// Unique ID of the user.
  final String id;

  /// Remote image URL representing the user's avatar.
  final String? imageUrl;

  /// Last name of the user.
  final String? lastName;

  /// Timestamp when the user was last visible, in ms.
  final int? lastSeen;

  /// Additional custom metadata or attributes related to the user.
  final Map<String, dynamic>? metadata;

  /// User [Role].
  final Role? role;

  /// Updated user timestamp, in ms.
  final int? updatedAt;

  /// Equatable props.
  @override
  List<Object?> get props => <Object?>[
        createdAt,
        firstName,
        id,
        imageUrl,
        lastName,
        lastSeen,
        metadata,
        role,
        updatedAt,
      ];

  User copyWith({
    final int? createdAt,
    final String? firstName,
    final String? id,
    final String? imageUrl,
    final String? lastName,
    final int? lastSeen,
    final Map<String, dynamic>? metadata,
    final Role? role,
    final int? updatedAt,
  });

  /// Converts user to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

/// A utility class to enable better copyWith.
class _User extends User {
  const _User({
    required super.id,
    super.createdAt,
    super.firstName,
    super.imageUrl,
    super.lastName,
    super.lastSeen,
    super.metadata,
    super.role,
    super.updatedAt,
  }) : super._();

  @override
  User copyWith({
    final dynamic createdAt = _Unset,
    final dynamic firstName = _Unset,
    final String? id,
    final dynamic imageUrl = _Unset,
    final dynamic lastName = _Unset,
    final dynamic lastSeen = _Unset,
    final dynamic metadata = _Unset,
    final dynamic role = _Unset,
    final dynamic updatedAt = _Unset,
  }) =>
      _User(
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        firstName: firstName == _Unset ? this.firstName : firstName as String?,
        id: id ?? this.id,
        imageUrl: imageUrl == _Unset ? this.imageUrl : imageUrl as String?,
        lastName: lastName == _Unset ? this.lastName : lastName as String?,
        lastSeen: lastSeen == _Unset ? this.lastSeen : lastSeen as int?,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        role: role == _Unset ? this.role : role as Role?,
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
      );
}

class _Unset {}
