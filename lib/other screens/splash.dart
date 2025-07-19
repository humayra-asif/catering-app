import 'package:capp/other%20screens/choice.dart';
import 'package:capp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChoiceScreen()));
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 200,),
            Center(child: Image.asset("assets/images/CuberLogo.png", height: 80.h)),
            SizedBox(height: 10.h),
            SizedBox(height: 5.h),
            Container(
              color: AppColors.red,
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
              child: Text("Fresh. Fast. Fabulous", style: TextStyle(fontSize: 16.sp, color: Colors.white)),
            ),
            const Spacer(),
            Image.asset("assets/images/dish.png", height: 150.h),
            ///SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
