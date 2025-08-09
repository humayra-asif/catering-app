import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerOrdersScreen extends StatefulWidget {
  @override
  _CustomerOrdersScreenState createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'cancel': true,
        'cancelReason': 'Order has been canceled by customer',
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Order cancelled'),
        backgroundColor: AppColors.red,
      ));
    } catch (e) {
      print('Error cancelling order: $e');
    }
  }

  Future<String> getCatererName(String catererId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('companyInfo')
          .doc(catererId)
          .get();
      if (snapshot.exists) {
        return snapshot.data()?['companyName'] ?? 'Unknown Caterer';
      } else {
        return 'Unknown Caterer';
      }
    } catch (e) {
      print('Error fetching caterer name: $e');
      return 'Unknown Caterer';
    }
  }

  // Helper function to parse date whether it's Timestamp or String
  DateTime? parseDate(dynamic dateValue) {
    try {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String && dateValue.isNotEmpty) {
        return DateTime.parse(dateValue);
      }
    } catch (e) {
      print("Error parsing date: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders')),
      body: currentUserId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: currentUserId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong!'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final orders = snapshot.data?.docs ?? [];

                if (orders.isEmpty) {
                  return Center(child: Text("No orders found."));
                }

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final order = doc.data() as Map<String, dynamic>;
                    final orderId = doc.id;

                    final foodName = order['foodName'] ?? 'Unknown Food';
                    final catererId = order['catererId'] ?? '';
                    final createdAt = parseDate(order['createdAt']);
                    final selectedDate = parseDate(order['selectedDate']);
                    final total = order['total'] ?? '';
                    final isCancelled = order['cancel'] == true;

                    return FutureBuilder<String>(
                      future: getCatererName(catererId),
                      builder: (context, catererSnapshot) {
                        final catererName =
                            catererSnapshot.data ?? 'Loading...';

                        return Card(
                          color: isCancelled
                              ? AppColors2.grey
                              : Colors.white,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.red),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Dish: $foodName",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("Caterer: $catererName"),
                                if (selectedDate != null)
                                  Text(
                                      "Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}"),
                                if (createdAt != null)
                                  Text(
                                      "Order Date: ${DateFormat('dd/MM/yyyy hh:mm a').format(createdAt)}"),
                                Text("Total: $total",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 10),
                                if (isCancelled)
                                  Text("Order Cancelled",
                                      style: TextStyle(
                                          color: AppColors.red,
                                          fontWeight: FontWeight.bold))
                                else
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.red,
                                      ),
                                      onPressed: () => cancelOrder(orderId),
                                      child: Text("Cancel Order",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
