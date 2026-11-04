import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/widgets/status_changing_form.dart';

class StatusChangingScreen extends StatelessWidget {
  final String incidentId;
  final String currentStatus;
  final String incidentCategory;
  final String staffPosition; // e.g. maintenance, security, cleaning, etc.

  const StatusChangingScreen({
    super.key,
    required this.incidentId,
    required this.currentStatus,
    required this.incidentCategory,
    required this.staffPosition,
  });

  bool get _canModifyStatus {
    final normalizedCategory = incidentCategory.toLowerCase();
    final normalizedPosition = staffPosition.toLowerCase();

    // Staff see tasks in their category, and 'other' category goes to facility/maintenance
    if (normalizedPosition == 'maintenance' || normalizedPosition == 'facility') {
      return ['water', 'electricity', 'facility', 'other'].contains(normalizedCategory);
    } else if (normalizedPosition == 'security') {
      return normalizedCategory == 'safety';
    } else if (normalizedPosition == 'cleaning') {
      return normalizedCategory == 'sanitation';
    } else if (normalizedPosition == 'campus operations' || normalizedPosition == 'nurse') {
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Incident Status',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _canModifyStatus
              ? Card(
                  color: colors.background[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StatusChangingForm(
                      incidentId: incidentId,
                      currentStatus: currentStatus,
                      onStatusChanged: (newStatus, reasoning) {
                        // Handle backend status update & optional reasoning logging
                      },
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Access Restricted',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.text[950],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your staff position ($staffPosition) does not match category "$incidentCategory". Note: Category "other" is routed to Facility/Maintenance.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.text[700]),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
