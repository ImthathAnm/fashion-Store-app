import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_app/view/shopping_screen.dart';
import 'package:e_commerce_app/view/checkout_screen.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_textstyles.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? selectedSize;

  @override
  void initState() {
    super.initState();

    final bool hasSize = widget.product['hasSize'] ?? false;
    final List<dynamic> productSizes = widget.product['sizes'] ?? [];

    if (hasSize && productSizes.isNotEmpty) {
      selectedSize = productSizes.first.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final CartController cartController = Get.find<CartController>();

    final String productName = widget.product['name'] ?? 'Product Name';
    final String productImage = widget.product['imageUrl'] ?? '';
    final String productPrice =
        widget.product['priceText'] ?? 'Rs. ${widget.product['price'] ?? 0}';
    final String productDescription = widget.product['description'] ??
        'Crafted with premium materials for comfort, style, and everyday elegance.';
    final String productCategory = widget.product['category'] ?? 'Fashion';

    final bool hasSize = widget.product['hasSize'] ?? false;
    final List<dynamic> productSizes = widget.product['sizes'] ?? [];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: theme.textTheme.bodyLarge!.color,
        ),
        title: Text(
          'Product Details',
          style: AppTextstyles.withColor(
            AppTextstyles.h2,
            theme.textTheme.bodyLarge!.color!,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: productImage.isNotEmpty
                  ? Image.network(
                      productImage,
                      height: 260,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder(context);
                      },
                    )
                  : _imagePlaceholder(context),
            ),

            const SizedBox(height: 20),

            // Product Name
            Text(
              productName,
              style: AppTextstyles.withColor(
                AppTextstyles.h3,
                theme.textTheme.bodyLarge!.color!,
              ),
            ),

            const SizedBox(height: 8),

            // Category
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                productCategory,
                style: AppTextstyles.withColor(
                  AppTextstyles.bodySmall,
                  theme.primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Price
            Text(
              productPrice,
              style: AppTextstyles.withColor(
                AppTextstyles.buttonMedium,
                theme.primaryColor,
              ),
            ),

            const SizedBox(height: 20),

            // Size Selection - only for products with size
            if (hasSize && productSizes.isNotEmpty) ...[
              Text(
                'Select Size',
                style: AppTextstyles.withColor(
                  AppTextstyles.h3,
                  theme.textTheme.bodyLarge!.color!,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: productSizes.map((sizeValue) {
                  final String size = sizeValue.toString();
                  final bool isSelected = selectedSize == size;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSize = size;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 48,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor
                            : theme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? theme.primaryColor
                              : isDark
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: AppTextstyles.withColor(
                            AppTextstyles.buttonMedium,
                            isSelected
                                ? Colors.white
                                : theme.textTheme.bodyLarge!.color!,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),
            ],

            // Description Title
            Text(
              'Description',
              style: AppTextstyles.withColor(
                AppTextstyles.h3,
                theme.textTheme.bodyLarge!.color!,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              productDescription,
              style: AppTextstyles.withColor(
                AppTextstyles.bodySmall,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),

            const SizedBox(height: 32),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  final Map<String, dynamic> productWithOptions = {
                    ...widget.product,
                    'selectedSize': hasSize ? selectedSize : null,
                    'quantity': 1,
                  };

                  cartController.addToCart(productWithOptions);

                  Get.snackbar(
                    'Added to Cart!',
                    hasSize
                        ? '$productName - Size $selectedSize added successfully!'
                        : '$productName added successfully!',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: theme.primaryColor,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    duration: const Duration(seconds: 2),
                  );

                  Future.delayed(const Duration(milliseconds: 1200), () {
                    Get.off(() => const ShoppingScreen());
                  });
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                label: Text(
                  'Add to Cart',
                  style: AppTextstyles.withColor(
                    AppTextstyles.buttonMedium,
                    Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Buy Now Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  final Map<String, dynamic> productWithOptions = {
                    ...widget.product,
                    'selectedSize': hasSize ? selectedSize : null,
                    'quantity': 1,
                  };

                  Get.to(
                    () => CheckoutScreen(),
                    arguments: {
                      'buyNowProduct': productWithOptions,
                    },
                  );
                },
                icon: Icon(
                  Icons.flash_on_outlined,
                  color: theme.primaryColor,
                ),
                label: Text(
                  'Buy Now',
                  style: AppTextstyles.withColor(
                    AppTextstyles.buttonMedium,
                    theme.primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.primaryColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 260,
      width: double.infinity,
      color: theme.cardColor,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.primaryColor,
        size: 50,
      ),
    );
  }
}