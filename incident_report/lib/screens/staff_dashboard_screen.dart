import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/logic/incident_assignment.dart';
import 'package:incident_report/screens/status_changing_screen.dart';
import 'package:incident_report/screens/login_screen.dart';
import 'package:incident_report/screens/profile_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  final String staffEmail;
  const StaffDashboardScreen({super.key, required this.staffEmail});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    final profile = UserManagement.getUserProfileFromEmail(staffEmail);

    final allIncidents = [
      IncidentModel(
        id: '1',
        title: 'Water leakage in Library 2nd floor',
        description: 'Pipe leaking near the reading section.',
        category: 'water',
        status: 'in progress',
        studentEmail: 'student1@alustudent.com',
        location: 'Enterprise Commons - Library',
      ),
      IncidentModel(
        id: '2',
        title: 'Projector power socket faulty',
        description: 'Sparking socket in classroom 304.',
        category: 'electricity',
        status: 'in progress',
        studentEmail: 'student2@alustudent.com',
        location: 'Learning Commons - Room 304',
      ),
      IncidentModel(
        id: '3',
        title: 'Main gate security light broken',
        description: 'Dark area at entrance.',
        category: 'safety',
        status: 'in progress',
        studentEmail: 'student3@alustudent.com',
        location: 'Social Commons - Main Gate',
      ),
      IncidentModel(
        id: '4',
        title: 'Cafeteria sanitation check needed',
        description: 'Spill near food station.',
        category: 'sanitation',
        status: 'submitted',
        studentEmail: 'student4@alustudent.com',
        location: 'Enterprise Commons - Cafeteria',
      ),
    ];

    final filteredIncidents = IncidentAssignment.filterIncidentsForUser(profile, allIncidents);

    return Scaffold(
      backgroundColor: colors.background[50],
      appBar: AppBar(
        title: Text(
          'Staff Portal (${profile.staffPosition?.name.toUpperCase() ?? 'STAFF'})',
          style: TextStyle(color: colors.text[950], fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary[500],
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Incidents (${profile.staffPosition?.name.toUpperCase() ?? 'General'})',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Showing tasks assigned to your category (Other category routed to Facility).',
              style: TextStyle(fontSize: 13, color: colors.text[700]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredIncidents.isEmpty
                  ? Center(
                      child: Text(
                        'No incidents found for your category.',
                        style: TextStyle(color: colors.text[700]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredIncidents.length,
                      itemBuilder: (context, index) {
                        final incident = filteredIncidents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: colors.background[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              incident.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colors.text[950],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text('Location: ${incident.location}', style: TextStyle(color: colors.text[700], fontSize: 13)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(incident.category.toUpperCase(), style: const TextStyle(fontSize: 10)),
                                      backgroundColor: colors.primary[200],
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(incident.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
                                      backgroundColor: Colors.orange.shade200,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary[500],
                                foregroundColor: colors.text[50],
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StatusChangingScreen(
                                      incidentId: incident.id,
                                      currentStatus: incident.status,
                                      incidentCategory: incident.category,
                                      staffPosition: profile.staffPosition?.name ?? 'maintenance',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Update'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
