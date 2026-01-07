import 'package:supabase_flutter/supabase_flutter.dart';

class AuthApiService {
  final SupabaseClient supabase = Supabase.instance.client;
  Future<Map<String, dynamic>> login(String userName, String password) async {
    final PostgrestList response = await supabase
        .from('users_master')
        .select()
        .eq('user_name', userName)
        .eq('password', password);
    return response != <dynamic>[] ? response[0] : <String, dynamic>{};
  }
  // static const String baseUrl = 'https://nodered-omnitech.onrender.com/api/v1/login';

  // Future<Map<String, dynamic>> login(String userName, String password) async {
  //   final http.Client client = http.Client();
  //   try {
  //     final http.Response response = await http.post(Uri.parse(baseUrl), headers: <String, String>{'Content-Type': 'application/json'}, body: jsonEncode(<String, String>{'userName': userName, 'password': password}));
  //     if (response.statusCode == 200) {
  //       return response.body != '[]' ? jsonDecode(response.body)[0] : <String, dynamic>{};
  //     } else {
  //       throw Exception('Failed to login: ${response.body}');
  //     }
  //   } finally {
  //     client.close();
  //   }
  // }
}

// final Provider<AuthApiService> authApiServiceProvider = Provider<AuthApiService>((Ref ref) => AuthApiService());

// @riverpod
// AuthApiService authApiService(Ref ref) => AuthApiService();
