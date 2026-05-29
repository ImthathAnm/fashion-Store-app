import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    //USER SAFETY
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Orders")),
        body: const Center(
          child: Text("Please login to view orders"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),

        builder: (context, snapshot) {
          //LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          //ERROR
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error loading orders"),
            );
          }

          //EMPTY
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long, size: 80),
                  SizedBox(height: 10),
                  Text("No orders yet"),
                ],
              ),
            );
          }

          final orders = snapshot.data!.docs;

          //SAFE SORT
          orders.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;

            if (aTime == null || bTime == null) return 0;

            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order =
                  orders[index].data() as Map<String, dynamic>;

              final total =
                  double.tryParse(order['total'].toString()) ?? 0;

              final payment = order['paymentMethod'] ?? '';
              final status = order['status'] ?? 'Pending';

              final items = order['items'] as List<dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //HEADER
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order #${orders[index].id.substring(0, 6)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Rs. ${total.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text("Payment: $payment"),

                    const SizedBox(height: 10),

                    //ITEMS LIST
                    ...items.map((item) {
                      final name = item['name'] ?? '';
                      final qty = item['quantity'] ?? 1;
                      final size = item['selectedSize'];

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                size != null
                                    ? "$name (Size: $size)"
                                    : name,
                              ),
                            ),
                            Text("x$qty"),
                          ],
                        ),
                      );
                    }),

                    const Divider(),

                    //STATUS
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Status"),
                        Text(
                          status,
                          style: TextStyle(
                            color: status == "Pending"
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}