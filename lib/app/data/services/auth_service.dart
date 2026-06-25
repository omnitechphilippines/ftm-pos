import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_pages.dart';
import '../models/auth_model.dart';
import '../services/auth_api_service.dart';

class AuthService extends GetxService {
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  final AuthApiService _authApi = AuthApiService();
  final Rx<AuthModel> state = const AuthModel().obs;

  bool get isLoggedIn => _prefs.getString('status') == 'success';

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final String? status = _prefs.getString('status');

    if (status == 'success') {
      state.value = AuthModel(status: AuthStatus.success, userName: _prefs.getString('userName'), user: _prefs.getString('user'));
    }
  }

  Future<void> login(String userName, String password) async {
    state.value = state.value.copyWith(status: AuthStatus.loading);

    try {
      final Map<String, dynamic> response = await _authApi.login(userName, password);

      if (response.isNotEmpty) {
        await _prefs.setString('status', 'success');
        await _prefs.setString('userName', response['user_name'] ?? '');
        await _prefs.setString('user', '${response['first_name']} ${response['last_name']}');

        state.value = state.value.copyWith(status: AuthStatus.success, token: response['status'], userName: response['user_name'], user: '${response['first_name']} ${response['last_name']}');
      } else if (response.isEmpty) {
        state.value = state.value.copyWith(status: AuthStatus.failure, error: null);
      }
    } catch (e) {
      state.value = state.value.copyWith(status: AuthStatus.failure, error: 'Invalid Credentials');
    }
  }

  Future<void> logout() async {
    await _prefs.clear();
    state.value = const AuthModel(status: AuthStatus.initial);
    Get.offAllNamed(Routes.LOGIN);
  }
}
