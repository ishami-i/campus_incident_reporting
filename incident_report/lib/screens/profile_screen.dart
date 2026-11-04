import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: colors.primary[500],
                child: Icon(Icons.person, size: 60, color: colors.text[50]),
              ),
              const SizedBox(height: 16),
              Text(
                'Alex Johnson',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.text[950],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'alex.johnson@university.edu',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.text[700],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: colors.background[100],
                child: ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Role'),
                  trailing: const Text('Student', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
