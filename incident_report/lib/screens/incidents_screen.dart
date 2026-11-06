import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/firestore_service.dart';
import 'package:incident_report/logic/incident_model.dart';
import 'package:incident_report/widgets/incident_widgets.dart';
import 'package:incident_report/screens/reporting_screen.dart';
import 'package:incident_report/screens/incident_detail_screen.dart';

/// The signed-in student's own reports, live from Firestore.
class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Reports', style: TextStyle(color: colors.text[950])),
        backgroundColor: colors.primary[500],
      ),
      body: StreamBuilder(
        stream: FirestoreService.myIncidentsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorNotice(error: snapshot.error!);
          if (!snapshot.hasData) return const LoadingBox();

          final incidents =
              snapshot.data!.docs.map(IncidentModel.fromDoc).toList();
          if (incidents.isEmpty) {
            return Center(
              child: Text(
                'No incidents reported yet.',
                style: TextStyle(color: colors.text[700]),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return IncidentCard(
                incident: incident,
                showLocation: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          IncidentDetailScreen(incidentId: incident.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.accent[500],
        foregroundColor: colors.text[50],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportingScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
