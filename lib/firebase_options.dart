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
    apiKey: 'AIzaSyCJg_ohEUH5YbWzqqQaHFly8Qw8SP-LzkA',
    appId: '1:1075915739015:web:21e69d41b2f65f8d11cd22',
    messagingSenderId: '1075915739015',
    projectId: 'dosedashvf',
    authDomain: 'dosedashvf.firebaseapp.com',
    storageBucket: 'dosedashvf.appspot.com',
    measurementId: 'G-PTJ1ST4CCY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0jquLDBLHRqn6bisMOaAnfakxutq53HU',
    appId: '1:1075915739015:android:79d6decc62b456d811cd22',
    messagingSenderId: '1075915739015',
    projectId: 'dosedashvf',
    storageBucket: 'dosedashvf.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxT8D_F7ZMbJK89C70R6GjIBKeao6rXoU',
    appId: '1:1075915739015:ios:ac21f4327a548de111cd22',
    messagingSenderId: '1075915739015',
    projectId: 'dosedashvf',
    storageBucket: 'dosedashvf.appspot.com',
    iosBundleId: 'com.example.ddpatient',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCxT8D_F7ZMbJK89C70R6GjIBKeao6rXoU',
    appId: '1:1075915739015:ios:ac21f4327a548de111cd22',
    messagingSenderId: '1075915739015',
    projectId: 'dosedashvf',
    storageBucket: 'dosedashvf.appspot.com',
    iosBundleId: 'com.example.ddpatient',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCJg_ohEUH5YbWzqqQaHFly8Qw8SP-LzkA',
    appId: '1:1075915739015:web:eb623d70cf1e22d511cd22',
    messagingSenderId: '1075915739015',
    projectId: 'dosedashvf',
    authDomain: 'dosedashvf.firebaseapp.com',
    storageBucket: 'dosedashvf.appspot.com',
    measurementId: 'G-96SJHQ9Q2T',
  );

}