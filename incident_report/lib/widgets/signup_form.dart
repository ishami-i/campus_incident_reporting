import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/validators/form_validator.dart';
import 'package:incident_report/screens/home_screen.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
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
              'Student Sign Up',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Note: Only students can sign up using their @alustudent.com email.',
              style: TextStyle(
                fontSize: 13,
                color: colors.text[700],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              validator: (val) => FormValidator.validateRequired(val, 'full name'),
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (val) => FormValidator.validateEmail(val, isSignup: true),
              decoration: InputDecoration(
                labelText: 'Student Email (@alustudent.com)',
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
                  final name = _nameController.text.trim();
                  final email = _emailController.text.trim();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student account created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(userName: name, userEmail: email),
                    ),
                  );
                }
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
