// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/delete_absen_today_models.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:http/http.dart' as http;

import '../models/get_history_models.dart'; // file model yang tadi

class HistoryAPI {
  /// Ambil seluruh riwayat absensi
  static Future<GetHistory?> getHistory() async {
    try {
      final token = await PreferenceHandler.getToken();

      final url = Uri.parse(ApiEndpoints.history);
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("📥 Response history: ${response.body}");

      if (response.statusCode == 200) {
        return GetHistory.fromJson(json.decode(response.body));
      } else {
        print("❌ Gagal ambil history. Status: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error getHistory: $e");
      return null;
    }
  }

  /// Ambil riwayat absensi berdasarkan tanggal
  static Future<GetHistory?> getHistoryByDate(String date) async {
    try {
      final token = await PreferenceHandler.getToken();

      final url = Uri.parse("${ApiEndpoints.history}?date=$date");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("📥 Response history by date: ${response.body}");

      if (response.statusCode == 200) {
        return GetHistory.fromJson(json.decode(response.body));
      } else {
        print("❌ Gagal ambil history by date. Status: ${response.statusCode}");
        print("❌ Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error getHistoryByDate: $e");
      return null;
    }
  }

  static Future<GetDelete?> deleteHistory(String id) async {
    try {
      final token = await PreferenceHandler.getToken();

      final url = Uri.parse(ApiEndpoints.historyById(id));
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("🗑️ Response delete history: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        return GetDelete.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Error deleteAbsen: $e");
      return null;
    }
  }
}
