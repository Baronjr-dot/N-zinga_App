// lib/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nzinga_app/auth_screen.dart';
import 'package:nzinga_app/customer_home_screen.dart';
import 'package:nzinga_app/dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.active) {
          if (authSnapshot.hasData) {
            // If user is logged in, use our dedicated role checker
            return RoleBasedScreenSelector(userId: authSnapshot.data!.uid);
          } else {
            // If not logged in, show the Auth Screen
            return const AuthScreen();
          }
        }
        // While checking auth state, show a loading spinner
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class RoleBasedScreenSelector extends StatelessWidget {
  final String userId;
  const RoleBasedScreenSelector({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // THIS IS THE CRITICAL FIX
        // If the user document does NOT exist, show the "stuck" screen.
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const AccountSetupErrorScreen();
        }

        if (userSnapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Something went wrong!")));
        }

        final userRole = userSnapshot.data!['role'];

        if (userRole == 'business_owner') {
          return const DashboardScreen();
        } else {
          return const CustomerHomeScreen();
        }
      },
    );
  }
}

// This is a new, dedicated screen for handling the "stuck" scenario
class AccountSetupErrorScreen extends StatelessWidget {
  const AccountSetupErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Setting up your account...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Text(
                'If you are stuck on this screen, it means your user data was not found. Please try logging out and signing up again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: const Text('Logout and Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}