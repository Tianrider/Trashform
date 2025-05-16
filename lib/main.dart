import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trashform/screens/onboarding_screen.dart';
import 'package:trashform/screens/auth/login_screen.dart';
import 'package:trashform/screens/auth/signup_screen.dart';
import 'package:trashform/screens/main_screen.dart';
import 'package:trashform/screens/scan_screen.dart';
import 'package:trashform/services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable debug logging for Firebase Auth
  FirebaseAuth.instance.setLanguageCode("en");
  if (kDebugMode) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('Firebase Auth: User is currently signed out');
      } else {
        print('Firebase Auth: User is signed in with ID: ${user.uid}');
        print('Firebase Auth: Email: ${user.email}');
        print('Firebase Auth: Email verified: ${user.emailVerified}');
      }
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trashform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/scan': (context) => const ScanScreen(),
      },
    );
  }
}

// This wrapper checks the authentication state and navigates accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    final User? user = FirebaseAuth.instance.currentUser;

    if (kDebugMode) {
      print("AuthWrapper - Current user: ${user?.uid ?? 'No user logged in'}");
    }

    // If we have a logged-in user, show the main app screen
    // Otherwise, show the onboarding page first
    if (user != null) {
      return const MainScreen();
    } else {
      return const HomePage(); // Still showing HomePage for now but will navigate to onboarding via button
    }
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    if (kDebugMode) {
      print("HomePage - User is ${isLoggedIn ? 'logged in' : 'not logged in'}");
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFEDF7ED),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/trashform_logo.png',
                    height: 150,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            constraints: const BoxConstraints(),
                            child: Image.asset(
                              'assets/images/scanning_illustration.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // Text content
                      const SizedBox(height: 10),
                      const Text(
                        'Trashform helps you scan,\nupcycle, and share',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '- because waste shouldn\'t go to waste.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),

                      // Button - different behavior based on login state
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLoggedIn) {
                              // If logged in, proceed to the scanning feature
                              Navigator.pushNamed(context, '/scan');
                              if (kDebugMode) {
                                print(
                                    "Starting scanning functionality (user logged in)");
                              }
                            } else {
                              // If not logged in, go to onboarding
                              Navigator.pushNamed(context, '/onboarding');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            isLoggedIn ? 'Start Scanning' : 'Get Started',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // If logged in, show logout option
                      if (isLoggedIn)
                        TextButton(
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                // Refresh the page to update the UI
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const AuthWrapper()));
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print("Error signing out: $e");
                              }
                            }
                          },
                          child: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
