// widgets/attendance_summary.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart'
    as AbsenToday;

class AttendanceSummary extends StatelessWidget {
  final AbsenToday.Data? absenData;

  const AttendanceSummary({super.key, this.absenData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.purple.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ringkasan Hari Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Summary Cards
          Row(
            children: [
              // Status Card
              Expanded(
                child: _buildSummaryCard(
                  title: 'Status',
                  value: _getStatusText(),
                  icon: Icons.assignment_turned_in,
                  color: _getStatusColor(),
                ),
              ),

              const SizedBox(width: 12),

              // Time Card
              Expanded(
                child: _buildSummaryCard(
                  title: 'Waktu Sekarang',
                  value: _getCurrentTime(),
                  icon: Icons.access_time,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Additional Info Row
          Row(
            children: [
              // Work Duration (if checked in)
              if (absenData?.checkInTime != null &&
                  absenData?.checkOutTime != null)
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Durasi Kerja',
                    value: _calculateWorkDuration(),
                    icon: Icons.timer,
                    color: Colors.green,
                  ),
                )
              else if (absenData?.checkInTime != null &&
                  absenData?.checkOutTime == null)
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Sedang Bekerja',
                    value: _calculateCurrentWorkTime(),
                    icon: Icons.play_arrow,
                    color: Colors.orange,
                  ),
                )
              else
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Hari',
                    value: _getTodayName(),
                    icon: Icons.calendar_today,
                    color: Colors.indigo,
                  ),
                ),

              const SizedBox(width: 12),

              // Weather or Date Info
              Expanded(
                child: _buildSummaryCard(
                  title: 'Tanggal',
                  value: _getTodayDate(),
                  icon: Icons.date_range,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (absenData == null) return 'Belum Absen';

    switch (absenData!.status?.toLowerCase()) {
      case 'hadir':
        if (absenData!.checkOutTime != null) return 'Selesai';
        return 'Hadir';
      case 'izin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      case 'alpha':
        return 'Alpha';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor() {
    if (absenData == null) return Colors.grey;

    switch (absenData!.status?.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'izin':
        return Colors.blue;
      case 'sakit':
        return Colors.orange;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getTodayName() {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[DateTime.now().weekday - 1];
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _calculateWorkDuration() {
    if (absenData?.checkInTime == null || absenData?.checkOutTime == null) {
      return '-';
    }

    try {
      final checkIn = _parseTime(absenData!.checkInTime!);
      final checkOut = _parseTime(absenData!.checkOutTime!);

      final duration = checkOut.difference(checkIn);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      return '${hours}j ${minutes}m';
    } catch (e) {
      return 'Error';
    }
  }

  String _calculateCurrentWorkTime() {
    if (absenData?.checkInTime == null) return '-';

    try {
      final checkIn = _parseTime(absenData!.checkInTime!);
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final checkInToday = DateTime(
        today.year,
        today.month,
        today.day,
        checkIn.hour,
        checkIn.minute,
      );

      final duration = now.difference(checkInToday);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      return '${hours}j ${minutes}m';
    } catch (e) {
      return 'Error';
    }
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}
