import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String loginUrl =
      'https://securitymindset.ongbantat.io.vn/api/auth/login';

  /// Trả về true nếu đăng nhập đúng, ném Exception nếu sai hoặc lỗi mạng.
  Future<bool> login(String username, String password) async {
    final res = await http
        .post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    )
        .timeout(const Duration(seconds: 15));

    print('login ${res.statusCode}: ${res.body}'); // so với DevTools khi debug

    final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};

    if (res.statusCode == 200 && data['status'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      return true;
    }

    // Sai thì server trả {"status":false}, không kèm message, nên tự viết câu báo lỗi
    throw Exception('Sai tài khoản hoặc mật khẩu');
  }

  Future<bool> isLoggedIn() async =>
      (await SharedPreferences.getInstance()).getBool('isLoggedIn') ?? false;

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
  }
}