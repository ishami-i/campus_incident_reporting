import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    final currentMode = themeNotifier.value;
    final isDarkMode = currentMode == ThemeMode.dark ||
        (currentMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.primary[600],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: colors.background[100],
            child: SwitchListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(color: colors.text[950], fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                isDarkMode ? 'Currently using Dark Theme' : 'Currently using Light Theme',
                style: TextStyle(color: colors.text[700], fontSize: 12),
              ),
              value: isDarkMode,
              onChanged: (value) {
                themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
        ],
      ),
    );
  }
}
