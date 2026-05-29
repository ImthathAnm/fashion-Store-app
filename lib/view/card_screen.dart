import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_textstyles.dart';
import 'checkout_screen.dart';

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Cart',
          style: AppTextstyles.withColor(
            AppTextstyles.h2,
            theme.textTheme.bodyLarge!.color!,
          ),
        ),
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return const Center(child: Text('Your cart is empty!'));
        }

        return Column(
          children: [
            //LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartController.cartItems[index];

                  return _cartItem(
                    theme: theme,
                    item: item,
                    index: index,
                  );
                },
              ),
            ),

            //SELECTED TOTAL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Selected Total:', style: AppTextstyles.h3),
                  Text(
                    'Rs. ${cartController.selectedTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            //CHECKOUT BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final selectedItems =
                        cartController.selectedItems;

                    if (selectedItems.isEmpty) {
                      Get.snackbar(
                        "Alert!",
                        "Select at least one item!",
                      );
                      return;
                    }

                    Get.to(
                      () => CheckoutScreen(),
                      arguments: {'items': selectedItems},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed to Checkout',
                    style: AppTextstyles.withColor(
                      AppTextstyles.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  //CART ITEM
  Widget _cartItem({
    required ThemeData theme,
    required Map<String, dynamic> item,
    required int index,
  }) {
    final controller = Get.find<CartController>();

    final String name = item['name'] ?? '';
    final String price =
        item['priceText'] ?? 'Rs. ${item['price'] ?? 0}';
    final String image = item['imageUrl'] ?? '';
    final String? size = item['selectedSize'];
    final int qty = item['quantity'] ?? 1;
    final bool isSelected = item['isSelected'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          //CHECKBOX
          Checkbox(
            value: isSelected,
            activeColor: theme.primaryColor,
            onChanged: (_) {
              controller.toggleSelection(index);
            },
          ),

          //IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 80,
                    height: 90,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 90,
                    color: theme.scaffoldBackgroundColor,
                    child: Icon(Icons.image,
                        color: theme.primaryColor),
                  ),
          ),

          const SizedBox(width: 10),

          //DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),

                const SizedBox(height: 6),

                Text(price),

                if (size != null) Text("Size: $size"),

                const SizedBox(height: 6),

                //QTY
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () =>
                          controller.decrementQty(index),
                    ),
                    Text('$qty'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          controller.incrementQty(index),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //DELETE
          IconButton(
            onPressed: () =>
                controller.removeItem(index),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
}