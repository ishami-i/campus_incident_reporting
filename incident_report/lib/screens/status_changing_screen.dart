import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/incident_model.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/widgets/status_changing_form.dart';

class StatusChangingScreen extends StatelessWidget {
  final IncidentModel incident;
  final UserProfile profile;

  const StatusChangingScreen({
    super.key,
    required this.incident,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    final allowed = UserManagement.canChangeStatus(profile, incident.category);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Incident Status',
            style: TextStyle(color: colors.text[950])),
        backgroundColor: colors.primary[500],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: allowed
              ? SingleChildScrollView(
                  child: Card(
                    color: colors.background[100],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StatusChangingForm(
                        incidentId: incident.id,
                        incidentLabel: '#${incident.shortId}',
                        currentStatus: incident.status,
                      ),
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
                      'Your position (${profile.staffPosition?.label ?? 'Staff'}) '
                      'cannot change incidents in the "${incident.category}" category.',
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
