import 'package:e_commerce_app/controllers/auth_controller.dart';
import 'package:e_commerce_app/controllers/cart_controller.dart';
import 'package:e_commerce_app/controllers/navigation_controller.dart';
import 'package:e_commerce_app/controllers/theme_controller.dart';
import 'package:e_commerce_app/utils/app_themes.dart';
import 'package:e_commerce_app/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Local storage
  await GetStorage.init();

  //Controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(NavigationController());

  //CartController with Firestore auto load
  Get.put(CartController()); // onInit() already loads cart

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController =
        Get.find<ThemeController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nova Ceylon',

      //Theme
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,

      //smooth transition
      defaultTransition: Transition.fade,

      //start screen
      home: SplashScreen(),
    );
  }
}