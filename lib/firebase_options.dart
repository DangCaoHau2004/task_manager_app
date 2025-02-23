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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDA4-OPMmRtfB6K0axYTp_1OVeC6bExXKg',
    appId: '1:914171480535:web:a6ed760a7c874e1776e392',
    messagingSenderId: '914171480535',
    projectId: 'task-manager-app-26a8d',
    authDomain: 'task-manager-app-26a8d.firebaseapp.com',
    storageBucket: 'task-manager-app-26a8d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrAnbWEmzzeirC0lVhcarH0aDhkuFOCjE',
    appId: '1:914171480535:android:8a50b997b56a660d76e392',
    messagingSenderId: '914171480535',
    projectId: 'task-manager-app-26a8d',
    storageBucket: 'task-manager-app-26a8d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqfaAyaoSB08LVfEMrI9xWgLuOAKW94bk',
    appId: '1:914171480535:ios:61dee2cd08e83bf076e392',
    messagingSenderId: '914171480535',
    projectId: 'task-manager-app-26a8d',
    storageBucket: 'task-manager-app-26a8d.firebasestorage.app',
    iosBundleId: 'com.example.taskManagerApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqfaAyaoSB08LVfEMrI9xWgLuOAKW94bk',
    appId: '1:914171480535:ios:61dee2cd08e83bf076e392',
    messagingSenderId: '914171480535',
    projectId: 'task-manager-app-26a8d',
    storageBucket: 'task-manager-app-26a8d.firebasestorage.app',
    iosBundleId: 'com.example.taskManagerApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDA4-OPMmRtfB6K0axYTp_1OVeC6bExXKg',
    appId: '1:914171480535:web:4c0b4879f9924b5476e392',
    messagingSenderId: '914171480535',
    projectId: 'task-manager-app-26a8d',
    authDomain: 'task-manager-app-26a8d.firebaseapp.com',
    storageBucket: 'task-manager-app-26a8d.firebasestorage.app',
  );

}