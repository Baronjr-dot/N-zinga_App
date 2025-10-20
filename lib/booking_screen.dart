// lib/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  final String salonId;
  const BookingScreen({super.key, required this.salonId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // --- STATE ---
  String? _selectedService = 'Gent\'s Cut';
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isLoading = false; // To show a loading indicator on the button

  // --- LOGIC ---
  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'salonId': widget.salonId,
        'userId': user.uid,
        'service': _selectedService,
        'date': Timestamp.fromDate(_selectedDate),
        'time': _selectedTime,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Booking Confirmed!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            content: Text('Your appointment for $_selectedService at $_selectedTime has been successfully requested.', style: const TextStyle(fontFamily: 'Poppins')),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back from booking screen
                  Navigator.of(context).pop(); // Go back from profile to home
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4CAF50);
    const Color textColor = Color(0xFF333333);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Select Service'),
            const SizedBox(height: 10),
            _buildServiceItem('Gent\'s Cut (30 min) - K80'),
            _buildServiceItem('Fade & Wash (45 min) - K120'),
            _buildServiceItem('Hot Shave (20 min) - K60'),
            const SizedBox(height: 30),
            _buildSectionTitle('2. Select Date'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Text(
                '${_selectedDate.toLocal()}'.split(' ')[0],
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('3. Select Time Slot'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildTimeSlot('9:00 AM'),
                _buildTimeSlot('10:00 AM'),
                _buildTimeSlot('11:00 AM'),
                _buildTimeSlot('1:30 PM'),
                _buildTimeSlot('2:00 PM'),
                _buildTimeSlot('3:00 PM'),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          onPressed: (_selectedService != null && _selectedTime != null && !_isLoading) ? _confirmBooking : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : const Text('CONFIRM BOOKING', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
    );
  }

  Widget _buildServiceItem(String serviceName) {
    final bool isSelected = _selectedService == serviceName.split(' ')[0];
    return RadioListTile<String>(
      title: Text(serviceName, style: const TextStyle(fontFamily: 'Poppins')),
      value: serviceName.split(' ')[0],
      groupValue: _selectedService,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedService = value;
          });
        }
      },
      activeColor: const Color(0xFF4CAF50),
    );
  }

  Widget _buildTimeSlot(String time) {
    final bool isSelected = _selectedTime == time;
    return ChoiceChip(
      label: Text(time),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF4CAF50),
      labelStyle: TextStyle(
        fontFamily: 'Poppins',
        color: isSelected ? Colors.white : Colors.black,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}