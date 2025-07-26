import 'package:capp/screens/catere/additem.dart';
import 'package:capp/screens/catere/booking.dart';
import 'package:capp/screens/catere/dashboard.dart';
import 'package:capp/screens/catere/profile.dart';// ✅ Import your booking screen
import 'package:capp/utils/color.dart';
import 'package:flutter/material.dart';

class BottomNavigationCaterer extends StatefulWidget {
  final String userId;

  const BottomNavigationCaterer({super.key, required this.userId});

  @override
  State<BottomNavigationCaterer> createState() => _BottomNavigationCatererState();
}

class _BottomNavigationCatererState extends State<BottomNavigationCaterer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ✅ Booking tab me CatererBookingScreen diya gaya hai
    final screens = [
      CatererDashboard(userId: widget.userId,),
      CatererBookingScreen(catererId: widget.userId), // 👈 Your Booking Screen
      AddItemPage(),
      CatererProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.red,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.grey[200],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
