
class User {
  // todo profile pic
  final String id;
  final String name;

  User(this.id, this.name);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'] as String,
      json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}