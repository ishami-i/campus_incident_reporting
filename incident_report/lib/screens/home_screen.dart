import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/auth_service.dart';
import 'package:incident_report/logic/firestore_service.dart';
import 'package:incident_report/logic/incident_model.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/widgets/incident_widgets.dart';
import 'package:incident_report/widgets/welcome.dart';
import 'package:incident_report/widgets/report_summary_student.dart';
import 'package:incident_report/widgets/recent_reports.dart';
import 'package:incident_report/screens/reporting_screen.dart';
import 'package:incident_report/screens/incidents_screen.dart';
import 'package:incident_report/screens/profile_screen.dart';
import 'package:incident_report/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserProfile profile;

  const HomeScreen({super.key, required this.profile});

  int _count(List<IncidentModel> list, String status) =>
      list.where((i) => i.status == status).length;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.background[50],
      appBar: AppBar(
        title: Text(
          'Campus Incident Reporting',
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
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colors.primary[500]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ProfileAvatar(photoUrl: profile.photoUrl, radius: 30),
                  const SizedBox(height: 10),
                  Text(
                    profile.name,
                    style: TextStyle(
                      color: colors.text[50],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.email,
                    style: TextStyle(
                      color: colors.text[50]!.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IncidentsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('New Report'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () async {
                Navigator.pop(context);
                await AuthService.signOut();
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirestoreService.myIncidentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorNotice(error: snapshot.error!);

          final loading = !snapshot.hasData;
          final incidents = (snapshot.data?.docs ?? [])
              .map(IncidentModel.fromDoc)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeWidget(profile: profile),
                const SizedBox(height: 20),
                ReportSummaryStudent(
                  totalCount: incidents.length,
                  submittedCount: _count(incidents, 'submitted'),
                  inProgressCount: _count(incidents, 'in progress'),
                  resolvedCount: _count(incidents, 'resolved'),
                ),
                const SizedBox(height: 20),
                if (loading)
                  const LoadingBox()
                else
                  RecentReports(reports: incidents.take(5).toList()),
                const SizedBox(height: 80), // room for the floating button
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.accent[500],
        foregroundColor: colors.text[50],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportingScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Report'),
      ),
    );
  }
}
