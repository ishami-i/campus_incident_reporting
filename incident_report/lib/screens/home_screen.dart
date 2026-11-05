import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/widgets/welcome.dart';
import 'package:incident_report/widgets/report_summary_student.dart';
import 'package:incident_report/widgets/recent_reports.dart';
import 'package:incident_report/screens/reporting_screen.dart';
import 'package:incident_report/screens/incidents_screen.dart';
import 'package:incident_report/screens/profile_screen.dart';
import 'package:incident_report/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HomeScreen({
    super.key,
    this.userName = 'Alex',
    this.userEmail = 'alex.johnson@alustudent.com',
  });

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
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      color: colors.text[50],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
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
              title: const Text('All Reports'),
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
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeWidget(userName: userName),
            const SizedBox(height: 20),
            const ReportSummaryStudent(),
            const SizedBox(height: 20),
            const RecentReports(),
          ],
        ),
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
