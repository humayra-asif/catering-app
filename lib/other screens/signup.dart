import 'package:capp/other%20screens/login.dart';
import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _cnic = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _selectedType = 'customer';
  bool _obscure = true;

  Future<void> _signup() async {
    try {
      // Basic field validation
      if (_email.text.isEmpty ||
          _password.text.isEmpty ||
          _name.text.isEmpty ||
          _phone.text.isEmpty ||
          _address.text.isEmpty ||
          _cnic.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields are required")),
        );
        return;
      }

      // Extra validations
      if (!_email.text.contains("@")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid email address")),
        );
        return;
      }
      if (_password.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password must be at least 6 characters")),
        );
        return;
      }

      // Firebase Authentication signup
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      // Store user data in Firestore
      await _firestore.collection("users").doc(userCred.user!.uid).set({
        "email": _email.text.trim(),
        "name": _name.text.trim(),
        "userType": _selectedType,
        "phone": _phone.text.trim(),
        "address": _address.text.trim(),
        "cnic": _cnic.text.trim(),
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Specific Firebase errors
      String message = "";
      if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is not valid.";
      } else if (e.code == 'weak-password') {
        message = "Password is too weak. Use at least 6 characters.";
      } else {
        message = e.message ?? "Signup failed.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print("Signup error: ${e.code} - ${e.message}");
    } catch (e) {
      // Any other error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
      print("Unexpected signup error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
        child: Column(
          children: [
            const Text(
              "Create Account",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
              ],
              decoration: const InputDecoration(
                label: Text("Full Name"),
                hintText: "Ali Khan",
                filled: true,
                fillColor: Color(0xFFF2F2F2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                label: Text("Email"),
                hintText: "abc@gmail.com",
                filled: true,
                fillColor: Color(0xFFF2F2F2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(
                label: Text("Phone Number"),
                hintText: "03XXXXXXXXX",
                filled: true,
                fillColor: Color(0xFFF2F2F2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: const InputDecoration(
                label: Text("Address"),
                hintText: "Address",
                filled: true,
                fillColor: Color(0xFFF2F2F2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cnic,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              decoration: const InputDecoration(
                label: Text("CNIC"),
                hintText: "4210112345678",
                filled: true,
                fillColor: Color(0xFFF2F2F2),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                label: const Text("Password"),
                hintText: "********",
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("I am a: "),
                DropdownButton<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(value: "customer", child: Text("Customer")),
                    DropdownMenuItem(value: "caterer", child: Text("Caterer")),
                  ],
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: _signup,
              child: const Text(
                "Signup",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
