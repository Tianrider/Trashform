// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // This is a simple placeholder. In a real app, you would use the Firebase CLI
    // to generate this file with actual configuration values from your Firebase project.
    return const FirebaseOptions(
      apiKey: 'your-api-key',
      appId: 'your-app-id',
      messagingSenderId: 'your-messaging-sender-id',
      projectId: 'trashform-72d5f',
      storageBucket: 'trashform-72d5f.appspot.com',
      authDomain: 'trashform-72d5f.firebaseapp.com',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBHhFU0bCsTMmFMWkaB9jTP4VCEQZssL5U',
    appId: '1:898243505007:web:045b623bc188fd5df5569a',
    messagingSenderId: '898243505007',
    projectId: 'trashform-72d5f',
    authDomain: 'trashform-72d5f.firebaseapp.com',
    storageBucket: 'trashform-72d5f.firebasestorage.app',
    measurementId: 'G-NY1Q69KXZ5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5hiW3Q5hSAB1RVDq7B2hDbcGxArdHqOA',
    appId: '1:898243505007:android:7b18cd99c006eb2af5569a',
    messagingSenderId: '898243505007',
    projectId: 'trashform-72d5f',
    storageBucket: 'trashform-72d5f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWOBFkPbnlPg4UfL8maCY1C6UGWavXSJU',
    appId: '1:898243505007:ios:a9a5e6b13b4868a1f5569a',
    messagingSenderId: '898243505007',
    projectId: 'trashform-72d5f',
    storageBucket: 'trashform-72d5f.firebasestorage.app',
    iosBundleId: 'com.example.trashform',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWOBFkPbnlPg4UfL8maCY1C6UGWavXSJU',
    appId: '1:898243505007:ios:a9a5e6b13b4868a1f5569a',
    messagingSenderId: '898243505007',
    projectId: 'trashform-72d5f',
    storageBucket: 'trashform-72d5f.firebasestorage.app',
    iosBundleId: 'com.example.trashform',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBHhFU0bCsTMmFMWkaB9jTP4VCEQZssL5U',
    appId: '1:898243505007:web:50a0f87692be8ac8f5569a',
    messagingSenderId: '898243505007',
    projectId: 'trashform-72d5f',
    authDomain: 'trashform-72d5f.firebaseapp.com',
    storageBucket: 'trashform-72d5f.firebasestorage.app',
    measurementId: 'G-CP3SQC49ED',
  );
}
