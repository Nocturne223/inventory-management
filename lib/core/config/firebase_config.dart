
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

/// Minimal FirebaseConfig placeholder used until the FlutterFire CLI generates
/// `lib/firebase_options.dart`. Replace these values with the real options or
/// generate `DefaultFirebaseOptions` and update `main.dart` to use them.
class FirebaseConfig {
	static FirebaseOptions get currentPlatform {
		if (Platform.isIOS || Platform.isMacOS) return ios;
		if (Platform.isAndroid) return android;
		if (Platform.isWindows) return windows;
		return web;
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

