import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_textstyles.dart';
import 'product_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  Stream<QuerySnapshot> _productsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('isFeatured', isEqualTo: false)
        .snapshots();
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Rs. 0';

    if (price is int || price is double) {
      return 'Rs. ${price.toString()}';
    }

    return 'Rs. $price';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge!.color),
        title: Text(
          'New Arrivals!',
          style: AppTextstyles.withColor(
            AppTextstyles.h2,
            theme.textTheme.bodyLarge!.color!,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Failed to load products. Please try again.',
                  textAlign: TextAlign.center,
                  style: AppTextstyles.withColor(
                    AppTextstyles.bodyMedium,
                    Colors.red,
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products available',
                style: AppTextstyles.withColor(
                  AppTextstyles.bodyMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            );
          }

          final products = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.70,
              ),
              itemBuilder: (context, index) {
                final doc = products[index];
                final data = doc.data() as Map<String, dynamic>;

                //IMPORTANT FIX HERE
                final product = {
                  'id': doc.id,
                  'name': data['name'] ?? 'Product Name',
                  'price': data['price'] ?? 0,
                  'priceText': _formatPrice(data['price']),
                  'imageUrl': data['imageUrl'] ?? '',
                  'category': data['category'] ?? '',
                  'description': data['description'] ?? '',
                  'isFeatured': data['isFeatured'] ?? false,

                  //ADD THESE 2 LINES
                  'hasSize': data['hasSize'] ?? false,
                  'sizes': data['sizes'] ?? [],
                };

                return _ProductCard(
                  product: product,
                  isDark: isDark,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Product Card
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isDark;

  const _ProductCard({
    required this.product,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailsScreen(product: product));
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: product['imageUrl'] != null &&
                      product['imageUrl'].toString().isNotEmpty
                  ? Image.network(
                      product['imageUrl'],
                      height: 145,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder(context);
                      },
                    )
                  : _imagePlaceholder(context),
            ),

            const SizedBox(height: 10),

            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                product['name'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextstyles.withColor(
                  AppTextstyles.bodyMedium,
                  theme.textTheme.bodyLarge!.color!,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                product['priceText'] ?? '',
                style: AppTextstyles.withColor(
                  AppTextstyles.buttonMedium,
                  theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 145,
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.primaryColor,
        size: 38,
      ),
    );
  }
}