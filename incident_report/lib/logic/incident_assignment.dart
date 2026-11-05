import 'user_management.dart';

class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'water', 'electricity', 'facility', 'safety', 'sanitation', 'other'
  final String status; // 'in progress', 'resolved', 'closed'
  final String studentEmail;
  final String location;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.studentEmail,
    required this.location,
  });
}

class IncidentAssignment {
  /// Ensures right content goes to the right user based on role and category mapping.
  /// - Staff see tasks in their category.
  /// - 'other' category is routed to facility/maintenance staff.
  /// - Students see only their submitted incidents.
  static List<IncidentModel> filterIncidentsForUser(UserProfile profile, List<IncidentModel> allIncidents) {
    if (profile.isStudent) {
      return allIncidents.where((incident) => incident.studentEmail.toLowerCase() == profile.email.toLowerCase()).toList();
    } else if (profile.isStaff) {
      final position = profile.staffPosition;
      return allIncidents.where((incident) {
        final cat = incident.category.toLowerCase();

        if (position == StaffPosition.campusOperations) {
          return true;
        } else if (position == StaffPosition.maintenance) {
          // Maintenance handles water, electricity, facility, and 'other'
          return ['water', 'electricity', 'facility', 'other'].contains(cat);
        } else if (position == StaffPosition.security) {
          return cat == 'safety';
        } else if (position == StaffPosition.cleaning) {
          return cat == 'sanitation';
        } else if (position == StaffPosition.nurse) {
          return cat == 'safety' || cat == 'other';
        }
        
        return cat == 'facility' || cat == 'other';
      }).toList();
    }

    return [];
  }
}
