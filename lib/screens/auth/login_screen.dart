import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trashform/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        print(
            'Login attempt started with email: ${_emailController.text.trim()}');
      }

      final result = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Check for direct Firebase auth success even if result is null
      final currentUser = FirebaseAuth.instance.currentUser;

      if (result != null) {
        // Normal success path
        if (kDebugMode) {
          print(
              'Login successful via normal path. User ID: ${result.user?.uid}');
          print('Email verified: ${result.user?.emailVerified}');
        }
      } else if (currentUser != null) {
        // Workaround path - user is logged in despite the error
        if (kDebugMode) {
          print('Login successful via workaround. User ID: ${currentUser.uid}');
        }
      } else {
        // Neither approach worked
        throw Exception(
            "Authentication failed - user not logged in after attempt");
      }

      // Wait a bit to ensure the user is properly processed by Firebase
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Double check if user is actually signed in
        final verifiedUser = FirebaseAuth.instance.currentUser;
        if (verifiedUser != null) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else {
          setState(() {
            _errorMessage = 'Failed to authenticate. Please try again.';
            _isLoading = false;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (kDebugMode) {
        print('Login FirebaseAuthException:');
        print('  Code: ${e.code}');
        print('  Message: ${e.message}');
      }

      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email. Please sign up.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled. Please contact support.';
          break;
        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;
        default:
          message = 'An error occurred (${e.code}). Please try again later.';
      }

      if (kDebugMode) {
        print('Setting error message: $message');
      }

      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Login unknown error: $e');
      }

      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    } finally {
      if (kDebugMode && _errorMessage != null) {
        print('Login failed with error: $_errorMessage');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFEDF7ED)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button and signup link
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page title
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.0, bottom: 32.0),
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Text(
                        _obscurePassword ? 'Show' : 'Hide',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),

                const Spacer(),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      disabledBackgroundColor:
                          const Color(0xFF2E7D32).withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),

                // Forgot password link
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Add forgot password functionality
                    },
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
