import 'package:capp/screens/user/booking.dart';
import 'package:capp/screens/user/order_total.dart';
import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const BookingScreen({super.key, required this.itemData});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  int itemPrice = 0;
  int discount = 0;
  int tax = 0;
  int transport = 200;
  int other = 100;
  int total = 0;

  @override
  void initState() {
    super.initState();
    calculateTotal();
  }

  void calculateTotal() {
    final priceString = widget.itemData['price'] ?? 'Rs. 0';
    final priceInt = int.tryParse(priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    setState(() {
      itemPrice = priceInt;
      discount = (priceInt * 0.10).toInt();
      tax = (priceInt * 0.05).toInt();
      total = priceInt - discount + tax + transport + other;
    });
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> confirmBooking() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('orders').add({
      'foodName': widget.itemData['foodName'],
      'imageUrl': widget.itemData['imageUrl'],
      'price': widget.itemData['price'],
      'selectedDate': selectedDate!.toIso8601String(),
      'total': 'Rs. $total',
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          foodName: widget.itemData['foodName'],
          total: 'Rs. $total',
          selectedDate: selectedDate!, itemData: {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Summary'),
        backgroundColor: AppColors.red,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            summaryRow("Price", "Rs. $itemPrice"),
            summaryRow("Discount (10%)", "- Rs. $discount"),
            summaryRow("Tax (5%)", "+ Rs. $tax"),
            summaryRow("Transport", "+ Rs. $transport"),
            summaryRow("Other Charges", "+ Rs. $other"),
            const Divider(thickness: 1),
            summaryRow("Total", "Rs. $total", isBold: true),
            SizedBox(height: 30.h),

            Text("Select Event Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
            SizedBox(height: 10.h),

            InkWell(
              onTap: pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: Colors.grey[700]),
                    SizedBox(width: 10.w),
                    Text(
                      selectedDate == null
                          ? "Select a date"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      style: TextStyle(fontSize: 15.sp),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text("Confirm", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
