/// A local profile (multi-account on the same device). Pure model.
library;

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;

  /// May be empty for the default profile — the UI shows a localized fallback.
  final String name;
  final DateTime createdAt;
}
