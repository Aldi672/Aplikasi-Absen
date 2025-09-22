// widgets/action_buttons_row.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart'
    as AbsenToday;
import 'package:geolocator/geolocator.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onIzin;
  final bool isCheckingIn;
  final bool isCheckingOut;
  final AbsenToday.Data? absenData;
  final Position? currentPosition; // Tambahkan parameter lokasi
  final String currentAddress; // Tambahkan parameter alamat

  // Pengaturan lokasi kantor dan jam kerja
  static const double _officeLatitude = -6.210882;
  static const double _officeLongitude = 106.812942;
  static const double _allowedRadius = 50.0; // meter
  static const int _workStartHour = 8; // Jam masuk kerja (08:00)
  static const int _workEndHour = 17; // Jam pulang kerja (17:00)

  const ActionButtonsRow({
    super.key,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onIzin,
    required this.isCheckingIn,
    required this.isCheckingOut,
    this.absenData,
    this.currentPosition,
    required this.currentAddress,
  });

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
          // Header dengan status lokasi
          Row(
            children: [
              Icon(
                _isWithinOfficeRadius()
                    ? Icons.check_circle
                    : Icons.location_off,
                color: _isWithinOfficeRadius() ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilihan Absensi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      _getLocationStatus(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _isWithinOfficeRadius()
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Buttons Row
          Row(
            children: [
              // Check In Button
              Expanded(
                child: _buildActionButton(
                  label: 'Check In',
                  icon: Icons.login,
                  color: Colors.orange,
                  isLoading: isCheckingIn,
                  onPressed: _canCheckIn() ? onCheckIn : null,
                  disabledReason: _getCheckInDisabledReason(),
                ),
              ),

              const SizedBox(width: 12),

              // Permission Button
              Expanded(
                child: _buildActionButton(
                  label: 'Izin',
                  icon: Icons.assignment_late,
                  color: Colors.blue,
                  isLoading: false,
                  onPressed: _canRequestPermission() ? onIzin : null,
                  disabledReason: _getPermissionDisabledReason(),
                ),
              ),

              const SizedBox(width: 12),

              // Check Out Button
              Expanded(
                child: _buildActionButton(
                  label: 'Check Out',
                  icon: Icons.logout,
                  color: _canCheckOut() ? Colors.green : Colors.grey,
                  isLoading: isCheckingOut,
                  onPressed: _canCheckOut() ? onCheckOut : null,
                  disabledReason: _getCheckOutDisabledReason(),
                ),
              ),
            ],
          ),

          // Status Info dengan informasi lokasi dan jam
          if (_getDetailedStatusMessage() != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getStatusBorderColor()),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(),
                        color: _getStatusIconColor(),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getDetailedStatusMessage()!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusTextColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_shouldShowLocationDetails()) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.place,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Jarak ke kantor: ${_getDistanceToOffice()}m',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Jam kerja: ${_workStartHour.toString().padLeft(2, '0')}:00 - ${_workEndHour.toString().padLeft(2, '0')}:00',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback? onPressed,
    String? disabledReason,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: disabledReason ?? '',
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? color : Colors.grey[300],
            foregroundColor: isEnabled ? Colors.white : Colors.grey[500],
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // === VALIDASI LOKASI ===
  bool _isWithinOfficeRadius() {
    if (currentPosition == null) return false;

    double distance = Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      _officeLatitude,
      _officeLongitude,
    );

    return distance <= _allowedRadius;
  }

  double _getDistanceToOffice() {
    if (currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      _officeLatitude,
      _officeLongitude,
    );
  }

  // === VALIDASI JAM KERJA ===
  bool _isWithinWorkingHours() {
    final now = DateTime.now();
    final currentHour = now.hour;
    return currentHour >= _workStartHour && currentHour < _workEndHour;
  }

  // === VALIDASI TOMBOL ===
  bool _canCheckIn() {
    if (isCheckingIn) return false;
    if (absenData?.checkInTime != null) return false;
    if (!_isWithinOfficeRadius()) return false;
    if (!_isWithinWorkingHours()) return false;
    return true;
  }

  bool _canRequestPermission() {
    if (isCheckingIn) return false;
    if (absenData?.checkInTime != null) return false;
    if (absenData?.status == 'izin') return false;
    return true;
  }

  bool _canCheckOut() {
    if (isCheckingOut) return false;
    if (absenData?.checkInTime == null) return false;
    if (absenData?.checkOutTime != null) return false;
    if (!_isWithinOfficeRadius()) return false;
    return true;
  }

  // === PESAN ERROR ===
  String? _getCheckInDisabledReason() {
    if (absenData?.checkInTime != null) return "Anda sudah check-in hari ini";
    if (!_isWithinOfficeRadius()) return "Lokasi terlalu jauh dari kantor";
    if (!_isWithinWorkingHours()) return "Di luar jam kerja";
    return null;
  }

  String? _getPermissionDisabledReason() {
    if (absenData?.checkInTime != null)
      return "Sudah check-in, tidak bisa izin";
    if (absenData?.status == 'izin') return "Sudah mengajukan izin hari ini";
    return null;
  }

  String? _getCheckOutDisabledReason() {
    if (absenData?.checkInTime == null) return "Belum check-in";
    if (absenData?.checkOutTime != null) return "Sudah check-out hari ini";
    if (!_isWithinOfficeRadius()) return "Lokasi terlalu jauh dari kantor";
    return null;
  }

  // === STATUS MESSAGES ===
  String _getLocationStatus() {
    if (currentPosition == null) {
      return "Lokasi belum terdeteksi";
    }

    if (_isWithinOfficeRadius()) {
      return "Dalam radius kantor (${_getDistanceToOffice().toStringAsFixed(1)}m)";
    } else {
      return "Luar radius kantor (${_getDistanceToOffice().toStringAsFixed(1)}m)";
    }
  }

  String? _getDetailedStatusMessage() {
    // Prioritas pesan berdasarkan status absensi
    if (absenData?.status == 'izin') {
      return 'Status hari ini: Izin. Semoga urusan lancar!';
    }

    if (absenData?.checkInTime != null && absenData?.checkOutTime != null) {
      return 'Absensi hari ini sudah lengkap. Terima kasih!';
    }

    if (absenData?.checkInTime != null && absenData?.checkOutTime == null) {
      return 'Sudah check-in. Jangan lupa check-out sebelum pulang.';
    }

    // Pesan berdasarkan kondisi lokasi dan waktu
    if (!_isWithinOfficeRadius() && currentPosition != null) {
      return 'Anda berada di luar radius kantor. Dekati kantor untuk melakukan absensi.';
    }

    if (!_isWithinWorkingHours()) {
      final now = DateTime.now();
      if (now.hour < _workStartHour) {
        return 'Belum waktunya masuk kerja. Jam kerja mulai ${_workStartHour.toString().padLeft(2, '0')}:00.';
      } else {
        return 'Sudah melewati jam kerja. Jam kerja sampai ${_workEndHour.toString().padLeft(2, '0')}:00.';
      }
    }

    if (_isWithinOfficeRadius() && _isWithinWorkingHours()) {
      return 'Lokasi dan waktu sesuai. Anda dapat melakukan absensi.';
    }

    return null;
  }

  // === STYLING HELPERS ===
  Color _getStatusBackgroundColor() {
    if (absenData?.status == 'izin') return Colors.blue.shade50;
    if (absenData?.checkInTime != null && absenData?.checkOutTime != null) {
      return Colors.green.shade50;
    }
    if (!_isWithinOfficeRadius()) return Colors.red.shade50;
    if (!_isWithinWorkingHours()) return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  Color _getStatusBorderColor() {
    if (absenData?.status == 'izin') return Colors.blue.withOpacity(0.2);
    if (absenData?.checkInTime != null && absenData?.checkOutTime != null) {
      return Colors.green.withOpacity(0.2);
    }
    if (!_isWithinOfficeRadius()) return Colors.red.withOpacity(0.2);
    if (!_isWithinWorkingHours()) return Colors.orange.withOpacity(0.2);
    return Colors.green.withOpacity(0.2);
  }

  Color _getStatusTextColor() {
    if (absenData?.status == 'izin') return Colors.blue.shade700;
    if (absenData?.checkInTime != null && absenData?.checkOutTime != null) {
      return Colors.green.shade700;
    }
    if (!_isWithinOfficeRadius()) return Colors.red.shade700;
    if (!_isWithinWorkingHours()) return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  Color _getStatusIconColor() {
    if (absenData?.status == 'izin') return Colors.blue.shade600;
    if (absenData?.checkInTime != null && absenData?.checkOutTime != null) {
      return Colors.green.shade600;
    }
    if (!_isWithinOfficeRadius()) return Colors.red.shade600;
    if (!_isWithinWorkingHours()) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  IconData _getStatusIcon() {
    if (absenData?.status == 'izin') return Icons.assignment_late;
    if (absenData?.checkInTime != null && absenData?.checkOutTime != null) {
      return Icons.check_circle;
    }
    if (!_isWithinOfficeRadius()) return Icons.location_off;
    if (!_isWithinWorkingHours()) return Icons.access_time;
    return Icons.check_circle;
  }

  bool _shouldShowLocationDetails() {
    return currentPosition != null &&
        (absenData?.checkInTime == null || absenData?.checkOutTime == null);
  }
}
