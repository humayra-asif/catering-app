import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CatererProfileScreen extends StatefulWidget {
  final String userId;
  const CatererProfileScreen({required this.userId});

  @override
  State<CatererProfileScreen> createState() => _CatererProfileScreenState();
}

class _CatererProfileScreenState extends State<CatererProfileScreen> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String companyName = '';
  String email = '';

  Future<void> loadProfile() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      final companyDoc = await FirebaseFirestore.instance.collection('company').doc(widget.userId).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        nameCtrl.text = data['name'] ?? '';
        phoneCtrl.text = data['phone'] ?? '';
        addressCtrl.text = data['address'] ?? '';
        email = data['email'] ?? '';
      }

      if (companyDoc.exists) {
        companyName = companyDoc.data()!['companyName'] ?? '';
      }
      setState(() {});
    } catch (e) {
      print("Profile load error: $e");
    }
  }

  Future<void> saveProfile() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': nameCtrl.text,
        'phone': phoneCtrl.text,
        'address': addressCtrl.text,
      });
      print("Profile updated!");
    } catch (e) {
      print("Profile update error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: "Address")),
            const SizedBox(height: 12),
            Text("Company Name: $companyName", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Email: $email", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveProfile, child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}
