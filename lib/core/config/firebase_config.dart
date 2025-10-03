import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (Platform.isIOS || Platform.isMacOS) {
      return ios;
    } else if (Platform.isAndroid) {
      return android;
    } else if (Platform.isWindows) {
      return windows;
    } else {
      return web; // Default to web for other platforms
    }
  }
    if (Platform.isIOS || Platform.isMacOS) {
      return ios;
    } else if (Platform.isAndroid) {
      return android;
    } else if (Platform.isWindows) {
      return windows;
    } else {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for this platform.',
      );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'mit-inventory-system',
    authDomain: 'mit-inventory-system.firebaseapp.com',
    storageBucket: 'mit-inventory-system.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'mit-inventory-system',
    storageBucket: 'mit-inventory-system.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'mit-inventory-system',
    storageBucket: 'mit-inventory-system.appspot.com',
    iosBundleId: 'com.mit.inventory.management',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key',
    appId: 'your-windows-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'mit-inventory-system',
    authDomain: 'mit-inventory-system.firebaseapp.com',
    storageBucket: 'mit-inventory-system.appspot.com',
  );
}
*/
