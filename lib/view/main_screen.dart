import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import 'shopping_screen.dart';
import 'card_screen.dart';
import 'account_screen.dart';
import 'widgets/custom_bottom_navbar.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Obx(
        () => IndexedStack(
          index: navigationController.currentIndex.value,
          children: const [
            HomeScreen(),
            ShoppingScreen(),
            CardScreen(),
            AccountScreen(),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNavbar(),
    );
  }
}