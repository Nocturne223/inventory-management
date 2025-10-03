# PowerShell helper to run FlutterFire CLI (documentation only)
# Run this from the project root (replace <your-firebase-project> as needed)
# Ensure dart pub global activate flutterfire_cli has been run at least once.

Write-Host "Running FlutterFire configure..."
flutterfire configure

Write-Host "If successful, lib/firebase_options.dart will be created."
