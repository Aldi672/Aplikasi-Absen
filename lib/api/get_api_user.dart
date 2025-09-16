import 'dart:convert';
import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:aplikasi_absen/screens/pages_akun/get_login_screen.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Fungsi untuk login
  static Future<GetRegisterUser> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/login',
    ); // Sesuaikan endpoint

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: json.encode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final getUser = getRegisterUserFromJson(response.body);

      // Simpan token dan user ID setelah login berhasil
      await PreferenceHandler.saveToken(getUser.data?.token);
      await PreferenceHandler.saveUserId(getUser.data?.user?.id);

      return getUser;
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Login gagal");
    }
  }

  // Fungsi untuk registrasi (sudah ada)
  static Future<GetRegisterUser> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(ApiEndpoints.register);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: json.encode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final registerUser = getRegisterUserFromJson(response.body);

      // Simpan token dan user ID setelah register berhasil
      await PreferenceHandler.saveToken(registerUser.data?.token);
      await PreferenceHandler.saveUserId(registerUser.data?.user?.id);
      return registerUser;
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }
}
