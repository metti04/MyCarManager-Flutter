import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUsername = 'logged_in_username';

  Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<bool> isLoggedIn() async {
    final username = await getUsername();
    return username != null && username.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
  }
}
