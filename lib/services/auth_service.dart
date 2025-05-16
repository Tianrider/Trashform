import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      if (kDebugMode) {
        print('Attempting to sign in with email: $email');
      }

      try {
        // Try the regular method first
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (kDebugMode) {
          print('Sign in successful for user: ${credential.user?.uid}');
        }

        return credential;
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails')) {
          // Handle the specific type casting error
          if (kDebugMode) {
            print('Caught PigeonUserDetails error, trying direct auth check');
          }

          // Try a direct authentication approach
          try {
            // Manually check if auth worked despite the error
            await Future.delayed(const Duration(milliseconds: 1000));
            final currentUser = _auth.currentUser;

            if (currentUser != null) {
              if (kDebugMode) {
                print(
                    'User is actually signed in despite error: ${currentUser.uid}');
              }

              // Just return null - we'll handle this in the calling code
              return null;
            }
          } catch (directAuthError) {
            if (kDebugMode) {
              print('Error in direct auth check: $directAuthError');
            }
          }
        }
        // Re-throw if we couldn't handle it
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException during sign in:');
        print('  Code: ${e.code}');
        print('  Message: ${e.message}');
        print('  Email: $email');
        if (e.stackTrace != null) {
          print('  Stack trace: ${e.stackTrace}');
        }
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during sign in: $e');
      }
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(String name,
      String email, String password, bool receiveNewsletter) async {
    try {
      if (kDebugMode) {
        print('Attempting to register with email: $email, name: $name');
      }

      try {
        // Create user in Firebase Auth
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (kDebugMode) {
          print('Firebase Auth user created: ${result.user?.uid}');
        }

        // Add user details to Firestore
        try {
          await _firestore.collection('users').doc(result.user!.uid).set({
            'name': name,
            'email': email,
            'receiveNewsletter': receiveNewsletter,
            'created': FieldValue.serverTimestamp(),
          });

          if (kDebugMode) {
            print('User data added to Firestore');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error adding user data to Firestore: $e');
          }
          // Continue despite Firestore error
        }

        // Update user profile with name
        try {
          await result.user!.updateDisplayName(name);
          if (kDebugMode) {
            print('User profile updated with name: $name');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error updating user profile: $e');
          }
          // Continue despite profile update error
        }

        return result;
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails')) {
          // Handle the specific type casting error
          if (kDebugMode) {
            print(
                'Caught PigeonUserDetails error during registration, checking auth status');
          }

          // Try a direct authentication approach
          try {
            // Manually check if auth worked despite the error
            await Future.delayed(const Duration(milliseconds: 1000));
            final currentUser = _auth.currentUser;

            if (currentUser != null) {
              if (kDebugMode) {
                print(
                    'User was actually created despite error: ${currentUser.uid}');
              }

              // Try to update profile and Firestore anyway
              try {
                await currentUser.updateDisplayName(name);

                await _firestore.collection('users').doc(currentUser.uid).set({
                  'name': name,
                  'email': email,
                  'receiveNewsletter': receiveNewsletter,
                  'created': FieldValue.serverTimestamp(),
                });

                if (kDebugMode) {
                  print('User data added in workaround flow');
                }
              } catch (updateError) {
                if (kDebugMode) {
                  print('Error in workaround profile update: $updateError');
                }
              }

              // Return null to indicate we need to use currentUser instead
              return null;
            }
          } catch (directAuthError) {
            if (kDebugMode) {
              print(
                  'Error in direct auth check during registration: $directAuthError');
            }
          }
        }
        // Re-throw if we couldn't handle it
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException during registration:');
        print('  Code: ${e.code}');
        print('  Message: ${e.message}');
        print('  Email: $email');
        if (e.stackTrace != null) {
          print('  Stack trace: ${e.stackTrace}');
        }
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during registration: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        print('User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('Password reset email sent to $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending password reset: $e');
      }
      rethrow;
    }
  }
}
