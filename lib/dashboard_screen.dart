// lib/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _salonId;
  bool _isLoading = true;
  String _salonOwnerName = "Owner";

  @override
  void initState() {
    super.initState();
    _fetchSalonData();
  }

  Future<void> _fetchSalonData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _salonOwnerName = userDoc.data()?['username'] ?? "Owner";
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('salons')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _salonId = querySnapshot.docs.first.id;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NEW LOGIC METHOD ---
  void _updateBookingStatus(String bookingId, String newStatus) {
    FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF4A90E2);
    const Color textColor = Color(0xFF333333);
    const Color successColor = Color(0xFF4CAF50);
    const Color warningColor = Color(0xFFF5A623);
    const Color dangerColor = Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(icon: const Icon(Icons.menu, color: textColor), onPressed: () {}),
        title: const Text('Dashboard', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: textColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: textColor),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $_salonOwnerName! 👋',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Here\'s your summary for today:',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // Summary cards would go here
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Upcoming Appointments', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: textColor)),
                      TextButton(onPressed: () {}, child: const Text('View Calendar', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: primaryBlue))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _salonId == null
                      ? const Card(child: ListTile(title: Text("You don't have a salon configured.")))
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('bookings')
                              .where('salonId', isEqualTo: _salonId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Card(child: ListTile(title: Text("No upcoming appointments.")));
                            }
                            final bookingDocs = snapshot.data!.docs;
                            return Card(
                              elevation: 1,
                              margin: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: bookingDocs.map<Widget>((doc) {
                                  final bookingData = doc.data() as Map<String, dynamic>;
                                  return _buildAppointmentItem(
                                    context: context,
                                    bookingId: doc.id, // Pass the document ID
                                    time: bookingData['time'] ?? 'N/A',
                                    service: bookingData['service'] ?? 'Unknown',
                                    status: bookingData['status'] ?? 'Unknown',
                                    statusColor: (bookingData['status'] ?? '') == 'Pending' ? warningColor : ((bookingData['status'] ?? '') == 'Confirmed' ? successColor : dangerColor),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentItem({
    required BuildContext context,
    required String bookingId,
    required String time,
    required String service,
    required String status,
    required Color statusColor,
  }) {
    return ListTile(
      title: Text(time, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
      subtitle: Text(service, style: const TextStyle(fontFamily: 'Poppins')),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 12)),
      ),
      // --- MAKE THE ITEM TAPPABLE ---
      onTap: () {
        // Only show the dialog for pending bookings
        if (status == 'Pending') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Manage Booking'),
              content: const Text('Do you want to confirm or decline this appointment?'),
              actions: [
                TextButton(
                  child: const Text('Decline', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    _updateBookingStatus(bookingId, 'Declined');
                    Navigator.of(ctx).pop();
                  },
                ),
                TextButton(
                  child: const Text('Confirm'),
                  onPressed: () {
                    _updateBookingStatus(bookingId, 'Confirmed');
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}