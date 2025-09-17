import 'dart:convert';
import 'dart:io';

import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/get_register_models.dart';
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // Fungsi untuk login
  static Future<GetRegisterUser> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(ApiEndpoints.login); // Sesuaikan endpoint

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
    int? batchId,
    int? trainingId,
    String? gender,
    File? image,
  }) async {
    final url = Uri.parse(ApiEndpoints.register);
    var request = http.MultipartRequest('POST', url);
    final Map<String, dynamic> requestBody = {
      "name": name,
      "email": email,
      "password": password,
      "batch_id": batchId,
      "training_id": trainingId,
      "jenis_kelamin": gender,
      "profile_photo": image,
    };

    // Remove null values
    requestBody.removeWhere((key, value) => value == null);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final registerUser = getRegisterUserFromJson(response.body);
      await PreferenceHandler.saveToken(registerUser.data?.token);
      await PreferenceHandler.saveUserId(registerUser.data?.user?.id);
      return registerUser;
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Register gagal");
    }
  }

  static Future<GetUser> getUserProfile() async {
    // Ambil token yang sudah tersimpan
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan, silahkan login ulang.");
    }

    final url = Uri.parse(ApiEndpoints.profile);

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        // Kirim token untuk otorisasi
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      // Jika berhasil, parse data dan kembalikan
      return getUserFromJson(response.body);
    } else {
      // Jika gagal, tampilkan pesan error
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mengambil data profil");
    }
  }
}
