# Generating firebase_options.dart (FlutterFire CLI)

This project uses a small `FirebaseConfig` placeholder. To enable real Firebase integration you should generate `lib/firebase_options.dart` using the FlutterFire CLI and then update `main.dart` to use `DefaultFirebaseOptions`.

Steps (PowerShell / Windows):

1. Install FlutterFire CLI if you don't have it:

   dart pub global activate flutterfire_cli

2. Run the configure command from your project root and follow the interactive prompts:

   flutterfire configure

This will generate `lib/firebase_options.dart` containing `DefaultFirebaseOptions`.

3. After generation you can update `main.dart` to initialize with the generated options:

   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

Notes:

- If you prefer keeping `FirebaseConfig` as a fallback, you can replace `FirebaseConfig.currentPlatform` with
  `DefaultFirebaseOptions.currentPlatform` once the file is generated.
