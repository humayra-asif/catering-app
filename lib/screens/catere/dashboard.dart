import 'package:capp/other%20screens/login.dart';
import 'package:capp/screens/catere/additem.dart';
import 'package:capp/screens/catere/bottom.dart';
import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CatererDashboard extends StatefulWidget {
  final String userId;

  const CatererDashboard({super.key, required this.userId});

  @override
  State<CatererDashboard> createState() => _CatererDashboardState();
}

class _CatererDashboardState extends State<CatererDashboard> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  Future<void> getUserName() async {
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      setState(() {
        userName = userDoc['name'] ?? '';
      });
    }
  }

  Future<List<Map<String, dynamic>>> getMyItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("catererItems")
        .where("userId", isEqualTo: widget.userId)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
                title: Image.asset('assets/images/CuberLogo.png', height: 40),

                backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:AppColors2.grey,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              child: const Text("Logout",style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner
          Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Text(
              "Welcome, $userName 👋",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Your Items",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getMyItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching data"));
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return const Center(child: Text("No items found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['image'] ??
                                  'https://via.placeholder.com/70',
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['foodName'] ?? 'Abc food',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'] ?? 'No description',
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      //bottomNavigationBar: BottomNavigationCaterer(userId: widget.userId),
    );
  }
}
