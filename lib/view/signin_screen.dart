import 'package:e_commerce_app/controllers/navigation_controller.dart';
import 'package:e_commerce_app/utils/app_textstyles.dart';
import 'package:e_commerce_app/view/main_screen.dart';
import 'package:e_commerce_app/view/signup_screen.dart';
import 'package:e_commerce_app/view/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String welcomeText = 'Welcome to Nova Ceylon!';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLastUserName();
  }

  Future<void> _loadLastUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUserName = prefs.getString('lastUserName');

    if (lastUserName != null && lastUserName.isNotEmpty) {
      setState(() {
        welcomeText = 'Welcome back, $lastUserName';
      });
    } else {
      setState(() {
        welcomeText = 'Welcome to Nova Ceylon!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Text(
                welcomeText,
                style: AppTextstyles.withColor(
                  AppTextstyles.h1,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Unlock Your Shopping Experience!',
                style: AppTextstyles.withColor(
                  AppTextstyles.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),

              const SizedBox(height: 40),

              CustomTextfield(
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),

              const SizedBox(height: 16),

              CustomTextfield(
                label: 'Password',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                controller: _passwordController,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: AppTextstyles.withColor(
                      AppTextstyles.buttonMedium,
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: AppTextstyles.withColor(
                            AppTextstyles.buttonMedium,
                            Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an Account?",
                    style: AppTextstyles.withColor(
                      AppTextstyles.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const SignUpScreen()),
                    child: Text(
                      'Sign Up',
                      style: AppTextstyles.withColor(
                        AppTextstyles.buttonMedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Alert!", "Please Enter Your Email!");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Alert!", "Please Enter Your Email Correctly!");
      return;
    }

    if (password.isEmpty) {
      Get.snackbar("Alert!", "Please Enter Your Password!");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      String userName = email.split('@')[0];

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        userName = data['name'] ?? email.split('@')[0];
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastUserName', userName);
      await prefs.setString('lastUserEmail', email);

      // Reset bottom navigation to Home tab
      final navigationController = Get.find<NavigationController>();
      navigationController.changeIndex(0);

      Get.snackbar("Success!", "Login Successful!");

      Get.offAll(() => const MainScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed! Please try again!";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email!";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password!";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address!";
      } else if (e.code == 'invalid-credential') {
        errorMessage = "Invalid email or password!";
      }

      Get.snackbar("Login Failed!", errorMessage);
    } catch (e) {
      debugPrint("Signin Error: $e");
      Get.snackbar("Alert!", "Something went wrong! Please try again!");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
