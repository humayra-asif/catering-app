import 'package:capp/screens/user/booking.dart';
import 'package:capp/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ProductDetailScreen({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    final description = itemData['description'];
    if (description == null || description.toString().trim().isEmpty) {
      debugPrint('⚠️ No description available for item: ${itemData['foodName']}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Detail"),
        backgroundColor: AppColors.red,
       // automaticallyImplyLeading: false, // ✅ hides the back button
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                itemData['imageUrl'] ?? '',
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black26,
                  height: 200.h,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(itemData['foodName'] ?? '',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 6.h),
            Text(itemData['catererName'] ?? '',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
            Text(itemData['price'] ?? '',
                style: TextStyle(fontSize: 14.sp, color: Colors.black54)),
            SizedBox(height: 12.h),
            Text("Description", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 6.h),
            Text(
              description ?? "No description available.",
              style: TextStyle(fontSize: 14.sp),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(itemData: itemData),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text("Book Now", style: TextStyle(fontSize: 16.sp, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
