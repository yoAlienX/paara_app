import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register user
  Future<AuthResult> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    User? user;

    try {
      print("=== STARTING REGISTRATION PROCESS ===");
      print("Name: $name");
      print("Email: $email");

      // Validate input
      if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
        return AuthResult(success: false, message: 'All fields are required');
      }

      String normalizedEmail = email.trim().toLowerCase();
      print("Normalized email: $normalizedEmail");

      // Additional email validation for college domain
      if (!normalizedEmail.endsWith('@duk.ac.in')) {
        return AuthResult(success: false, message: 'Please use your college email (@duk.ac.in)');
      }

      print("Attempting to create user with Firebase Auth...");

      // Create user with Firebase Auth first
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      print("Firebase Auth user created successfully.");
      user = userCredential.user;

      if (user == null) {
        // This case is rare but good to handle
        return AuthResult(success: false, message: 'User creation failed unexpectedly.');
      }

      print("Firebase Auth user UID: ${user.uid}");

      // Update display name
      try {
        print("Updating display name...");
        await user.updateDisplayName(name.trim());
        await user.reload(); // Reload user to get updated info
        user = _auth.currentUser;
        print("Display name updated successfully.");
      } catch (displayNameError) {
        print("WARNING: Display name update failed: $displayNameError. Continuing...");
        // This is not a critical failure, so we continue the process.
      }

      // Create user document in Firestore
      try {
        print("Creating Firestore user document for UID: ${user!.uid}...");
        final userData = {
          'uid': user.uid,
          'name': name.trim(),
          'email': user.email ?? normalizedEmail,
          'displayName': user.displayName ?? name.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'isActive': true,
          'profileComplete': false,
          'emailVerified': user.emailVerified,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).set(userData);

        print("SUCCESS: User document created in Firestore.");

      } catch (firestoreError) {
        // CRITICAL: This is the block causing the issue.
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        print("CRITICAL ERROR: Firestore write failed after user creation.");
        print("Error: $firestoreError");
        print("Error Type: ${firestoreError.runtimeType}");
        print("Attempting to delete orphaned Firebase Auth user...");
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

        try {
          await user?.delete();
          print("Orphaned user account (${user?.email}) deleted successfully.");
        } catch (deleteError) {
          print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          print("CRITICAL FAILURE: FAILED TO DELETE ORPHANED USER.");
          print("User ${user?.email} may be stuck in limbo.");
          print("Delete Error: $deleteError");
          print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        }

        // Return a clear error message to the user.
        return AuthResult(
          success: false,
          message: 'Failed to save user profile. Please try again in a moment.',
        );
      }

      print("=== REGISTRATION PROCESS COMPLETED SUCCESSFULLY ===");
      // After successful registration, fetch the newly created user data to return it
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return AuthResult(
        success: true,
        message: 'Registration successful!',
        userData: userDoc.data() as Map<String, dynamic>?,
      );

    } on FirebaseAuthException catch (e) {
      print('=== FIREBASE AUTH EXCEPTION DURING REGISTRATION ===');
      print('Error code: ${e.code}');
      print('Error message: ${e.message}');
      return AuthResult(success: false, message: _getAuthErrorMessage(e));
    } catch (e) {
      print('=== UNEXPECTED REGISTRATION ERROR ===');
      print('Error: $e');
      // Attempt to clean up if user was partially created
      if (user != null) {
        await user.delete().catchError((deleteError) {
          print("Failed to clean up user during unexpected error: $deleteError");
        });
      }
      return AuthResult(success: false, message: 'An unexpected error occurred. Please try again.');
    }
  }

  // Sign in user - UPDATED
  Future<AuthResult> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Sign in with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        return AuthResult(success: false, message: 'Login failed, user not found.');
      }

      // Step 2: Fetch user document from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // This is an edge case where a user exists in Auth but not Firestore
        return AuthResult(success: false, message: 'User profile not found.');
      }

      // Step 3: Return the Firestore data
      return AuthResult(
        success: true,
        message: 'Login successful!',
        userData: userDoc.data() as Map<String, dynamic>?,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e));
    } catch (e) {
      print("Login Error: $e");
      return AuthResult(success: false, message: 'An unexpected error occurred.');
    }
  }

  // Reset Password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return AuthResult(success: true, message: 'Password reset link sent to your email.');
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult(success: false, message: 'An unexpected error occurred.');
    }
  }


  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper to convert Firebase Auth error codes into user-friendly messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

// A simple class to return the result of an auth operation - UPDATED
class AuthResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? userData; // Changed from User? to Map?

  AuthResult({
    required this.success,
    required this.message,
    this.userData,
  });
}
