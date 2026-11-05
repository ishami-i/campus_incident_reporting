import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/validators/form_validator.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/screens/home_screen.dart';
import 'package:incident_report/screens/staff_dashboard_screen.dart';
import 'package:incident_report/screens/signup_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => FormValidator.validateEmail(val, isSignup: false),
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: FormValidator.validatePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary[500],
                foregroundColor: colors.text[50],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final email = _emailController.text.trim().toLowerCase();
                  final profile = UserManagement.getUserProfileFromEmail(email);
                  final namePart = email.split('@')[0];
                  final displayName = namePart[0].toUpperCase() + namePart.substring(1);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logged in successfully as ${profile.role.name.toUpperCase()}!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  if (profile.isStaff) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StaffDashboardScreen(staffEmail: email),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(userName: displayName, userEmail: email),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: Text(
                  'Don\'t have an account? Sign up',
                  style: TextStyle(color: colors.primary[600], fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
