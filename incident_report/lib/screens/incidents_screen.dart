import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/screens/reporting_screen.dart';
import 'package:incident_report/screens/incident_detail_screen.dart';

class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    final allIncidents = [
      {
        'id': '1',
        'title': 'Water leakage in Library 2nd floor',
        'category': 'water',
        'status': 'in progress',
        'date': 'Today, 10:30 AM',
      },
      {
        'id': '2',
        'title': 'Projector power socket faulty',
        'category': 'electricity',
        'status': 'resolved',
        'date': 'Yesterday',
      },
      {
        'id': '3',
        'title': 'Broken door handle in Enterprise Commons',
        'category': 'facility',
        'status': 'closed',
        'date': 'Oct 24, 2023',
      },
      {
        'id': '4',
        'title': 'Corridor light flickering',
        'category': 'electricity',
        'status': 'in progress',
        'date': 'Oct 22, 2023',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Incidents',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allIncidents.length,
        itemBuilder: (context, index) {
          final incident = allIncidents[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: colors.background[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary[500]?.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  incident['category'] == 'water'
                      ? Icons.water_drop
                      : incident['category'] == 'electricity'
                          ? Icons.electric_bolt
                          : Icons.business,
                  color: colors.primary[600],
                ),
              ),
              title: Text(
                incident['title']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.text[950],
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Row(
                  children: [
                    _buildStatusBadge(incident['status']!),
                    const Spacer(),
                    Text(
                      incident['date']!,
                      style: TextStyle(fontSize: 12, color: colors.text[700]),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IncidentDetailScreen(
                      incidentId: incident['id']!,
                      title: incident['title']!,
                      status: incident['status']!,
                    ),
                  ),
                );
              },
            ),
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

  Widget _buildStatusBadge(String status) {
    Color color;
    if (status == 'in progress') {
      color = Colors.orange;
    } else if (status == 'resolved') {
      color = Colors.green;
    } else {
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
