import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/screens/profile_screen.dart';

class WelcomeWidget extends StatelessWidget {
  final String userName;
  const WelcomeWidget({super.key, this.userName = 'Student'});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Big Hello, $userName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.text[950],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Work together to make our university great.',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.text[700],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: CircleAvatar(
            radius: 24,
            backgroundColor: colors.primary[500],
            child: Icon(
              Icons.person,
              color: colors.text[50],
            ),
          ),
        ),
      ],
    );
  }
}
