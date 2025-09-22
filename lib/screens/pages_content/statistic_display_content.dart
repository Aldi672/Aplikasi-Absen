import 'package:aplikasi_absen/api/get_statistic_absen.dart';
import 'package:flutter/material.dart';
// Sesuaikan path import dengan lokasi file service dan model Anda

import 'package:aplikasi_absen/models/get_statistic_models.dart';

class StatistikDisplay extends StatefulWidget {
  const StatistikDisplay({Key? key}) : super(key: key);

  @override
  StatistikDisplayState createState() => StatistikDisplayState();
}

class StatistikDisplayState extends State<StatistikDisplay> {
  Data? _statistikData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Ensure it's loading when called externally
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await StatistikService.getStatistik();
      if (!mounted) return; // pastikan widget masih aktif

      setState(() {
        _statistikData = response?.data;
      });
    } catch (e) {
      // Handle error if needed
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_statistikData == null) {
      return const Center(child: Text("Gagal memuat data statistik."));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _StatBox(
          label: "Hadir",

          value: (_statistikData!.totalMasuk ?? 0).toString(),
          color: Colors.green,
        ),
        _StatBox(label: "Sakit", value: "0", color: Colors.blue),
        _StatBox(
          label: "Izin",
          value: (_statistikData!.totalIzin ?? 0).toString(),
          color: Colors.orange,
        ),
        _StatBox(
          label: "Absen",
          value: (_statistikData!.totalAbsen ?? 0).toString(),
          color: Colors.red,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 6, left: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
