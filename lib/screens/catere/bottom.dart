import 'package:capp/screens/catere/dashboard.dart';
import 'package:capp/screens/catere/profile.dart';
import 'package:flutter/material.dart';


class BottomNavigationCaterer extends StatefulWidget {
  @override
  _BottomNavigationCatererState createState() => _BottomNavigationCatererState();
}

class _BottomNavigationCatererState extends State<BottomNavigationCaterer> {
  int currentIndex = 0;

  final List<Widget> screens = [
    ///CatererDashboardScreen()
    CatererDashboardScreen(userId: '',),
    //CatererOrdersScreen(),
    ////CatererAddItemScreen(),
   // CatererMessagesScreen(),
    CatererProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.red, // use myapp.red if needed
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
