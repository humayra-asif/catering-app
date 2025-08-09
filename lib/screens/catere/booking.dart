import 'package:capp/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatererBookingScreen extends StatefulWidget {
  final String catererId;

  const CatererBookingScreen({super.key, required this.catererId});

  @override
  State<CatererBookingScreen> createState() => _CatererBookingScreenState();
}

class _CatererBookingScreenState extends State<CatererBookingScreen> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where("catererId", isEqualTo: widget.catererId)
          .orderBy("selectedDate", descending: true)
          .get();

      final List<Map<String, dynamic>> loaded = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        String customerName = "Unknown";
        if (data['userId'] != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userId'])
              .get();
          customerName = userDoc.data()?['name'] ?? "Unknown";
        }

        loaded.add({
          ...data,
          'docId': doc.id,
          'customerName': customerName,
        });
      }

      setState(() {
        bookings = loaded;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      setState(() => isLoading = false);
    }
  }

  String formatDate(dynamic dateValue) {
    try {
      DateTime date;
      if (dateValue is Timestamp) {
        date = dateValue.toDate();
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else {
        return "Invalid date";
      }
      return DateFormat('dd-MMM-yyyy').format(date);
    } catch (e) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Bookings"),
        backgroundColor: AppColors.red,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text("No bookings found"))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final customerName =
                        booking['customerName'] ?? 'Customer Name';
                    final foodName = booking['foodName'] ?? '';
                    final rawDate = booking['selectedDate'];
                    final formattedDate = formatDate(rawDate);
                    final price = booking['price']?.toString() ?? '';
                    final total = booking['total']?.toString() ?? '';
                    final isCancelled = booking['cancel'] == true;
                    final cancelReason =
                        booking['cancelReason'] ?? 'Order has been canceled by customer';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors2.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('1 $foodName',
                                        style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text('date: $formattedDate',
                                        style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Price: ${price.startsWith("Rs") ? price : "Rs. $price"}',
                                          style:
                                              const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Total: $total',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isCancelled) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        cancelReason,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 14,
                              height: 100,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: isCancelled
                                    ? Colors.red
                                    : AppColors.red,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
