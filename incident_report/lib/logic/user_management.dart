import 'package:incident_report/logic/incident_rules.dart';

enum UserRole { student, staff }

enum StaffPosition {
  maintenance,
  security,
  cleaning,
  campusOperations,
  nurse,
  other,
}

extension StaffPositionX on StaffPosition {
  String get label {
    switch (this) {
      case StaffPosition.maintenance:
        return 'Maintenance';
      case StaffPosition.security:
        return 'Security';
      case StaffPosition.cleaning:
        return 'Cleaning';
      case StaffPosition.campusOperations:
        return 'Campus Operations';
      case StaffPosition.nurse:
        return 'Nurse';
      case StaffPosition.other:
        return 'Staff';
    }
  }
}

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final StaffPosition? staffPosition;
  final String? photoUrl;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.staffPosition,
    this.photoUrl,
  });

  bool get isStudent => role == UserRole.student;
  bool get isStaff => role == UserRole.staff;

  /// Builds a profile from a `users/{uid}` Firestore document.
  /// Role and position come from the database, never from the email address.
  factory UserProfile.fromMap(String uid, Map<String, dynamic> m) {
    final role = m['role'] == 'staff' ? UserRole.staff : UserRole.student;
    StaffPosition? position;
    if (role == UserRole.staff) {
      position = StaffPosition.values.firstWhere(
        (p) => p.name == m['staffPosition'],
        orElse: () => StaffPosition.other,
      );
    }
    final photo = m['photo'];
    return UserProfile(
      uid: uid,
      email: (m['email'] as String?) ?? '',
      name: (m['name'] as String?) ?? 'User',
      role: role,
      staffPosition: position,
      photoUrl: photo is Map ? photo['url'] as String? : null,
    );
  }
}

class UserManagement {
  /// Whether this user may change the status of an incident in [category].
  /// Mirrors the `handledBy` rule enforced by firestore.rules.
  static bool canChangeStatus(UserProfile profile, String category) {
    if (!profile.isStaff || profile.staffPosition == null) return false;
    return IncidentRouting.handledBy(category.toLowerCase())
        .contains(profile.staffPosition!.name);
  }
}
