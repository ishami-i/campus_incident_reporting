import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:incident_report/logic/auth_service.dart';
import 'package:incident_report/logic/firestore_service.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/screens/home_screen.dart';
import 'package:incident_report/screens/login_screen.dart';
import 'package:incident_report/screens/staff_dashboard_screen.dart';
import 'package:incident_report/themes/app_theme.dart';

/// Decides what to show from the real sign-in state:
/// signed out -> login, student -> home, staff -> staff dashboard.
/// The role comes from the user's Firestore profile, not from the email.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        return _ProfileRouter(user: user);
      },
    );
  }
}

class _ProfileRouter extends StatelessWidget {
  final User user;
  const _ProfileRouter({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirestoreService.profileStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AccountMessage(
            message:
                'Could not load your profile.\n${AuthService.friendlyError(snapshot.error!)}',
          );
        }
        if (!snapshot.hasData) return const _Splash();

        final doc = snapshot.data!;
        final data = doc.data();
        if (!doc.exists || data == null) {
          // Right after sign-up the profile is written a moment later and
          // this stream then emits it. A staff login with no profile stays here.
          return const _AccountMessage(
            message: 'Setting up your account…\n\n'
                'If this takes more than a few seconds, your account has no '
                'profile yet. Staff accounts must be created by an administrator.',
            showSpinner: true,
          );
        }

        final profile = UserProfile.fromMap(user.uid, data);
        return profile.isStaff
            ? StaffDashboardScreen(profile: profile)
            : HomeScreen(profile: profile);
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _AccountMessage extends StatelessWidget {
  final String message;
  final bool showSpinner;
  const _AccountMessage({required this.message, this.showSpinner = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSpinner) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.text[700]),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: AuthService.signOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
