import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final GetStorage _storage = GetStorage();

  final RxBool _isFirstTime = true.obs;

  bool get isFirstTime => _isFirstTime.value;

  @override
  void onInit() {
    super.onInit();
    _loadInitialState();
  }

  void _loadInitialState() {
    _isFirstTime.value =
        _storage.read('isFirstTime') ?? true;
  }

  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }
}