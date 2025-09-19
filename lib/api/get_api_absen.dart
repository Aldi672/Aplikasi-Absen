// The rest of your imports remain the same
import 'dart:convert';

import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart';
import 'package:aplikasi_absen/models/get_check_in_models.dart';
import 'package:aplikasi_absen/models/get_check_out_models.dart';
import 'package:aplikasi_absen/models/get_izin_models.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:http/http.dart' as http;

class AbsenAPI {
  static Future<CheckInModel?> checkInUser({
    required double checkInLat,
    required double checkInLng,
    required String checkInLocation,
    required String checkInAddress,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();

      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final checkInTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse(ApiEndpoints.checkIn),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "attendance_date": attendanceDate,
          "check_in_time": checkInTime, // Perubahan di sini
          "check_in_lat": checkInLat.toString(),
          "check_in_lng": checkInLng.toString(),
          "check_in_location": checkInLocation,
          "check_in_address": checkInAddress,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return CheckInModel.fromJson(jsonResponse);
      } else {
        print("CheckIn Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error CheckIn: $e");
      return null;
    }
  }

  static Future<CheckOutModel?> checkOut({
    required double checkOutLat,
    required double checkOutLng,
    required String checkOutLocation,
    required String checkOutAddress,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();
      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final checkOutTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse(ApiEndpoints.checkOut),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: {
          "attendance_date": attendanceDate,
          "check_out_time": checkOutTime, // Perubahan di sini
          "check_out_lat": checkOutLat.toString(),
          "check_out_lng": checkOutLng.toString(),
          "check_out_location": checkOutLocation,
          "check_out_address": checkOutAddress,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return CheckOutModel.fromJson(jsonResponse);
      } else {
        print("CheckOut Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error CheckOut: $e");
      return null;
    }
  }

  static Future<Izin?> submitIzin({required String alasanIzin}) async {
    try {
      final token = await PreferenceHandler.getToken();

      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Asumsi ada endpoint khusus untuk izin di ApiEndpoints
      final response = await http.post(
        Uri.parse(ApiEndpoints.izin), // Asumsikan Anda memiliki endpoint ini
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type":
              "application/json", // Penting untuk mengirim body JSON
        },
        body: jsonEncode({
          "attendance_date": attendanceDate,
          "alasan_izin": alasanIzin,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return Izin.fromJson(jsonResponse);
      } else {
        print("Submit Izin Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error Submit Izin: $e");
      return null;
    }
  }

  // Absen Today
  static Future<AbsenTodayModel?> getAbsenToday() async {
    try {
      final token = await PreferenceHandler.getToken();
      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final response = await http.get(
        Uri.parse("${ApiEndpoints.absenToday}?attendance_date=$attendanceDate"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return AbsenTodayModel.fromJson(jsonDecode(response.body));
      } else {
        print("Get Absen Today Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error Get Absen Today: $e");
      return null;
    }
  }
}
