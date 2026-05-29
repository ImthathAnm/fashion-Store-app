import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CartController extends GetxController {
  final cartItems = <Map<String, dynamic>>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  //ADD TO CART
  void addToCart(Map<String, dynamic> product) {
    int index = cartItems.indexWhere((item) =>
        item['id'] == product['id'] &&
        item['selectedSize'] == product['selectedSize']);

    if (index != -1) {
      cartItems[index]['quantity'] =
          (cartItems[index]['quantity'] ?? 0) + 1;
    } else {
      final newItem = Map<String, dynamic>.from(product);
      newItem['quantity'] = 1;
      newItem['isSelected'] = true;
      cartItems.add(newItem);
    }

    cartItems.refresh();
    saveCart();
  }

  //REMOVE ITEM
  void removeItem(int index) {
    cartItems.removeAt(index);
    cartItems.refresh();
    saveCart();
  }

  //INCREMENT
  void incrementQty(int index) {
    cartItems[index]['quantity'] =
        (cartItems[index]['quantity'] ?? 0) + 1;

    cartItems.refresh();
    saveCart();
  }

  //DECREMENT
  void decrementQty(int index) {
    int qty = cartItems[index]['quantity'] ?? 1;

    if (qty > 1) {
      cartItems[index]['quantity'] = qty - 1;
    } else {
      cartItems.removeAt(index);
    }

    cartItems.refresh();
    saveCart();
  }

  //SELECT / UNSELECT
  void toggleSelection(int index) {
    cartItems[index]['isSelected'] =
        !(cartItems[index]['isSelected'] ?? true);

    cartItems.refresh();
    saveCart();
  }

  //TOTAL
  double get selectedTotal {
    double total = 0;

    for (var item in cartItems) {
      if (item['isSelected'] == true) {
        final price =
            double.tryParse(item['price'].toString()) ?? 0;
        final qty = item['quantity'] ?? 1;

        total += price * qty;
      }
    }

    return total;
  }

  //SELECTED ITEMS
  List<Map<String, dynamic>> get selectedItems {
    return cartItems
        .where((item) => item['isSelected'] == true)
        .toList();
  }

  //SAVE CART
  Future<void> saveCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await _firestore
          .collection('cart')
          .doc(user.uid)
          .set({
        'items': cartItems.toList(),
      });
    } catch (e) {
      debugPrint("Error saving cart: $e");
    }
  }

  //LOAD CART
  Future<void> loadCart() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await _firestore
          .collection('cart')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null && data['items'] != null) {
          cartItems.value =
              List<Map<String, dynamic>>.from(data['items']);
        }
      }
    } catch (e) {
      debugPrint("Error loading cart: $e");
    }
  }

  //PLACE ORDER
  Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required String name,
    required String address,
    required String phone,
    required String payment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    double total = 0;

    for (var item in items) {
      final price =
          double.tryParse(item['price'].toString()) ?? 0;
      final qty = item['quantity'] ?? 1;

      total += price * qty;
    }

    try {
      await _firestore.collection('orders').add({
        'items': items,
        'total': total,
        'name': name,
        'address': address,
        'phone': phone,
        'paymentMethod': payment,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      //Remove selected items
      cartItems.removeWhere(
          (item) => item['isSelected'] == true);

      cartItems.refresh();
      await saveCart();
    } catch (e) {
      debugPrint("Error placing order: $e");
    }
  }
}