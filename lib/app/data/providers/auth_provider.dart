import 'package:bcrypt/bcrypt.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends GetConnect {
  final SupabaseClient _supabase = Supabase.instance.client;
  @override
  void onInit() {
    // httpClient.baseUrl = 'YOUR-API-URL';
  }

  Future<Map<String, dynamic>?> login(String userName, String password) async {
    final PostgrestMap? response = await _supabase.from('users_master').select('user_name, password, first_name, last_name').eq('user_name', userName).maybeSingle();
    if (response != null) {
      final bool checkPassword = BCrypt.checkpw(password, response['password']);
      if (checkPassword) {
        return response;
      }
    }
    return null;
  }

  Future<void> resetPassword(String userName, String password) async {
    final PostgrestList response = await _supabase.from('users_master').select().eq('user_name', userName);
    if (response.isNotEmpty) {
      final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      await _supabase.from('users_master').update(<dynamic, dynamic>{'password': hashedPassword}).eq('user_name', userName);
    }
  }

  Future<Map<String, dynamic>?> signUp(String userName, String password, String firstName, String lastName) async {
    final PostgrestList response = await _supabase.from('users_master').select().eq('user_name', userName);
    if (response.isNotEmpty) {
      return null;
    }
    final String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
    await _supabase.from('users_master').insert(<dynamic, dynamic>{'user_name': userName, 'password': hashedPassword, 'first_name': firstName, 'last_name': lastName});
    return <String, dynamic>{'user_name': userName, 'first_name': firstName, 'last_name': lastName};
  }
}
