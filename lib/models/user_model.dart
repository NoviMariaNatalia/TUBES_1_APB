class User {
  final String id;
  final String name;
  final String email;
  final String username;
  final String password;

  User({
    this.id = '',
    required this.name,
    required this.email,
    required this.username,
    required this.password,
  });

  // Convert User to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
    };
  }

  // Create User from Firestore Map
  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }
}