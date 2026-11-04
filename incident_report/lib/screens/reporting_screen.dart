import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/widgets/reporting_form.dart';

class ReportingScreen extends StatelessWidget {
  const ReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Incident',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
        iconTheme: IconThemeData(color: colors.text[950]),
      ),
      body: ReportingForm(
        onSubmit: (reportData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Incident "${reportData['title']}" submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, reportData);
        },
      ),
    );
  }
}
