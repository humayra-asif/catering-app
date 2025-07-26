import 'package:capp/screens/user/order_total.dart';
import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const BookingScreen({Key? key, required this.itemData}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  int quantity = 1;

  final formatPKR = NumberFormat.currency(locale: 'ur_PK', symbol: 'Rs. ');

  int get pricePerUnit {
    String priceString = widget.itemData['price'].toString();
    return int.tryParse(priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  int get discount => (pricePerUnit * 0.10).toInt();
  int get transport => 150;
  int get tax => (pricePerUnit * 0.05).toInt();
  int get other => 90;

  int get total => pricePerUnit - discount + tax + transport + other;

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'foodName': widget.itemData['foodName'],
      'imageUrl': widget.itemData['imageUrl'],
      'price': widget.itemData['price'],
      'selectedDate': selectedDate!.toIso8601String(),
      'total': formatPKR.format(total),
      'catererId': widget.itemData['userId'],
      'userId': currentUser.uid,
      'quantity': quantity,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(
          foodName: widget.itemData['foodName'],
          total: formatPKR.format(total),
          selectedDate: selectedDate!,
          orderId: orderRef.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        title: const Text("Booking"),
        backgroundColor:AppColors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors2.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  rowText(widget.itemData['foodName'], formatPKR.format(pricePerUnit)),
                  const SizedBox(height: 8),
                  rowText("Discount", "10% (-${formatPKR.format(discount)})"),
                  const SizedBox(height: 4),
                  rowText("Transport Charges", formatPKR.format(transport)),
                  const SizedBox(height: 4),
                  rowText("Tax", "5% (+${formatPKR.format(tax)})"),
                  const SizedBox(height: 4),
                  rowText("Other Charges", formatPKR.format(other)),
                  const Divider(height: 20),
                  rowText("Total", formatPKR.format(total), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? "Select the Date"
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors2.grey,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rowText(String left, String right, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(right, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
