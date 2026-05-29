import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final GetStorage _box = GetStorage();

  static const String _key = 'isDarkMode';

  final RxBool _isDarkMode = false.obs;

  //Getter
  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get theme =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _isDarkMode.value = _box.read(_key) ?? false;
  }

  //Toggle theme
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;

    _box.write(_key, _isDarkMode.value);

    Get.changeThemeMode(
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}