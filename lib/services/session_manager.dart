import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utente.dart';

class SessionManager {
  static const _keyUsername = 'logged_in_username';
  static const _keyUserData = 'logged_in_user_data';

  Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  Future<void> saveUser(Utente utente) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, utente.username);
    await prefs.setString(_keyUserData, jsonEncode(utente.toJson()));
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<Utente?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUserData);
    if (json == null) return null;
    try {
      return Utente.fromJson(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final username = await getUsername();
    return username != null && username.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyUserData);
  }
}
