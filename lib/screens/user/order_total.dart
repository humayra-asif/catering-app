import 'package:capp/screens/user/dasboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:capp/utils/color.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String foodName;
  final String total;
  final DateTime selectedDate;
  final String orderId;

  const OrderConfirmationScreen({
    super.key,
    required this.foodName,
    required this.total,
    required this.selectedDate,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.red,
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: const Text("Order Confirmed"),
        backgroundColor: AppColors.red,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: 0.9.sw,
          padding: EdgeInsets.all(16.w),
          margin: EdgeInsets.only(top: 30.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 60.sp),
              SizedBox(height: 10.h),
              Text("Order Confirmed",
                  style: TextStyle(
                      fontSize: 20.sp, fontWeight: FontWeight.bold)),
              Divider(height: 30.h, color: Colors.grey.shade300),
              orderDetailRow("Food Item", foodName),
              SizedBox(height: 10.h),
              orderDetailRow(
                  "Date", DateFormat("dd/MM/yyyy").format(selectedDate)),
              SizedBox(height: 10.h),
              orderDetailRow("Total", total),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                 onPressed: (){
                  Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => UserDashboard(userId: '')),
);

                 },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Back to Home",
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
        Text(value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
