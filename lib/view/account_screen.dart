import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_app/utils/app_textstyles.dart';
import 'package:e_commerce_app/view/signin_screen.dart';
import 'package:e_commerce_app/controllers/navigation_controller.dart';
import 'package:e_commerce_app/view/order_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:e_commerce_app/view/edit_profile_screen.dart';
import 'package:e_commerce_app/view/shipping_address_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = 'User';
  String userEmail = '';
  String? profileImageUrl;

  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  //LOAD USER DETAILS
  Future<void> _loadUserDetails() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;

        setState(() {
          userName = data['name'] ?? 'User';
          userEmail = data['email'] ?? currentUser.email ?? '';
          profileImageUrl = data['profileImage'];
        });
      }
    } catch (e) {
      Get.snackbar('Error!', 'Failed to load profile!');
    } finally {
      setState(() => isLoading = false);
    }
  }

  //IMAGE OPTIONS
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            if (profileImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Remove Photo"),
                onTap: () {
                  Get.back();
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  //PICK IMAGE
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);

    if (file == null) return;

    await _uploadImage(File(file.path));
  }

  //UPLOAD IMAGE
  Future<void> _uploadImage(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isUploading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}.jpg');

      await ref.putFile(file);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {'profileImage': url},
        SetOptions(merge: true),
      );

      setState(() => profileImageUrl = url);

      Get.snackbar("Success!", "Profile updated!");
    } catch (e) {
      Get.snackbar("Error!", "Upload failed!");
    } finally {
      setState(() => isUploading = false);
    }
  }

  //REMOVE PHOTO
  Future<void> _removePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImage': null});

      try {
        await FirebaseStorage.instance
            .ref('profile_images/${user.uid}.jpg')
            .delete();
      } catch (_) {}

      setState(() => profileImageUrl = null);

      Get.snackbar("Removed!", "Photo removed!");
    } catch (e) {
      Get.snackbar("Error!", "Failed to remove!");
    }
  }

  //LOGOUT
  Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastUserName', userName);
    await prefs.setString('lastUserEmail', userEmail);

    final navigationController = Get.find<NavigationController>();
    navigationController.changeIndex(0);

    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const SigninScreen());
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
        iconTheme:
            IconThemeData(color: theme.textTheme.bodyLarge!.color),
        title: Text(
          'My Profile',
          style: AppTextstyles.withColor(
            AppTextstyles.h2,
            theme.textTheme.bodyLarge!.color!,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      //PROFILE IMAGE
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundImage: profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : const AssetImage('assets/avatar.jpg')
                                    as ImageProvider,
                          ),

                          if (isUploading)
                            const Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageOptions,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        userName,
                        style: AppTextstyles.withColor(
                          AppTextstyles.h3,
                          theme.textTheme.bodyLarge!.color!,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        userEmail,
                        style: AppTextstyles.withColor(
                          AppTextstyles.bodySmall,
                          isDark
                              ? Colors.grey[400]!
                              : Colors.grey[600]!,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _profileItem(
                        context,
                        Icons.edit,
                        'Edit Profile',
                        onTap: () {
                          Get.to(() => const EditProfileScreen())
                          ?.then((value) {
                            if (value == true) {
                              _loadUserDetails();
                            }
                          });
                        },
                      ),

                      //My Orders navigation
                      _profileItem(
                        context,
                        Icons.shopping_bag,
                        'My Orders',
                        onTap: () {
                          Get.to(() => const OrderHistoryScreen());
                        },
                      ),

                      _profileItem(
                        context,
                        Icons.location_on,
                        'Shipping Address',
                        onTap: () {
                          Get.to(() => const ShippingAddressScreen())
                              ?.then((value) {
                            if (value == true) {
                              _loadUserDetails();
                            }
                          });
                        },
                      ),
                      _profileItem(context, Icons.settings, 'Settings'),

                      const SizedBox(height: 24),

                      //LOGOUT BUTTON
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: InkWell(
                          onTap: _logoutUser,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout,
                                    color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  'Log Out',
                                  style: AppTextstyles.withColor(
                                    AppTextstyles.buttonMedium,
                                    Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'NOVA CEYLON v1.0.0',
                        style: AppTextstyles.withColor(
                          AppTextstyles.bodySmall,
                          isDark
                              ? Colors.grey[500]!
                              : Colors.grey[600]!,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  //UPDATED PROFILE ITEM
  Widget _profileItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.primaryColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextstyles.withColor(
                    AppTextstyles.bodyMedium,
                    theme.textTheme.bodyLarge!.color!,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: isDark
                      ? Colors.grey[500]
                      : Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}