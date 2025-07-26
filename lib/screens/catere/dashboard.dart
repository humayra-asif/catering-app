import 'package:capp/other%20screens/login.dart';
import 'package:capp/screens/catere/additem.dart';
import 'package:capp/screens/catere/bottom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capp/utils/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CatererDashboard extends StatelessWidget {
  final String userId;

  const CatererDashboard({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> getMyItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("catererItems")
        .where("userId", isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caterer Dashboard"),
        backgroundColor: AppColors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getMyItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text("No items found"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(item['foodName'] ?? ''),
                  subtitle: Text(item['price'] ?? ''),
                  trailing: Text(item['description'] ?? ''),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.red,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddItemPage()),
          );
        },
      ),
     /// bottomNavigationBar: BottomNavigationCaterer(userId: userId),
    );
  }
}
