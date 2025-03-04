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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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
        return windows;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtGTR14Iblz70YSSX8uEfLUsxhixJUKcE',
    appId: '1:455527675737:android:68a26c21819bbba0fdbe48',
    messagingSenderId: '455527675737',
    projectId: 'expenses-app-c5470',
    storageBucket: 'expenses-app-c5470.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDr43jIoiMtAVZryPlpm6b0sbPQ6ZOI5_k',
    appId: '1:455527675737:web:4224ff238d665648fdbe48',
    messagingSenderId: '455527675737',
    projectId: 'expenses-app-c5470',
    authDomain: 'expenses-app-c5470.firebaseapp.com',
    storageBucket: 'expenses-app-c5470.appspot.com',
    measurementId: 'G-DP1BWM84BJ',
  );

}