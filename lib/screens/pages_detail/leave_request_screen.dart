import 'package:aplikasi_absen/screens/pages_draggble/draggable_scrollable_sheet_screen.dart';
import 'package:flutter/material.dart';

class RiwayatAbsensiContent extends StatelessWidget {
  const RiwayatAbsensiContent();

  @override
  Widget build(BuildContext context) {
    final List<AbsensiHistory> historyData = [
      AbsensiHistory(
        date: "Senin, 15 Sep 2025 : 16:30",
        status: "Absen Keluar",
      ),
      AbsensiHistory(date: "Senin, 15 Sep 2025 : 08:01", status: "Absen Masuk"),
      AbsensiHistory(
        date: "Jumat, 12 Sep 2025 : 17:05",
        status: "Absen Keluar",
      ),
      AbsensiHistory(date: "Jumat, 12 Sep 2025 : 07:55", status: "Absen Masuk"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Riwayat Absensi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...historyData.map((history) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _HistoryItem(date: history.date, status: history.status),
          );
        }).toList(),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String date;
  final String status;
  // ... (kode sama seperti sebelumnya)

  const _HistoryItem({required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isMasuk = status.toLowerCase().contains('masuk');
    final Color statusColor = isMasuk ? Colors.green : Colors.orange;

    return Row(
      children: [
        Icon(Icons.access_time_filled, color: Colors.grey[400], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            date,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
