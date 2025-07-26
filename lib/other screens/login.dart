import 'package:capp/other%20screens/forgrtpassword.dart';
import 'package:capp/screens/catere/bottom.dart';
import 'package:capp/screens/catere/company_info.dart';
import 'package:capp/screens/user/dasboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _loginUser() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final userDoc = await _firestore.collection("users").doc(userCred.user!.uid).get();

      if (!userDoc.exists || !userDoc.data()!.containsKey("userType")) {
        throw "User type not found";
      }

      final userType = userDoc["userType"];

      if (userType == "caterer") {
        final companyInfoDoc = await _firestore
            .collection("companyInfo")
            .doc(userCred.user!.uid)
            .get();

        if (companyInfoDoc.exists) {
          // Already filled company info, go to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BottomNavigationCaterer(userId: userCred.user!.uid),
            ),
          );
        } else {
          // First-time login → fill company info
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompanyInfoScreen()),
          );
        }
      } else {
        // Regular customer user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserDashboard(userId: userCred.user!.uid),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/CuberLogo.png",height: 50,),
            const SizedBox(height: 30),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ForgetPasswordScreen()),
                  );
                },
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              
              onPressed: _loginUser,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red,minimumSize: const Size(double.infinity, 50)),
              child: const Text("Login",style: TextStyle(color: Colors.white,fontSize: 23,fontWeight:FontWeight.bold ),),
            ),
          ],
        ),
      ),
    );
  }
}
