import 'package:chat_app/features/user/logic/entity/user.dart';

class UserDto {
  // todo profile pic
  final String id;
  final String name;

  UserDto(this.id, this.name);

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(json['id'], json['name'] ?? 'null');
  }

  User toUser() {
    return User(id, name);
  }

}