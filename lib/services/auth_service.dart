import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class AuthService {
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') != null;
  }

  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    return await DatabaseHelper.instance.getUserById(userId);
  }

  static Future<void> saveUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>?> register(
      String username,
      String email,
      String password,
      ) async {
    return await DatabaseHelper.instance.registerUser(username, email, password);
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    return await DatabaseHelper.instance.loginUser(email, password);
  }
}