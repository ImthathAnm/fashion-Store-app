import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_textstyles.dart';
import 'main_screen.dart';
import 'shipping_address_screen.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final RxString selectedPayment = "COD".obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final CartController cartController = Get.find<CartController>();

    final List<Map<String, dynamic>> items =
        Get.arguments?['items'] ?? cartController.selectedItems;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in!")),
      );
    }

    //CALCULATE TOTAL
    double subtotal = 0;
    for (var item in items) {
      final price =
          double.tryParse(item['price'].toString()) ?? 0;
      final qty = item['quantity'] ?? 1;
      subtotal += price * qty;
    }

    const double shipping = 300;
    final double total = subtotal + shipping;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Checkout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //SHIPPING ADDRESS
            const Text("Shipping Address"),
            const SizedBox(height: 10),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error loading address!");
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>?;

                if (data == null ||
                    (data['address'] ?? '').isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "No address found! Please add address!"),
                      TextButton(
                        onPressed: () {
                          Get.to(() =>
                              const ShippingAddressScreen());
                        },
                        child: const Text("Add Address!"),
                      ),
                    ],
                  );
                }

                return _card(
                  theme,
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Delivery Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.to(() =>
                                  const ShippingAddressScreen());
                            },
                            child: const Text("Change"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text("Name: ${data['name'] ?? ''}"),
                      const SizedBox(height: 8),
                      Text("Address: ${data['address'] ?? ''}"),
                      const SizedBox(height: 8),
                      Text("Phone: ${data['phone'] ?? ''}"),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            //PAYMENT METHOD
            const Text("Payment Method"),
            const SizedBox(height: 10),

            Obx(() => _card(
      theme,
      RadioGroup<String>(
        groupValue: selectedPayment.value,
        onChanged: (value) {
          selectedPayment.value = value!;
        },
        child: Column(
          children: const [
            RadioListTile<String>(
              value: "COD",
              title: Text("Cash on Delivery"),
            ),
            RadioListTile<String>(
              value: "CARD",
              title: Text("Card Payment"),
            ),
          ],
        ),
      ),
    )),


            const SizedBox(height: 24),

            //ORDER ITEMS
            const Text("Order Items"),
            const SizedBox(height: 10),

            ...items.map((item) {
              final qty = item['quantity'] ?? 1;
              final size = item['selectedSize'];
              final price =
                  item['priceText'] ?? 'Rs. ${item['price']}';

              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(item['name']),
                          if (size != null)
                            Text(
                              "Size: $size",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text("x$qty"),
                    const SizedBox(width: 10),
                    Text(price),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            //SUMMARY
            _card(
              theme,
              Column(
                children: [
                  _row("Subtotal",
                      "Rs. ${subtotal.toStringAsFixed(0)}"),
                  _row("Shipping", "Rs. $shipping"),
                  const Divider(),
                  _row(
                    "Total",
                    "Rs. ${total.toStringAsFixed(0)}",
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //PLACE ORDER BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (items.isEmpty) {
                    Get.snackbar(
                        "Alert!", "No items selected!");
                    return;
                  }

                  final user =
                      FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();

                  final data = doc.data() ?? {};

                  //ADDRESS VALIDATION
                  if ((data['address'] ?? '').isEmpty ||
                      (data['phone'] ?? '').isEmpty) {
                    Get.snackbar(
                      "Alert!",
                      "Please complete your address details!",
                    );
                    return;
                  }

                  await cartController.placeOrder(
                    items: items,
                    name: data['name'] ?? '',
                    address: data['address'] ?? '',
                    phone: data['phone'] ?? '',
                    payment: selectedPayment.value,
                  );

                  Get.snackbar(
                    "Order Confirmed!",
                    "Order placed successfully!",
                    backgroundColor: theme.primaryColor,
                    colorText: Colors.white,
                  );

                  Get.offAll(() => const MainScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                ),
                child: Text(
                  "PLACE ORDER",
                  style: AppTextstyles.withColor(
                    AppTextstyles.buttonMedium,
                    Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //CARD UI
  Widget _card(ThemeData theme, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  //ROW UI
  Widget _row(String title, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: TextStyle(
            fontWeight:
                bold ? FontWeight.bold : FontWeight.normal,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}