import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/widgets/signup_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.background[50],
      appBar: AppBar(
        title: Text(
          'Student Sign Up',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
        iconTheme: IconThemeData(color: colors.text[950]),
      ),
      body: const Center(
        child: SignupForm(),
      ),
    );
  }
}
