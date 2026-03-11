// File generated for Firebase configuration
// To get web configuration:
// 1. Go to Firebase Console > Project Settings > Your apps
// 2. Add a web app if you haven't already
// 3. Copy the web configuration values here

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return android; // Use android config as fallback
      case TargetPlatform.linux:
        return android; // Use android config as fallback
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Add your web app to Firebase Console and update these values
  // Go to: https://console.firebase.google.com/project/voyager-2e50c/settings/general
  // Click "Add app" > Web (</>) > Register app > Copy config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAbaXperNt50xjxzckKcgXNxeFQyaFsji0',
    appId: '1:524480440385:web:YOUR_WEB_APP_ID_HERE', // <-- UPDATE THIS
    messagingSenderId: '524480440385',
    projectId: 'voyager-2e50c',
    authDomain: 'voyager-2e50c.firebaseapp.com',
    storageBucket: 'voyager-2e50c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbaXperNt50xjxzckKcgXNxeFQyaFsji0',
    appId: '1:524480440385:android:8f83d4db0d1a17b8b4bec0',
    messagingSenderId: '524480440385',
    projectId: 'voyager-2e50c',
    storageBucket: 'voyager-2e50c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDS0hYpJlqL4ee25_sMMOLWFnWH9_oKM-Q',
    appId: '1:524480440385:ios:8d38a635e2ccaad4b4bec0',
    messagingSenderId: '524480440385',
    projectId: 'voyager-2e50c',
    storageBucket: 'voyager-2e50c.firebasestorage.app',
    iosBundleId: 'com.example.voyager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDS0hYpJlqL4ee25_sMMOLWFnWH9_oKM-Q',
    appId: '1:524480440385:ios:8d38a635e2ccaad4b4bec0',
    messagingSenderId: '524480440385',
    projectId: 'voyager-2e50c',
    storageBucket: 'voyager-2e50c.firebasestorage.app',
    iosBundleId: 'com.example.voyager',
  );
}
