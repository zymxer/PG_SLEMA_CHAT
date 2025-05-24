class RegisterRequest {
  final String username;
  final String password;
  final String email;

  const RegisterRequest(this.username, this.password, this.email);

  Map<String, String> toJson() {
    return {
      'username': username,
      'password': password, //TODO hash
      'email': email
    };
  }
}