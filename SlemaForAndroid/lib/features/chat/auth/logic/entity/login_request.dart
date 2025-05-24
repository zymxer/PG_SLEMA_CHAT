class LoginRequest {
  final String username;
  final String password;

  const LoginRequest(this.username, this.password);

  Map<String, String> toJson() {
    return {
      'username': username,
      'password': password, // hash
    };
  }
}