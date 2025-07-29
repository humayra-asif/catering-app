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
  final companyCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      final companyDoc = await FirebaseFirestore.instance
          .collection('company')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        nameCtrl.text = data['name'] ?? '';
        phoneCtrl.text = data['phone'] ?? '';
        addressCtrl.text = data['address'] ?? '';
        emailCtrl.text = data['email'] ?? '';
      }

      if (companyDoc.exists) {
        companyCtrl.text = companyDoc.data()!['companyName'] ?? '';
      }

      setState(() {});
    } catch (e) {
      print("Profile load error: $e");
    }
  }

  Future<void> saveProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': nameCtrl.text,
        'phone': phoneCtrl.text,
        'address': addressCtrl.text,
      });
      print("Profile updated!");
    } catch (e) {
      print("Profile update error: $e");
    }
  }

  Widget customTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool showIcon = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              border: InputBorder.none,
              suffixIcon: showIcon
                  ? Icon(Icons.edit, size: 18, color: Colors.grey[700])
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ListView(
          children: [
            Center(
              child: Text(
                "Cuber",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            customTextField(label: "Name", controller: nameCtrl),
            customTextField(
              label: "Company Name",
              controller: companyCtrl,
              readOnly: true,
              showIcon: false,
            ),
            customTextField(
              label: "Email",
              controller: emailCtrl,
              readOnly: true,
              showIcon: false,
            ),
            customTextField(label: "Phone no", controller: phoneCtrl),
            customTextField(label: "Address", controller: addressCtrl),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Save", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
