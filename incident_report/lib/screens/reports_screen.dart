import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
      ),
      body: Center(
        child: Text(
          'Reports List View',
          style: TextStyle(fontSize: 18, color: colors.text[700]),
        ),
      ),
    );
  }
}
