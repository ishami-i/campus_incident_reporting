import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.background[50],
      appBar: AppBar(
        title: Text(
          'Login - Campus Incidents',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
      ),
      body: const Center(
        child: LoginForm(),
      ),
    );
  }
}
