class User {
  final String name;
  final String email;
  final String? profilePicUrl;

  User({
    required this.name,
    required this.email,
    this.profilePicUrl,
  });
}
