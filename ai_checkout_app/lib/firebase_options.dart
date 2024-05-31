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
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAogLh_NnZBELfoZx8VndSHG0PWZH28Tfo',
    appId: '1:894898978277:web:4b59eceb4cc32c1e79c30c',
    messagingSenderId: '894898978277',
    projectId: 'final-year-project-4a9e1',
    authDomain: 'final-year-project-4a9e1.firebaseapp.com',
    storageBucket: 'final-year-project-4a9e1.appspot.com',
    measurementId: 'G-EEFEY8SRHD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfH3haQXr06yGE7u8SHFvOY6DdxYJhZuk',
    appId: '1:894898978277:android:5bd772f36302e00679c30c',
    messagingSenderId: '894898978277',
    projectId: 'final-year-project-4a9e1',
    storageBucket: 'final-year-project-4a9e1.appspot.com',
  );

}