import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/screens/login_screen.dart';
import 'package:incident_report/screens/settings_screen.dart';
import 'package:incident_report/screens/password_change_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Alex Johnson');
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
        actions: [
          // Direct logout on top profile icon without confirmation dialog
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: colors.primary[500],
                    child: Icon(Icons.person, size: 70, color: colors.text[50]),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile picture updated successfully!')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.accent[500],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.text[950]),
                    decoration: const InputDecoration(border: UnderlineInputBorder()),
                  )
                : Text(
                    _nameController.text,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.text[950],
                    ),
                  ),
            const SizedBox(height: 8),
            Text(
              'alex.johnson@alustudent.com',
              style: TextStyle(
                fontSize: 14,
                color: colors.text[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary[500],
                foregroundColor: colors.text[50],
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              label: Text(_isEditing ? 'Save Profile' : 'Edit Profile Name'),
            ),
            const SizedBox(height: 16),
            Card(
              color: colors.background[100],
              child: const ListTile(
                leading: Icon(Icons.badge),
                title: Text('Role'),
                trailing: Text('Student', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Card(
              color: colors.background[100],
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PasswordChangeScreen(isStaff: false)),
                  );
                },
              ),
            ),
            Card(
              color: colors.background[100],
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
