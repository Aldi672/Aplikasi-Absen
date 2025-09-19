import 'dart:convert';
import 'package:http/http.dart' as http;

// Sesuaikan path import ini dengan struktur proyek Anda
import 'package:aplikasi_absen/models/get_statistic_models.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart'; // Asumsi endpoint ada di sini

class StatistikService {
  /// Mengambil data statistik absensi untuk pengguna yang sedang login.
  static Future<GetStatistikPengguna?> getStatistik() async {
    try {
      // 1. Ambil token autentikasi pengguna
      final token = await PreferenceHandler.getToken();

      // 2. Lakukan request GET ke endpoint statistik
      final response = await http.get(
        // Pastikan Anda memiliki endpoint yang benar di kelas ApiEndpoints
        Uri.parse(ApiEndpoints.getStatistik),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // 3. Periksa status kode dari respons server
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        return GetStatistikPengguna.fromJson(jsonResponse);
      } else {
        // Jika gagal, cetak pesan error
        print("Gagal mengambil statistik: ${response.body}");
        return null;
      }
    } catch (e) {
      // Tangani jika ada error koneksi atau lainnya
      print("Error saat mengambil statistik: $e");
      return null;
    }
  }
}
