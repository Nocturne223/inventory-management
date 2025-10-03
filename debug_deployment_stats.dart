import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  print('🔍 Debugging Deployment Stats...\n');

  // Get all deployments
  final deploymentsSnapshot = await firestore.collection('deployments').get();

  print('📊 Total deployments found: ${deploymentsSnapshot.docs.length}\n');

  final now = DateTime.now();
  print('📅 Current time: $now\n');

  int activeCount = 0;
  int overdueCount = 0;

  for (final doc in deploymentsSnapshot.docs) {
    final data = doc.data();
    final status = data['status']?.toString() ?? 'unknown';
    final itemName = data['itemName'] ?? 'Unknown Item';
    final expectedReturnDate = data['expectedReturnDate'];

    print('📦 Deployment: $itemName');
    print('   Status: $status');
    print(
        '   Expected Return: $expectedReturnDate (${expectedReturnDate.runtimeType})');

    if (status.toLowerCase() == 'active' ||
        status.toLowerCase() == 'deployed') {
      activeCount++;
      print('   ✅ Counted as ACTIVE');

      if (expectedReturnDate != null) {
        DateTime? expectedReturn;
        if (expectedReturnDate is Timestamp) {
          expectedReturn = expectedReturnDate.toDate();
        } else if (expectedReturnDate is String) {
          expectedReturn = DateTime.tryParse(expectedReturnDate);
        }

        if (expectedReturn != null) {
          print('   📅 Parsed date: $expectedReturn');
          if (expectedReturn.isBefore(now)) {
            overdueCount++;
            print('   ⚠️  OVERDUE!');
          } else {
            final daysUntilDue = expectedReturn.difference(now).inDays;
            print('   ✅ Due in $daysUntilDue days');
          }
        } else {
          print('   ❌ Could not parse expected return date');
        }
      } else {
        print('   ℹ️  No expected return date');
      }
    } else {
      print('   ℹ️  Status not active: $status');
    }

    print('');
  }

  print('📊 FINAL STATS:');
  print('   Active: $activeCount');
  print('   Overdue: $overdueCount');
}
