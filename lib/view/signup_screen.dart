import 'package:e_commerce_app/utils/app_textstyles.dart';
import 'package:e_commerce_app/view/signin_screen.dart';
import 'package:e_commerce_app/view/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  bool isLoading = false;

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
              // Back button
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Create Account',
                style: AppTextstyles.withColor(
                  AppTextstyles.h1,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Signup to get Started!',
                style: AppTextstyles.withColor(
                  AppTextstyles.bodyLarge,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),

              const SizedBox(height: 40),

              // Name textfield
              CustomTextfield(
                label: 'Name',
                prefixIcon: Icons.person_outlined,
                keyboardType: TextInputType.name,
                controller: _nameController,
              ),

              const SizedBox(height: 16),

              // Email Textfield
              CustomTextfield(
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),

              const SizedBox(height: 16),

              // Password Textfield
              CustomTextfield(
                label: 'Password',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 16),

              // Confirm Password Textfield
              CustomTextfield(
                label: 'Confirm Password',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                controller: _confirmpasswordController,
              ),

              const SizedBox(height: 24),

              // SignUp Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSignUp,
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
                          'SignUp',
                          style: AppTextstyles.withColor(
                            AppTextstyles.buttonMedium,
                            Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Signin text button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an Account?",
                    style: AppTextstyles.withColor(
                      AppTextstyles.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const SigninScreen()),
                    child: Text(
                      'Sign In',
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

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmpasswordController.text.trim();

    if (name.isEmpty) {
      Get.snackbar("Alert!", "Please Enter Your Name!");
      return;
    }

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

    if (password.length < 6) {
      Get.snackbar("Alert!", "Password must be at least 6 characters!");
      return;
    }

    if (confirmPassword.isEmpty) {
      Get.snackbar("Alert!", "Please Confirm Your Password!");
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Alert!", "Password Doesn't Match!");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastUserName', name);
      await prefs.setString('lastUserEmail', email);

      Get.snackbar("Success!", "Account Created Successfully!");

      Get.off(() => const SigninScreen());
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed! Please try again!";

      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered!";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address!";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak!";
      }

      Get.snackbar("Registration Failed!", errorMessage);
    } catch (e) {
      Get.snackbar("Alert!", "Something went wrong! Please try again!");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }
}
