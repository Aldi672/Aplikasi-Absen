// widgets/action_buttons_row.dart
import 'package:flutter/material.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart'
    as AbsenToday;

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onIzin;
  final bool isCheckingIn;
  final bool isCheckingOut;
  final AbsenToday.Data? absenData;

  const ActionButtonsRow({
    super.key,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onIzin,
    required this.isCheckingIn,
    required this.isCheckingOut,
    this.absenData,
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
          // Header
          Row(
            children: [
              Icon(Icons.touch_app, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Pilihan Absensi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
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
                ),
              ),
            ],
          ),

          // Status Info
          if (_getStatusMessage() != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getStatusMessage()!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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
  }) {
    final isEnabled = onPressed != null;

    return Container(
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
    );
  }

  bool _canCheckIn() {
    return !isCheckingIn && (absenData?.checkInTime == null);
  }

  bool _canRequestPermission() {
    return !isCheckingIn && (absenData?.checkInTime == null);
  }

  bool _canCheckOut() {
    return !isCheckingOut &&
        (absenData?.checkInTime != null) &&
        (absenData?.checkOutTime == null);
  }

  String? _getStatusMessage() {
    if (absenData?.checkInTime != null && absenData?.checkOutTime == null) {
      return 'Anda sudah check-in. Jangan lupa untuk check-out sebelum pulang.';
    }
    if (absenData?.checkInTime != null && absenData?.checkOutTime != null) {
      return 'Absensi hari ini sudah lengkap. Terima kasih!';
    }
    if (absenData?.status == 'izin') {
      return 'Status hari ini: Izin. Semoga cepat pulih/urusan lancar.';
    }
    return null;
  }
}
