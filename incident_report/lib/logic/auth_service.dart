import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incident_report/logic/firestore_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Creates the Firebase Auth account, then the student profile document.
  /// If the profile cannot be saved, the new account is deleted again so the
  /// email is not left half-registered. Errors propagate to the caller.
  static Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    try {
      await FirestoreService.createStudentProfile(name: name);
      await _auth.currentUser?.updateDisplayName(name.trim());
    } catch (_) {
      await _auth.currentUser?.delete();
      rethrow;
    }
  }

  /// Throws [FirebaseAuthException] on a wrong password or unknown account.
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Re-authenticates with the current password, then sets the new one.
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Not signed in');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// Turns an exception into a message that is safe to show to the user.
  static String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-email':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account with this email already exists. Please log in instead.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a moment and try again.';
        case 'network-request-failed':
          return 'No internet connection. Please check your network.';
        case 'requires-recent-login':
          return 'Please log in again and retry.';
        case 'user-disabled':
          return 'This account has been disabled.';
      }
      return error.message ?? 'Authentication failed (${error.code}).';
    }
    if (error is FirebaseException && error.code == 'permission-denied') {
      return 'You do not have permission to do that.';
    }
    return error.toString();
  }
}
