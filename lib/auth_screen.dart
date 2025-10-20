// lib/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// An enum to define user roles
enum UserRole { customer, businessOwner }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // --- STATE ---
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;
  String _userEmail = '';
  String _userPassword = '';
  String _userName = ''; // New state for the user's name
  UserRole _userRole = UserRole.customer; // New state for the user's role

  // --- LOGIC ---
  void _submitForm() async {
    final auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential;

      if (_isLoginMode) {
        userCredential = await auth.signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
      } else {
        // 1. Create the user in Firebase Auth
        userCredential = await auth.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );

        // 2. Save the user's additional data to Firestore
        await FirebaseFirestore.instance
            .collection('users') // Get the 'users' collection
            .doc(userCredential.user!.uid) // Use the user's unique ID as the document ID
            .set({ // Set the data for this user
              'username': _userName,
              'email': _userEmail,
              'role': _userRole == UserRole.customer ? 'customer' : 'business_owner',
            });
      }
    } on FirebaseAuthException catch (e) {
      // ... error handling dialog remains the same
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Authentication Error'),
          content: Text(e.message ?? 'An unknown error occurred.'),
          actions: [ TextButton(child: const Text('Okay'), onPressed: () => Navigator.of(ctx).pop()) ],
        ),
      );
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    // ... UI code is mostly the same, with a few additions ...
    const Color primaryColor = Color(0xFF4CAF50);

    return Scaffold(
      body: Container(
        // ... gradient background ...
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ... Logo and App Name ...
                  const Icon(Icons.spa, color: Colors.white, size: 60),
                  const SizedBox(height: 10),
                  const Text('N\'zinga', style: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 50),

                  // --- Full Name Field (only in Sign Up mode) ---
                  if (!_isLoginMode)
                    TextFormField(
                      key: const ValueKey('username'),
                      onChanged: (value) => _userName = value,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(hintText: 'Full Name', icon: Icons.person_outline),
                    ),
                  if (!_isLoginMode) const SizedBox(height: 20),

                  TextFormField(
                    key: const ValueKey('email'),
                    onChanged: (value) => _userEmail = value,
                    // ... same as before
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration(hintText: 'Email Address', icon: Icons.email_outlined),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const ValueKey('password'),
                    onChanged: (value) => _userPassword = value,
                    // ... same as before
                     obscureText: true,
                     style: const TextStyle(color: Colors.white),
                     decoration: _buildInputDecoration(hintText: 'Password', icon: Icons.lock_outline),
                  ),
                  const SizedBox(height: 20),

                  // --- Role Selector (only in Sign Up mode) ---
                  if (!_isLoginMode)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('I am a:', style: TextStyle(color: Colors.white70)),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text('Customer'),
                          selected: _userRole == UserRole.customer,
                          onSelected: (selected) => setState(() => _userRole = UserRole.customer),
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(color: _userRole == UserRole.customer ? Colors.white : Colors.black),
                        ),
                        const SizedBox(width: 10),
                         ChoiceChip(
                          label: const Text('Business'),
                          selected: _userRole == UserRole.businessOwner,
                          onSelected: (selected) => setState(() => _userRole = UserRole.businessOwner),
                          selectedColor: primaryColor,
                          labelStyle: TextStyle(color: _userRole == UserRole.businessOwner ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      // ... same button style
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isLoginMode ? 'LOGIN' : 'SIGN UP', style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isLoginMode ? "Don't have an account? " : "Already have an account? ", style: const TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => setState(() => _isLoginMode = !_isLoginMode),
                        child: Text(_isLoginMode ? 'Sign Up' : 'Login', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  // ... _buildInputDecoration helper method remains the same ...
  InputDecoration _buildInputDecoration({required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}