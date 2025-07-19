import 'package:capp/other%20screens/login.dart';
import 'package:capp/other%20screens/signup.dart';
import 'package:capp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset("assets/images/CuberLogo.png", height: 60.h)),
            SizedBox(height: 40.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                minimumSize: Size(double.infinity, 48.h),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: Text("Login", style: TextStyle(fontSize: 18.sp,color: Colors.black),),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                minimumSize: Size(double.infinity, 48.h),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
              child: Text("Signup", style: TextStyle(fontSize: 18.sp,color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
