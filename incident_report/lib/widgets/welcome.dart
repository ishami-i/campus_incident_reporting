import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/screens/profile_screen.dart';
import 'package:incident_report/widgets/incident_widgets.dart';

class WelcomeWidget extends StatelessWidget {
  final UserProfile profile;
  const WelcomeWidget({super.key, required this.profile});

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
                'Big Hello, ${profile.name}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.text[950],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Work together to make our university great.',
                style: TextStyle(fontSize: 14, color: colors.text[700]),
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
          child: ProfileAvatar(photoUrl: profile.photoUrl, radius: 24),
        ),
      ],
    );
  }
}
