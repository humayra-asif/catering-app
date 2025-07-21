import 'package:capp/screens/user/dasboard.dart';
import 'package:capp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String foodName;
  final String total;
  final DateTime selectedDate;

  const OrderConfirmationScreen({
    super.key,
    required this.foodName,
    required this.total,
    required this.selectedDate, required Map<String, dynamic> itemData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 30.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(height: 30.h, thickness: 1),
              _infoRow("Caterer Name", foodName),
              SizedBox(height: 8.h),
              _infoRow("Date",
                  "${selectedDate.day}-${_monthName(selectedDate.month)}-${selectedDate.year}"),
              SizedBox(height: 8.h),
              _infoRow("Total", total),
              Divider(height: 30.h, thickness: 1),
              SizedBox(height: 5.h),
              SizedBox(
                width: double.infinity,
                height: 45.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserDashboard(userId: ''), // Replace with real userId if needed
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Back To Home',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
