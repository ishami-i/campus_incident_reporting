import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/widgets/password_change_form.dart';

class PasswordChangeScreen extends StatelessWidget {
  final bool isStaff;
  const PasswordChangeScreen({super.key, this.isStaff = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.background[50],
      appBar: AppBar(
        title: Text(
          isStaff ? 'Staff Password Change' : 'Student Password Change',
          style: TextStyle(color: colors.text[950]),
        ),
        backgroundColor: colors.primary[500],
      ),
      body: Center(
        child: PasswordChangeForm(isStaff: isStaff),
      ),
    );
  }
}
