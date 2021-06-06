/// User model
class User {
  const User({
    required this.id,
    this.email,
    this.name,
    this.photo,
  });

  /// Current user id.
  final String id;

  /// Current user email address.
  final String? email;

  /// Current user name.
  final String? name;

  /// Current user photo.
  final String? photo;

  /// Empty user.
  static const empty = User(id: '');

  /// Check if current user is empty.
  bool get isEmpty => this == User.empty;

  /// Check if current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, photo: $photo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.photo == photo;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ name.hashCode ^ photo.hashCode;
  }
}
