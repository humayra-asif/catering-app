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
      print("Fetching bookings for catererId: ${widget.catererId}");

      final snapshot = await FirebaseFirestore.instance
          .collection("orders")
          .where("catererId", isEqualTo: widget.catererId)
          .orderBy("selectedDate", descending: true)
          .get();

      final List<Map<String, dynamic>> loaded = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        print("Fetched order with catererId: ${data['catererId']}");

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

  String formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      print("Invalid date format: $isoString");
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Orders")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? const Center(child: Text("No bookings found"))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: booking['imageUrl'] != null && booking['imageUrl'] != ""
                            ? Image.network(
                                booking['imageUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.fastfood, size: 40),
                        title: Text(booking['foodName'] ?? "No name"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Customer: ${booking['customerName']}"),
                            Text("Date: ${formatDate(booking['selectedDate'])}"),
                            Text("Price: ${booking['price']}"),
                            Text("Total: ${booking['total']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
