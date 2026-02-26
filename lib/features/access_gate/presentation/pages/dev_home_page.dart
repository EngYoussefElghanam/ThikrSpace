import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DevHomePage extends StatelessWidget {
  const DevHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Home')),
      body: Center(
          child: Column(
        children: [
          Text('Developer home ready'),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final db = FirebaseFirestore.instance;
              final myUid = FirebaseAuth.instance.currentUser?.uid;

              if (myUid == null) {
                debugPrint('TEST FAILED: You must be logged in first.');
                return;
              }

              debugPrint('--- FIRING SECURITY TORTURE TESTS ---');

              // TEST 1: Privilege Escalation (Flags)
              try {
                await db
                    .collection('users')
                    .doc(myUid)
                    .update({'flags.pro': true});
                debugPrint('❌ TEST 1 FAILED: I was able to make myself Pro!');
              } catch (e) {
                debugPrint('✅ TEST 1 PASSED: Blocked from editing flags.');
              }

              // TEST 2: Cross-Tenant Breach (Other UID)
              try {
                await db
                    .collection('users')
                    .doc('some_random_hacked_uid_123')
                    .set({'hacked': true});
                debugPrint(
                    '❌ TEST 2 FAILED: I wrote to another user\'s profile!');
              } catch (e) {
                debugPrint(
                    '✅ TEST 2 PASSED: Blocked from touching other UIDs.');
              }

              // TEST 3: Invalid Settings Bounds
              try {
                await db.collection('users').doc(myUid).update({
                  'settings': {
                    'dailyNew': 9999, // Way over the max of 50
                    'dailyMaxReviews': 500
                  }
                });
                debugPrint('❌ TEST 3 FAILED: I bypassed the dailyNew limit!');
              } catch (e) {
                debugPrint(
                    '✅ TEST 3 PASSED: Blocked from invalid settings bounds.');
              }

              debugPrint('--- TESTS COMPLETE ---');
            },
            child: const Text('RUN SECURITY TESTS',
                style: TextStyle(color: Colors.white)),
          )
        ],
      )),
    );
  }
}
