import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/incident_model.dart';
import 'package:incident_report/screens/incident_detail_screen.dart';
import 'package:incident_report/widgets/incident_widgets.dart';

class RecentReports extends StatelessWidget {
  final List<IncidentModel> reports;

  const RecentReports({super.key, this.reports = const []});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reports',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.text[950],
          ),
        ),
        const SizedBox(height: 8),
        reports.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.background[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No reports yet. Tap "New Report" to submit one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.text[700]),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return IncidentCard(
                    incident: report,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              IncidentDetailScreen(incidentId: report.id),
                        ),
                      );
                    },
                  );
                },
              ),
      ],
    );
  }
}
