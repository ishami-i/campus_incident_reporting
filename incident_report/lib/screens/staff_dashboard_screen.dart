import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/auth_service.dart';
import 'package:incident_report/logic/firestore_service.dart';
import 'package:incident_report/logic/incident_model.dart';
import 'package:incident_report/logic/incident_rules.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/screens/incident_detail_screen.dart';
import 'package:incident_report/screens/profile_screen.dart';
import 'package:incident_report/screens/status_changing_screen.dart';
import 'package:incident_report/widgets/incident_widgets.dart';

/// Incidents routed to the signed-in staff member's position, live from
/// Firestore (`visibleTo` array-contains query).
class StaffDashboardScreen extends StatefulWidget {
  final UserProfile profile;

  const StaffDashboardScreen({super.key, required this.profile});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  String? _statusFilter; // null = all

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    final profile = widget.profile;
    final position = profile.staffPosition ?? StaffPosition.other;

    return Scaffold(
      backgroundColor: colors.background[50],
      appBar: AppBar(
        title: Text(
          'Staff Portal (${position.label})',
          style: TextStyle(color: colors.text[950], fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.primary[500],
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
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
            onPressed: AuthService.signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assigned Incidents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Showing incidents routed to your position.',
              style: TextStyle(fontSize: 13, color: colors.text[700]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final status in <String?>[null, ...IncidentConst.statuses])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status == null ? 'All' : status.toUpperCase()),
                        selected: _statusFilter == status,
                        onSelected: (_) => setState(() => _statusFilter = status),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: FirestoreService.staffIncidentsStream(
                  position.name,
                  status: _statusFilter,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ErrorNotice(error: snapshot.error!);
                  }
                  if (!snapshot.hasData) return const LoadingBox();

                  final incidents =
                      snapshot.data!.docs.map(IncidentModel.fromDoc).toList();
                  if (incidents.isEmpty) {
                    return Center(
                      child: Text(
                        'No incidents found.',
                        style: TextStyle(color: colors.text[700]),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: incidents.length,
                    itemBuilder: (context, index) {
                      final incident = incidents[index];
                      final canUpdate = UserManagement.canChangeStatus(
                          profile, incident.category);
                      return IncidentCard(
                        incident: incident,
                        showLocation: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncidentDetailScreen(
                                incidentId: incident.id,
                                staffProfile: profile,
                              ),
                            ),
                          );
                        },
                        trailing: canUpdate
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary[500],
                                  foregroundColor: colors.text[50],
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StatusChangingScreen(
                                        incident: incident,
                                        profile: profile,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Update'),
                              )
                            : null,
                      );
                    },
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
