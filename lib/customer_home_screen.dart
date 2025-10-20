// lib/customer_home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nzinga_app/salon_profile_screen.dart'; // Import the profile screen

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Salon', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('salons').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No salons found.'));
          }

          final salonDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: salonDocs.length,
            itemBuilder: (context, index) {
              final salonDoc = salonDocs[index]; // Get the whole document
              final salonData = salonDoc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  // ... (ListTile content remains the same)
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(radius: 30, backgroundColor: Colors.grey[200], child: const Icon(Icons.cut, color: Colors.grey)),
                  title: Text(salonData['name'] ?? 'No Name', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  subtitle: Text(salonData['address'] ?? 'No Address', style: const TextStyle(fontFamily: 'Poppins')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 4),
                      Text((salonData['rating'] ?? 0).toString(), style: const TextStyle(fontFamily: 'Poppins')),
                    ],
                  ),
                  // --- THIS IS THE KEY CHANGE ---
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // Pass the salon's unique document ID to the profile screen
                        builder: (context) => SalonProfileScreen(salonId: salonDoc.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}