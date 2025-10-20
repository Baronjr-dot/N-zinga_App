// lib/salon_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nzinga_app/booking_screen.dart';

class SalonProfileScreen extends StatelessWidget {
  // The screen now requires a salonId to be passed to it.
  final String salonId;
  const SalonProfileScreen({super.key, required this.salonId});

  @override
  Widget build(BuildContext context) {
    // We use a FutureBuilder because we only need to fetch the data once when the screen loads.
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('salons').doc(salonId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Salon not found.')));
        }

        // Once data is loaded, get the salon's data
        final salonData = snapshot.data!.data() as Map<String, dynamic>;

        // Define colors
        const Color primaryColor = Color(0xFF4CAF50);
        const Color textColor = Color(0xFF333333);
        // ... (the rest of your UI code is very similar, just using salonData)

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 250.0,
                backgroundColor: Colors.white,
                elevation: 1,
                iconTheme: const IconThemeData(color: textColor),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    salonData['name'] ?? 'Salon',
                    style: const TextStyle(fontFamily: 'Poppins', color: textColor, fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                  background: Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.camera_alt, color: Colors.white, size: 50)),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salonData['name'] ?? 'No Name',
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () { Navigator.push(
      context,
      MaterialPageRoute(
        // Pass the salonId to the booking screen
        builder: (context) => BookingScreen(salonId: salonId),
      ),
    );},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('BOOK NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // You can add back the services and reviews sections here, fetching them from sub-collections if needed.
            ],
          ),
        );
      },
    );
  }
}