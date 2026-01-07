import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../app/routes/app_pages.dart';
import '../models/auth_model.dart';
import '../services/auth_api_service.dart';

class AuthService extends GetxService {
  final GetStorage _box = GetStorage('auth');
  final AuthApiService _authApi = AuthApiService();
  final Rx<AuthModel> state = const AuthModel().obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    if (_box.hasData('status') && _box.read('status') == 'success') {
      state.value = AuthModel(status: AuthStatus.success, userName: _box.read('userName'), user: _box.read('user'));
    }
  }

  Future<void> login(String userName, String password) async {
    state.value = state.value.copyWith(status: AuthStatus.loading);

    try {
      final Map<String, dynamic> response = await _authApi.login(userName, password);

      if (response.isNotEmpty) {
        await _box.write('status', 'success');
        await _box.write('userName', response['user_name']);
        await _box.write('user', '${response['first_name']} ${response['last_name']}');

        state.value = state.value.copyWith(status: AuthStatus.success, token: response['status'], userName: response['user_name'], user: '${response['first_name']} ${response['last_name']}');
      } else if (response.isEmpty) {
        state.value = state.value.copyWith(status: AuthStatus.failure, error: null);
      }
    } catch (e) {
      state.value = state.value.copyWith(status: AuthStatus.failure, error: 'Invalid Credentials');
    }
  }

  Future<void> logout() async {
    await _box.erase();
    state.value = const AuthModel(status: AuthStatus.initial);
    Get.offAllNamed(Routes.LOGIN);
  }
}
