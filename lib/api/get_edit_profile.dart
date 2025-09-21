import 'dart:convert';

import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/edit_photo_profile_models.dart';
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:http/http.dart' as http;

import '../models/edit_profile_models.dart'; // sesuaikan path models kamu

class EditProfileApi {
  // GET Edit Profile
  Future<GetUser?> getEditProfile() async {
    try {
      final token =
          await PreferenceHandler.getToken(); // ambil token dari SharedPreferences

      final response = await http.get(
        Uri.parse(ApiEndpoints.profile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GetUser.fromJson(data);
      } else {
        throw Exception("Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error getEditProfile: $e");
    }
  }

  // UPDATE Edit Profile
  Future<EditProfile?> updateEditProfile({
    required int userId,
    required String name,
    required String email,
    required String jenisKelamin,
  }) async {
    try {
      final token =
          await PreferenceHandler.getToken(); // ambil token dari SharedPreferences

      final response = await http.put(
        Uri.parse(ApiEndpoints.profile),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "name": name,
          "email": email,
          "jenis_kelamin": jenisKelamin,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return EditProfile.fromJson(data);
      } else {
        throw Exception("Failed to update profile: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updateEditProfile: $e");
    }
  }

  Future<EditPhoto?> updateProfilePhoto(String base64Image) async {
    try {
      final token = await PreferenceHandler.getToken();

      final response = await http.put(
        Uri.parse(
          ApiEndpoints.profileEdit,
        ), // pastikan endpoint ada di ApiEndpoints
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "profile_photo": base64Image, // kirim base64 image
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return EditPhoto.fromJson(data);
      } else {
        throw Exception("Failed to update photo: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updateProfilePhoto: $e");
    }
  }
}
