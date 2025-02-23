class PilluUserModel {
  PilluUserModel({
    required this.imageUrl,
    required this.firstName,
    required this.lastName,
    required this.id,
  });

  ///
  factory PilluUserModel.fromMap(final Map<String, dynamic> map) =>
      PilluUserModel(
        imageUrl: map['imageUrl'] as String? ?? '',
        firstName: map['firstName'] as String? ?? '',
        lastName: map['lastName'] as String? ?? '',
        id: map['id'] as String? ?? '',
      );

  String imageUrl;
  String firstName;
  String lastName;
  String id;

  /// Method to convert the UserModel to a Map (e.g., for JSON encoding)
  Map<String, dynamic> toMap() => <String, dynamic>{
        'imageUrl': imageUrl,
        'firstName': firstName,
        'lastName': lastName,
        'id': id,
      };

  PilluUserModel copyWith({
    final String? imageUrl,
    final String? firstName,
    final String? lastName,
    final String? id,
  }) =>
      PilluUserModel(
        imageUrl: imageUrl ?? this.imageUrl,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        id: id ?? this.id,
      );
}
