/// Allowed values (single source of truth; mirrors firestore.rules).
class IncidentConst {
  static const categories = [
    'water',
    'electricity',
    'facility',
    'safety',
    'sanitation',
    'other',
  ];

  /// Every status an incident can have.
  static const statuses = ['submitted', 'in progress', 'resolved', 'closed'];

  /// Statuses staff may set (an incident starts as 'submitted').
  static const staffSettableStatuses = ['in progress', 'resolved', 'closed'];

  static const buildings = [
    'Enterprise commons',
    'Learning commons',
    'Social commons',
  ];
}

/// Decides which staff positions see / handle an incident.
/// Computed once at creation and stored on the document so staff dashboards
/// are a server-side query instead of a client-side filter.
/// Position strings equal `StaffPosition.<name>` from user_management.dart.
class IncidentRouting {
  static List<String> visibleTo(String category) {
    switch (category) {
      case 'water':
      case 'electricity':
        return ['maintenance', 'campusOperations'];
      case 'facility':
        return ['maintenance', 'campusOperations', 'other'];
      case 'safety':
        return ['security', 'nurse', 'campusOperations'];
      case 'sanitation':
        return ['cleaning', 'campusOperations'];
      default: // 'other'
        return ['maintenance', 'nurse', 'campusOperations', 'other'];
    }
  }

  /// Positions allowed to change status (nurse and 'other' are view-only).
  static List<String> handledBy(String category) => visibleTo(category)
      .where((p) => p != 'nurse' && p != 'other')
      .toList();
}
