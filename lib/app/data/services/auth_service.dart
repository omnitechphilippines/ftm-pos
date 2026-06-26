import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_pages.dart';
import '../models/auth_model.dart';
import '../providers/auth_provider.dart';

class AuthService extends GetxService {
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  final AuthProvider _authProvider = AuthProvider();
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
      final Map<String, dynamic>? response = await _authProvider.login(userName, password);

      if (response != null) {
        await _prefs.setString('status', 'success');
        await _prefs.setString('userName', response['user_name'] ?? '');
        await _prefs.setString('user', '${response['first_name']} ${response['last_name']}');

        state.value = state.value.copyWith(status: AuthStatus.success, token: response['status'], userName: response['user_name'], user: '${response['first_name']} ${response['last_name']}');
      } else {
        state.value = state.value.copyWith(status: AuthStatus.failure, error: null);
      }
    } catch (e) {
      state.value = state.value.copyWith(status: AuthStatus.failure, error: 'Invalid Credentials');
    }
  }

  Future<void> resetPassword(String userName, String password) async {
    try {
      await _authProvider.resetPassword(userName, password);
      Get.snackbar('Success', 'Password reset successfully');
    } catch (e) {
      Get.snackbar('Error', 'Reset password failed: $e');
    }
  }

  Future<void> signUp(String userName, String password, String firstName, String lastName) async {
    state.value = state.value.copyWith(status: AuthStatus.loading);

    try {
      final Map<String, dynamic>? response = await _authProvider.signUp(userName, password, firstName, lastName);

      if (response != null) {
        await _prefs.setString('status', 'success');
        await _prefs.setString('userName', response['user_name'] ?? '');
        await _prefs.setString('user', '$firstName $lastName');

        state.value = state.value.copyWith(status: AuthStatus.success, token: response['status'], userName: response['user_name'], user: '$firstName $lastName');
      } else {
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
