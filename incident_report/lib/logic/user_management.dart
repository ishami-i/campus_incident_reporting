enum UserRole { student, staff }

enum StaffPosition { maintenance, security, cleaning, campusOperations, nurse, other }

class UserProfile {
  final String email;
  final String name;
  final UserRole role;
  final StaffPosition? staffPosition;

  UserProfile({
    required this.email,
    required this.name,
    required this.role,
    this.staffPosition,
  });

  bool get isStudent => role == UserRole.student;
  bool get isStaff => role == UserRole.staff;
}

class UserManagement {
  /// Determines user role and staff position from email address
  static UserProfile getUserProfileFromEmail(String email, {String name = 'User'}) {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.endsWith('@alustudent.com')) {
      return UserProfile(
        email: normalizedEmail,
        name: name,
        role: UserRole.student,
      );
    } else if (normalizedEmail.endsWith('@alueducation.com')) {
      StaffPosition position = StaffPosition.other;
      if (normalizedEmail.startsWith('facility') || normalizedEmail.startsWith('maintenance')) {
        position = StaffPosition.maintenance;
      } else if (normalizedEmail.startsWith('security')) {
        position = StaffPosition.security;
      } else if (normalizedEmail.startsWith('cleaning') || normalizedEmail.startsWith('sanitation')) {
        position = StaffPosition.cleaning;
      } else if (normalizedEmail.startsWith('operations') || normalizedEmail.startsWith('campus')) {
        position = StaffPosition.campusOperations;
      } else if (normalizedEmail.startsWith('nurse') || normalizedEmail.startsWith('medical')) {
        position = StaffPosition.nurse;
      }

      return UserProfile(
        email: normalizedEmail,
        name: name,
        role: UserRole.staff,
        staffPosition: position,
      );
    } else {
      return UserProfile(
        email: normalizedEmail,
        name: name,
        role: UserRole.student,
      );
    }
  }

  /// Check if user has permission to perform actions (e.g. change status)
  static bool canChangeStatus(UserProfile profile, String incidentCategory) {
    if (profile.isStudent) return false;
    if (profile.isStaff) {
      if (profile.staffPosition == StaffPosition.campusOperations) return true;
      if (profile.staffPosition == StaffPosition.maintenance) {
        return ['water', 'electricity', 'facility', 'other'].contains(incidentCategory.toLowerCase());
      }
      if (profile.staffPosition == StaffPosition.security) {
        return incidentCategory.toLowerCase() == 'safety';
      }
      if (profile.staffPosition == StaffPosition.cleaning) {
        return incidentCategory.toLowerCase() == 'sanitation';
      }
    }
    return false;
  }
}
