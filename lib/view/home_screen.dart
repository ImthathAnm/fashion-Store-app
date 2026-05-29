import 'package:e_commerce_app/view/shopping_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../utils/app_textstyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _marqueeController;
  late Animation<double> _marqueeAnimation;

  Stream<QuerySnapshot> _featuredProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('isFeatured', isEqualTo: true)
        .limit(5)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();

    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _marqueeAnimation = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _marqueeController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    super.dispose();
  }

  Widget _movingWelcomeText(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.25)),
      ),

      
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: _marqueeAnimation,
              builder: (context, child) {
                final double moveDistance = constraints.maxWidth + 750;

                return Transform.translate(
                  offset: Offset(_marqueeAnimation.value * moveDistance, 0),
                  child: child,
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 750,
                  child: Center(
                    child: Text(
                      'Welcome to Nova Ceylon!  Now Cash on Delivery available anywhere in Sri Lanka',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: AppTextstyles.withColor(
                        AppTextstyles.buttonMedium,
                        theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Icon(
          Icons.search_outlined,
          color: theme.textTheme.bodyLarge!.color,
        ),
        iconTheme: IconThemeData(color: theme.textTheme.bodyLarge!.color),
        title: Text(
          'Nova Ceylon',
          style: AppTextstyles.withColor(
            AppTextstyles.h1,
            theme.textTheme.bodyLarge!.color!,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.asset(
                      'assets/sale.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Season',
                            style: AppTextstyles.withColor(
                              AppTextstyles.bodySmall,
                              Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Modern Fashion for Everyday',
                            style: AppTextstyles.withColor(
                              AppTextstyles.h2,
                              Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Categories Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Categories',
                style: AppTextstyles.withColor(
                  AppTextstyles.h3,
                  theme.textTheme.bodyLarge!.color!,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Categories List
            SizedBox(
              height: 125,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _CategoryItem(title: 'Men', icon: Icons.boy_outlined),
                  _CategoryItem(title: 'Kids', icon: Icons.child_care),
                  _CategoryItem(title: 'Women', icon: Icons.woman_2_outlined),
                  _CategoryItem(title: 'Accessories', icon: Icons.watch),
                  _CategoryItem(
                    title: 'Footwear',
                    icon: Icons.store_mall_directory_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Moving Welcome Text
            _movingWelcomeText(context),

            const SizedBox(height: 24),

            // Featured Products Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Products',
                    style: AppTextstyles.withColor(
                      AppTextstyles.h3,
                      theme.textTheme.bodyLarge!.color!,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Firestore Featured Products - Responsive Grid
            StreamBuilder<QuerySnapshot>(
              stream: _featuredProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 190,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Failed to load featured products',
                      style: AppTextstyles.withColor(
                        AppTextstyles.bodyMedium,
                        Colors.red,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'No featured products available',
                      style: AppTextstyles.withColor(
                        AppTextstyles.bodyMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                  );
                }

                final products = snapshot.data!.docs;
                final screenWidth = MediaQuery.of(context).size.width;

                // Featured products only:
                // Phone = 1 column, Laptop/Web = 2 columns
                final int crossAxisCount = screenWidth >= 700 ? 2 : 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: screenWidth >= 700 ? 2.6 : 1.9,
                    ),
                    itemBuilder: (context, index) {
                      final productData =
                          products[index].data() as Map<String, dynamic>;

                      final productName = productData['name'] ?? 'Product Name';
                      final productImage = productData['imageUrl'] ?? '';

                      return _ProductPreviewCard(
                        title: productName,
                        imageUrl: productImage,
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Shop Now Button
            Center(
              child: SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const ShoppingScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Shop Now',
                    style: AppTextstyles.withColor(
                      AppTextstyles.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Category item
class _CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CategoryItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 95,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.cardColor,
            child: Icon(icon, color: theme.primaryColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextstyles.withColor(
              AppTextstyles.bodySmall,
              theme.textTheme.bodyLarge!.color!,
            ),
          ),
        ],
      ),
    );
  }
}

// Product Preview Card from Firestore
class _ProductPreviewCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const _ProductPreviewCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Positioned.fill(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _imagePlaceholder(context);
                    },
                  )
                : _imagePlaceholder(context),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            color: Colors.black.withValues(alpha: 0.5),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextstyles.withColor(
                AppTextstyles.bodyMedium,
                Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.cardColor,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: theme.primaryColor,
      ),
    );
  }
}
