import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CatererDashboardScreen extends StatefulWidget {
  final String userId;

  const CatererDashboardScreen({super.key, required this.userId});

  @override
  State<CatererDashboardScreen> createState() => _CatererDashboardScreenState();
}

class _CatererDashboardScreenState extends State<CatererDashboardScreen> {
  String catererName = '';

  @override
  void initState() {
    super.initState();
    fetchCatererName();
  }

  void fetchCatererName() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    setState(() {
      catererName = doc['name'] ?? 'Caterer';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $catererName!'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('catererItems').limit(8).snapshots(),
        builder: (context, snapshot) {
          ///if (snapshot.hasError) return const Center(child: Text('Error loading items'));
          ///if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final items = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(item['imageUrl'], fit: BoxFit.cover),
                    ),
                    Text(item['catererName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(item['foodName']),
                    Text('Rs. ${item['price']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
