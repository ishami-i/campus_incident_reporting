import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/screens/incident_detail_screen.dart';

class RecentReports extends StatelessWidget {
  const RecentReports({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    final dummyReports = [
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
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            Text(
              'Recent Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(color: colors.primary[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dummyReports.length,
          itemBuilder: (context, index) {
            final report = dummyReports[index];
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
                    report['category'] == 'water'
                        ? Icons.water_drop
                        : report['category'] == 'electricity'
                            ? Icons.electric_bolt
                            : Icons.business,
                    color: colors.primary[600],
                  ),
                ),
                title: Text(
                  report['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.text[950],
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      _buildStatusBadge(report['status']!),
                      const Spacer(),
                      Text(
                        report['date']!,
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
                        incidentId: report['id']!,
                        title: report['title']!,
                        status: report['status']!,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
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
