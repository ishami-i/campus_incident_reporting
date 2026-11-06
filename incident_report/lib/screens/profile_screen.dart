import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/auth_service.dart';
import 'package:incident_report/logic/firestore_service.dart';
import 'package:incident_report/logic/openinary_service.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/validators/form_validator.dart';
import 'package:incident_report/widgets/incident_widgets.dart';
import 'package:incident_report/screens/settings_screen.dart';
import 'package:incident_report/screens/password_change_screen.dart';

/// The signed-in user's profile. Reads live from Firestore; the photo is
/// uploaded to Openinary and only its {path, url} is saved in Firestore.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isBusy = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isBusy = true);
      final bytes = await picked.readAsBytes();
      final image = await OpeninaryService.uploadImage(
        bytes: bytes,
        fileName: picked.name,
      );
      await FirestoreService.updateMyProfile(photo: image.toMap());
      _toast('Profile photo updated!');
    } catch (e) {
      _toast('Could not update photo: ${AuthService.friendlyError(e)}', error: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveName() async {
    final error = FormValidator.validateName(_nameController.text);
    if (error != null) {
      _toast(error, error: true);
      return;
    }
    setState(() => _isBusy = true);
    try {
      await FirestoreService.updateMyProfile(name: _nameController.text);
      setState(() => _isEditing = false);
      _toast('Profile saved!');
    } catch (e) {
      _toast('Could not save: ${AuthService.friendlyError(e)}', error: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    // The auth gate swaps to the login screen; close any screens on top of it.
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: colors.text[950])),
        backgroundColor: colors.primary[500],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirestoreService.myProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorNotice(error: snapshot.error!);
          final data = snapshot.data?.data();
          if (data == null) return const LoadingBox();

          final profile = UserProfile.fromMap(snapshot.data!.id, data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      _isBusy
                          ? CircleAvatar(
                              radius: 55,
                              backgroundColor: colors.primary[500],
                              child: const CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : ProfileAvatar(photoUrl: profile.photoUrl, radius: 55),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _isBusy ? null : _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.accent[500],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
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
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.text[950]),
                        decoration:
                            const InputDecoration(border: UnderlineInputBorder()),
                      )
                    : Text(
                        profile.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.text[950],
                        ),
                      ),
                const SizedBox(height: 8),
                Text(profile.email,
                    style: TextStyle(fontSize: 14, color: colors.text[700])),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary[500],
                    foregroundColor: colors.text[50],
                  ),
                  onPressed: _isBusy
                      ? null
                      : () {
                          if (_isEditing) {
                            _saveName();
                          } else {
                            _nameController.text = profile.name;
                            setState(() => _isEditing = true);
                          }
                        },
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  label: Text(_isEditing ? 'Save Profile' : 'Edit Profile Name'),
                ),
                const SizedBox(height: 16),
                Card(
                  color: colors.background[100],
                  child: ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('Role'),
                    trailing: Text(
                      profile.isStaff
                          ? 'Staff · ${profile.staffPosition?.label ?? ''}'
                          : 'Student',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                        MaterialPageRoute(
                          builder: (context) =>
                              PasswordChangeScreen(isStaff: profile.isStaff),
                        ),
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
                            builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
