import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_commerce_app/utils/app_textstyles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      Get.snackbar("Alert!", "User not logged in!");
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
      }
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
      Get.snackbar("Alert!", "Failed to load data!");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Alert!", "User not logged in!");
      return;
    }

    final name = nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar("Alert!", "Name cannot be empty!");
      return;
    }

    if (mounted) {
      setState(() => isSaving = true);
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {'name': name},
        SetOptions(merge: true),
      );

      Get.back(result: true);

      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar(
          "Success!",
          "Profile updated!",
          snackPosition: SnackPosition.TOP,
        );
      });

    } catch (e) {
      debugPrint("SAVE ERROR: $e");
      Get.snackbar("Alert!", "Update failed!");
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveProfile,
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              "Save",
                              style: AppTextstyles.buttonMedium,
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}