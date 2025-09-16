import 'dart:convert';

import 'package:aplikasi_absen/api/endpoint/get_endpoint_user.dart';
import 'package:aplikasi_absen/models/get_list_trainings_models.dart';
import 'package:http/http.dart' as http;

class TrainingService {
  static Future<Trainings> getTrainings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/trainings'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Trainings.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load trainings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load trainings: $e');
    }
  }
}
