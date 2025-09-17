import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static Future<void> saveToken(String? token) async {
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', token);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  static Future<void> saveUserId(int? userId) async {
    if (userId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
    }
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class UserPreferences {
  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  static Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user.name ?? '');
    await prefs.setString('user_email', user.email ?? '');
    await prefs.setString('user_gender', user.jenisKelamin ?? '');
    await prefs.setString('user_photo', user.profilePhoto ?? '');
  }

  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'gender': prefs.getString('user_gender') ?? '',
      'photo': prefs.getString('user_photo') ?? '',
    };
  }

  static Future<void> saveUserImagePath(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image_path', imagePath);
  }

  static Future<String?> getUserImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_image_path');
  }

  static Future<void> saveUserBatch(String batchName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_batch', batchName);
  }

  static Future<String?> getUserBatch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_batch');
  }
}
