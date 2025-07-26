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

  int get pricePerUnit {
    String priceString = widget.itemData['price'].toString();
    return int.tryParse(priceString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  int get total => pricePerUnit * quantity;

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

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      /// ✅ Add order to Firestore WITH userId
      final orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'foodName': widget.itemData['foodName'],
        'imageUrl': widget.itemData['imageUrl'],
        'price': widget.itemData['price'],
        'selectedDate': selectedDate!.toIso8601String(),
        'total': 'Rs. $total',
        'catererId': widget.itemData['userId'], // Caterer UID
        'userId': currentUser.uid, // ✅ Customer UID added here
        'quantity': quantity,
        'createdAt': FieldValue.serverTimestamp(),
      });

      /// ✅ Print customer UID in console
      print("✅ Order placed by UserID: ${currentUser.uid}");
      print("Order ID: ${orderRef.id}");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            foodName: widget.itemData['foodName'],
            total: 'Rs. $total',
            selectedDate: selectedDate!,
            orderId: orderRef.id,
          ),
        ),
      );
    } catch (e) {
      print('❌ Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Now'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(widget.itemData['imageUrl'], height: 200),
            const SizedBox(height: 16),
            Text(
              widget.itemData['foodName'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.itemData['price'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Date:', style: TextStyle(fontSize: 16)),
                TextButton(
                  onPressed: _selectDate,
                  child: Text(
                    selectedDate == null
                        ? 'Choose Date'
                        : DateFormat('yyyy-MM-dd').format(selectedDate!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity:', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: () => setState(() => quantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Total: Rs. $total', style: const TextStyle(fontSize: 20)),
            const Spacer(),
            ElevatedButton(
              onPressed: _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
              child: const Text('Confirm Booking', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              Text(
                'Your order for "$foodName"\nhas been placed successfully!',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Order Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('Total Amount: $total', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Text('Order ID:\n$orderId',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
