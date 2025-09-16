import 'dart:convert';

import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/get_list_bacth_models.dart';
import 'package:http/http.dart' as http;

class BatchService {
  static Future<Bacth> getBatches() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/batches'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Bacth.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load batches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load batches: $e');
    }
  }
}
