class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String? profileImagePath;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    this.profileImagePath,
  });
}

class BusinessProfile {
  final String businessName;
  final String email;
  final String location;
  final String? businessField;
  final String? profileImagePath;

  BusinessProfile({
    required this.businessName,
    required this.email,
    required this.location,
    this.businessField,
    this.profileImagePath,
  });
}
