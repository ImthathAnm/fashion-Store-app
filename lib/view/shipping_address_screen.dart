import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() =>
      _ShippingAddressScreenState();
}

class _ShippingAddressScreenState
    extends State<ShippingAddressScreen> {
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  //LOAD DATA
  Future<void> _loadAddress() async {
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
        addressController.text = data['address'] ?? '';
        phoneController.text = data['phone'] ?? '';
      }
    } catch (e) {
      Get.snackbar("Alert!", "Failed to load address!");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  //SAVE DATA
  Future<void> _saveAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar("Alert!", "User not logged in!");
      return;
    }

    final address = addressController.text.trim();
    final phone = phoneController.text.trim();

    if (address.isEmpty) {
      Get.snackbar("Alert!", "Address cannot be empty!");
      return;
    }

    if (phone.isEmpty || phone.length < 8) {
      Get.snackbar("Alert!", "Enter valid phone number!");
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
        {
          'address': address,
          'phone': phone,
        },
        SetOptions(merge: true),
      );

      Get.back(result: true);

      Future.delayed(const Duration(milliseconds: 100), () {
        Get.snackbar("Success!", "Address updated!");
      });

    } catch (e) {
      Get.snackbar("Alert1", "Failed to save address!");
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Shipping Address"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: addressController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Enter your address",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Enter phone number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveAddress,
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Save Address"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}