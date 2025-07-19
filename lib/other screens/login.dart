import 'package:capp/screens/catere/dashboard.dart';
import 'package:capp/screens/catere/company_info.dart';

import 'package:capp/screens/user/dasboard.dart';

import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      final userDoc = await _firestore.collection("users").doc(userCred.user!.uid).get();
      if (!userDoc.exists || !userDoc.data()!.containsKey("userType")) {
        throw "User type not found";
      }

      final userType = userDoc["userType"] as String;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );

      if (userType == "caterer") {
        // If user hasn't added company info yet, go to CompanyInfo, else go to CatererDashboard
        final compDoc = await _firestore.collection("companyInfo").doc(userCred.user!.uid).get();
        if (!compDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompanyInfoScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CatererDashboardScreen(userId: userCred.user!.uid)),
          );
        }
      } else {
        Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => UserDashboard(userId: userCred.user!.uid)),
  (route) => false,
);

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset("assets/images/CuberLogo.png", height: 80.h)),
            const SizedBox(height: 40),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                label: Text("Email"), hintText: "abc@gmail.com",
                filled: true, fillColor: Color(0xFFF2F2F2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                label: const Text("Password"), hintText: "password",
                filled: true, fillColor: const Color(0xFFF2F2F2),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red, minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _login,
              child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
