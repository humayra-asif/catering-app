import 'package:capp/screens/catere/dashboard.dart';
import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen({super.key});
  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _submit() async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('companyInfo').doc(uid).set({
        'companyName': _name.text.trim(),
        'companyAddress': _address.text.trim(),
        'companyPhone': _phone.text.trim(),
        'uid': uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Company info submitted")),
      );

      // ✅ Redirect to Caterer Dashboard (as per your flow)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CatererDashboardScreen(userId: '',)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting: $e")),
      );
    }
  }

  Widget _buildField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        label: Text(label),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: AppColors.red,
              child: const Text("Company Info",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20),
            _buildField(_name, "Company Name"),
            const SizedBox(height: 12),
            _buildField(_address, "Company Address"),
            const SizedBox(height: 12),
            _buildField(_phone, "Company Phone"),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _submit,
              child: const Text("Submit",
                  style: TextStyle(fontSize: 18, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
