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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKfkSrASykqJOMjof4NS3TWTzQ6dGY-WY',
    appId: '1:563145311512:android:2fda433636d0caa5250a6d',
    messagingSenderId: '563145311512',
    projectId: 'foodsaverapp-8fb2d',
    storageBucket: 'foodsaverapp-8fb2d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDTmA5i6zPbyuUunAb5wa_vxoMi2iIgWa8',
    appId: '1:563145311512:ios:4d24fad710a3cbb4250a6d',
    messagingSenderId: '563145311512',
    projectId: 'foodsaverapp-8fb2d',
    storageBucket: 'foodsaverapp-8fb2d.firebasestorage.app',
    iosBundleId: 'com.example.helloWorld',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCPy7G658gEm5RVHroj8_0H_KAwozhI8sg',
    appId: '1:563145311512:web:f107098490a2ab42250a6d',
    messagingSenderId: '563145311512',
    projectId: 'foodsaverapp-8fb2d',
    authDomain: 'foodsaverapp-8fb2d.firebaseapp.com',
    storageBucket: 'foodsaverapp-8fb2d.firebasestorage.app',
    measurementId: 'G-SSLFMLECE1',
  );

}