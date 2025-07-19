import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CatererProfileScreen extends StatefulWidget {
  @override
  State<CatererProfileScreen> createState() => _CatererProfileScreenState();
}

class _CatererProfileScreenState extends State<CatererProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      nameController.text = doc['name'] ?? '';
      emailController.text = doc['email'] ?? '';
      phoneController.text = doc['phone'] ?? '';
      addressController.text = doc['address'] ?? '';
    });
  }

  void saveProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated')));
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Change route accordingly
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Caterer Profile'), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('Name', nameController),
              buildTextField('Email (Read Only)', emailController, readOnly: true),
              buildTextField('Phone', phoneController),
              buildTextField('Address', addressController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Save Profile'),
              ),
              TextButton(
                onPressed: logout,
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
