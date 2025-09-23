import 'dart:convert';

import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/get_forgot_password_models.dart';
import 'package:aplikasi_absen/models/get_reset_password.dart';
import 'package:http/http.dart' as http;

class Forgot {
  // Forgot Password API
  static Future<ForgotPassword?> forgotPassword(String email) async {
    try {
      final url = Uri.parse(ApiEndpoints.forgot);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        return ForgotPassword.fromJson(jsonDecode(response.body));
      } else {
        print("❌ Gagal forgot password. Status: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Error forgot password: $e");
      return null;
    }
  }

  static Future<ResetPasswordResponse?> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        ApiEndpoints.reset,
      ); // Pastikan endpoint ini ada di file endpoint Anda

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp, "password": password}),
      );

      if (response.statusCode == 200) {
        return ResetPasswordResponse.fromJson(jsonDecode(response.body));
      } else {
        print("❌ Gagal reset password. Status: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Error reset password: $e");
      return null;
    }
  }
}
