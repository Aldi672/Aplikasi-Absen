import 'dart:convert';

import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart';
import 'package:aplikasi_absen/models/get_hadir_models.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceService {
  // Fungsi untuk melakukan Check-In (Hadir)
  static Future<GetHadir> checkIn({
    required String status,
    double? latitude, // Menjadi opsional (boleh null)
    double? longitude, // Menjadi opsional (boleh null)
    String? address, // Menjadi opsional (boleh null)
    String? alasanIzin, // Menjadi opsional (boleh null)
  }) async {
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan, silahkan login ulang.");
    }

    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, dynamic> body = {
      "attendance_date": todayDate,
      "status": status,
    };

    // HANYA jika statusnya 'hadir', kita tambahkan data lokasi
    if (status == 'hadir') {
      body['check_in_lat'] = latitude;
      body['check_in_lng'] = longitude;
      body['check_in_address'] = address;
    }
    // Dan HANYA jika statusnya 'izin', kita tambahkan alasan
    else if (status == 'izin') {
      body['alasan_izin'] = alasanIzin;
    }

    final url = Uri.parse(ApiEndpoints.checkIn);
    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "attendance_date": todayDate, // <-- Kirim tanggal hari ini
        "status": status, // <-- Kirim status (kemungkinan ini "1 more error")
        "check_in_lat": latitude,
        "check_in_lng": longitude,
        "check_in_address": address,
        "alasan_izin": alasanIzin,
      }),
    );

    if (response.statusCode == 200) {
      return getHadirFromJson(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal melakukan check-in");
    }
  }

  // Fungsi untuk mendapatkan data absensi hari ini
  static Future<DataAbsen> getTodaysAttendance() async {
    final token = await PreferenceHandler.getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan, silahkan login ulang.");
    }

    final url = Uri.parse(ApiEndpoints.absenToday);
    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return dataAbsenFromJson(response.body);
    } else if (response.statusCode == 404) {
      // Jika API mengembalikan 404, artinya belum ada data absen hari ini
      throw Exception("Anda belum melakukan absensi hari ini.");
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Gagal mengambil data absensi");
    }
  }
}
