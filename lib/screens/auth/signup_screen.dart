import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trashform/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _receiveNewsletter = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
        _isLoading = false;
      });
      return;
    }

    try {
      if (kDebugMode) {
        print(
            'Signup attempt started with email: ${_emailController.text.trim()}');
      }

      final result = await _authService.registerWithEmailAndPassword(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _receiveNewsletter,
      );

      // Check for direct Firebase auth success even if result is null
      final currentUser = FirebaseAuth.instance.currentUser;

      if (result != null) {
        // Normal success path
        if (kDebugMode) {
          print(
              'Signup successful via normal path. User ID: ${result.user?.uid}');
          print('Email verified: ${result.user?.emailVerified}');
        }
      } else if (currentUser != null) {
        // Workaround path - user is created despite the error
        if (kDebugMode) {
          print(
              'Signup successful via workaround. User ID: ${currentUser.uid}');
        }
      } else {
        // Neither approach worked
        throw Exception(
            "Account creation failed - user not found after signup attempt");
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
            _errorMessage =
                'Account created but failed to log in automatically. Please try logging in.';
            _isLoading = false;
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (kDebugMode) {
        print('Signup FirebaseAuthException:');
        print('  Code: ${e.code}');
        print('  Message: ${e.message}');
      }

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already in use. Please try logging in.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password accounts are not enabled. Please contact support.';
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
        print('Signup unknown error: $e');
      }

      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
    } finally {
      if (kDebugMode && _errorMessage != null) {
        print('Signup failed with error: $_errorMessage');
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
                // Header with close button and login link
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
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Login',
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
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Name field
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Name',
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

                const SizedBox(height: 16),

                // Newsletter checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _receiveNewsletter,
                      onChanged: (value) {
                        setState(() {
                          _receiveNewsletter = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF2E7D32),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'I would like to receive your newsletter and other promotional information.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
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

                // Signup Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
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
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),

                // Already have an account
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Login here',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
