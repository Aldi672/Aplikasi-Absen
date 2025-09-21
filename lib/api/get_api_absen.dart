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
  /// POST Check In
  static Future<CheckInModel?> checkInUser({
    required double checkInLat,
    required double checkInLng,
    required String checkInAddress,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();

      // ambil tanggal hari ini
      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final checkInTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final body = {
        "attendance_date": attendanceDate,
        "check_in": checkInTime,
        "check_in_lat": checkInLat,
        "check_in_lng": checkInLng,
        "check_in_address": checkInAddress,
        "status": "masuk",
      };

      print("📤 Sending body: $body");

      final response = await http.post(
        Uri.parse(ApiEndpoints.checkIn),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CheckInModel.fromJson(data);
      } else {
        throw Exception("Failed to check-in: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error checkInUser: $e");
    }
  }

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

  static Future<CheckOutModel?> checkOutUser({
    required String attendanceDate,
    required String checkOut,
    required double checkOutLat,
    required double checkOutLng,
    required String checkOutAddress,
    required String status,
  }) async {
    try {
      final token = await PreferenceHandler.getToken();

      // ambil tanggal hari ini
      final now = DateTime.now();
      final attendanceDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final checkOutTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final response = await http.post(
        Uri.parse(ApiEndpoints.checkOut), // pastikan endpoint sesuai
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "attendance_date": attendanceDate,
          "check_out": checkOut,
          "check_out_lat": checkOutLat,
          "check_out_lng": checkOutLng,
          "check_out_address": checkOutAddress,
          "status": status,
        }),
      );

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200) {
        return CheckOutModel.fromJson(jsonDecode(response.body));
      } else {
        print("❌ CheckOut Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error: $e");
      return null;
    }
  }

  /// Kirim permintaan izin
  static Future<Izin?> izin({
    required String attendanceDate,
    required String alasanIzin,
  }) async {
    try {
      final url = Uri.parse(ApiEndpoints.izin);
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode({
          "date": attendanceDate,
          "status": "izin",
          "alasan_izin": alasanIzin,
        }),
      );

      print("📤 Request izin: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Izin.fromJson(json.decode(response.body));
      } else {
        print("❌ Gagal izin. Status: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error izin: $e");
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
        body: jsonEncode({"date": attendanceDate, "alasan_izin": alasanIzin}),
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
}
