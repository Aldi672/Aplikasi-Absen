// widgets/action_buttons_row.dart - Enhanced with Real-time Location Updates
import 'package:aplikasi_absen/models/get_absen_today_models.dart'
    as AbsenToday;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ActionButtonsRow extends StatefulWidget {
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onIzin;
  final bool isCheckingIn;
  final bool isCheckingOut;
  final AbsenToday.Data? absenData;
  final Position? currentPosition;
  final String currentAddress;

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
  State<ActionButtonsRow> createState() => _ActionButtonsRowState();
}

class _ActionButtonsRowState extends State<ActionButtonsRow>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Animation untuk pulse effect ketika dalam radius
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animation untuk slide in effect
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void didUpdateWidget(ActionButtonsRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger pulse animation ketika masuk/keluar radius
    if (oldWidget.currentPosition != widget.currentPosition) {
      _handleLocationUpdate();
    }
  }

  void _handleLocationUpdate() {
    if (_isWithinOfficeRadius()) {
      // Mulai pulse animation ketika dalam radius
      _pulseController.repeat(reverse: true);
    } else {
      // Stop pulse animation ketika keluar radius
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isWithinOfficeRadius()
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.2),
            width: _isWithinOfficeRadius() ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isWithinOfficeRadius()
                  ? Colors.green.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: _isWithinOfficeRadius() ? 15 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan real-time location status
            _buildLocationStatusHeader(),
            const SizedBox(height: 16),

            // Buttons Row dengan animasi
            _buildAnimatedButtonsRow(),

            // Status Info yang dinamis
            if (_getDetailedStatusMessage() != null) ...[
              const SizedBox(height: 12),
              _buildStatusInfoCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatusHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isWithinOfficeRadius()
                  ? Icons.verified_user
                  : Icons.location_disabled,
              key: ValueKey(_isWithinOfficeRadius()),
              color: _isWithinOfficeRadius() ? Colors.green : Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
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
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 12,
                    color: _isWithinOfficeRadius()
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text(_getLocationStatus()),
                ),
              ],
            ),
          ),
          // Real-time location indicator
          _buildLocationIndicator(),
        ],
      ),
    );
  }

  Widget _buildLocationIndicator() {
    if (widget.currentPosition == null) {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        child: const SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _isWithinOfficeRadius() ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        boxShadow: _isWithinOfficeRadius()
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildAnimatedButtonsRow() {
    return Row(
      children: [
        // Check In Button with pulse animation
        Expanded(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _canCheckIn() ? _pulseAnimation.value : 1.0,
                child: _buildActionButton(
                  label: 'Check In',
                  icon: Icons.login,
                  color: _canCheckIn() ? Colors.orange : Colors.grey,
                  isLoading: widget.isCheckingIn,
                  onPressed: _canCheckIn() ? widget.onCheckIn : null,
                  disabledReason: _getCheckInDisabledReason(),
                  isHighlighted: _canCheckIn(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        // Permission Button
        Expanded(
          child: _buildActionButton(
            label: 'Izin',
            icon: Icons.assignment_late,
            color: _canRequestPermission() ? Colors.blue : Colors.grey,
            isLoading: false,
            onPressed: _canRequestPermission() ? widget.onIzin : null,
            disabledReason: _getPermissionDisabledReason(),
            isHighlighted: _canRequestPermission() && !_isWithinOfficeRadius(),
          ),
        ),

        const SizedBox(width: 12),

        // Check Out Button with pulse animation
        Expanded(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _canCheckOut() ? _pulseAnimation.value : 1.0,
                child: _buildActionButton(
                  label: 'Check Out',
                  icon: Icons.logout,
                  color: _canCheckOut() ? Colors.green : Colors.grey,
                  isLoading: widget.isCheckingOut,
                  onPressed: _canCheckOut() ? widget.onCheckOut : null,
                  disabledReason: _getCheckOutDisabledReason(),
                  isHighlighted: _canCheckOut(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback? onPressed,
    String? disabledReason,
    bool isHighlighted = false,
  }) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: disabledReason ?? '',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: color.withOpacity(isHighlighted ? 0.4 : 0.2),
                    blurRadius: isHighlighted ? 12 : 8,
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
            elevation: isHighlighted ? 8 : 0,
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

  Widget _buildStatusInfoCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _getStatusIcon(),
                  key: ValueKey(_getStatusIcon()),
                  color: _getStatusIconColor(),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusTextColor(),
                    fontWeight: FontWeight.w500,
                  ),
                  child: Text(_getDetailedStatusMessage()!),
                ),
              ),
            ],
          ),
          if (_shouldShowLocationDetails()) ...[
            const SizedBox(height: 8),
            _buildLocationDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationDetails() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
              Icon(Icons.place, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Jarak ke kantor: ${_getDistanceToOffice().toStringAsFixed(1)}m',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _isWithinOfficeRadius()
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isWithinOfficeRadius() ? 'DALAM RADIUS' : 'LUAR RADIUS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: _isWithinOfficeRadius()
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Jam kerja: ${ActionButtonsRow._workStartHour.toString().padLeft(2, '0')}:00 - ${ActionButtonsRow._workEndHour.toString().padLeft(2, '0')}:00',
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === VALIDASI LOKASI ===
  bool _isWithinOfficeRadius() {
    if (widget.currentPosition == null) return false;

    double distance = Geolocator.distanceBetween(
      widget.currentPosition!.latitude,
      widget.currentPosition!.longitude,
      ActionButtonsRow._officeLatitude,
      ActionButtonsRow._officeLongitude,
    );

    return distance <= ActionButtonsRow._allowedRadius;
  }

  double _getDistanceToOffice() {
    if (widget.currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
      widget.currentPosition!.latitude,
      widget.currentPosition!.longitude,
      ActionButtonsRow._officeLatitude,
      ActionButtonsRow._officeLongitude,
    );
  }

  // === VALIDASI JAM KERJA ===
  bool _isWithinWorkingHours() {
    final now = DateTime.now();
    final currentHour = now.hour;
    return currentHour >= ActionButtonsRow._workStartHour &&
        currentHour < ActionButtonsRow._workEndHour;
  }

  // === VALIDASI TOMBOL ===
  bool _canCheckIn() {
    if (widget.isCheckingIn) return false;
    if (widget.absenData?.checkInTime != null) return false;
    if (!_isWithinOfficeRadius()) return false;
    if (!_isWithinWorkingHours()) return false;
    return true;
  }

  bool _canRequestPermission() {
    if (widget.isCheckingIn) return false;
    if (widget.absenData?.checkInTime != null) return false;
    if (widget.absenData?.status == 'izin') return false;
    return true;
  }

  bool _canCheckOut() {
    if (widget.isCheckingOut) return false;
    if (widget.absenData?.checkInTime == null) return false;
    if (widget.absenData?.checkOutTime != null) return false;
    if (!_isWithinOfficeRadius()) return false;
    return true;
  }

  // === PESAN ERROR ===
  String? _getCheckInDisabledReason() {
    if (widget.absenData?.checkInTime != null)
      return "Anda sudah check-in hari ini";
    if (!_isWithinOfficeRadius()) {
      final distance = _getDistanceToOffice();
      return "Lokasi terlalu jauh dari kantor (${distance.toStringAsFixed(1)}m dari batas ${ActionButtonsRow._allowedRadius.toInt()}m)";
    }
    if (!_isWithinWorkingHours())
      return "Di luar jam kerja (${ActionButtonsRow._workStartHour}:00-${ActionButtonsRow._workEndHour}:00)";
    return null;
  }

  String? _getPermissionDisabledReason() {
    if (widget.absenData?.checkInTime != null)
      return "Sudah check-in, tidak bisa izin";
    if (widget.absenData?.status == 'izin')
      return "Sudah mengajukan izin hari ini";
    return null;
  }

  String? _getCheckOutDisabledReason() {
    if (widget.absenData?.checkInTime == null) return "Belum check-in";
    if (widget.absenData?.checkOutTime != null)
      return "Sudah check-out hari ini";
    if (!_isWithinOfficeRadius()) {
      final distance = _getDistanceToOffice();
      return "Lokasi terlalu jauh dari kantor (${distance.toStringAsFixed(1)}m dari batas ${ActionButtonsRow._allowedRadius.toInt()}m)";
    }
    return null;
  }

  // === STATUS MESSAGES ===
  String _getLocationStatus() {
    if (widget.currentPosition == null) {
      return "📍 Mencari lokasi...";
    }

    if (_isWithinOfficeRadius()) {
      return "✅ Dalam radius kerja (${_getDistanceToOffice().toStringAsFixed(1)}m)";
    } else {
      return "❌ Luar radius kerja (${_getDistanceToOffice().toStringAsFixed(1)}m)";
    }
  }

  String? _getDetailedStatusMessage() {
    // Prioritas pesan berdasarkan status absensi
    if (widget.absenData?.status == 'izin') {
      return '📋 Status hari ini: Izin. Semoga urusan lancar!';
    }

    if (widget.absenData?.checkInTime != null &&
        widget.absenData?.checkOutTime != null) {
      return '✅ Absensi hari ini sudah lengkap. Terima kasih!';
    }

    if (widget.absenData?.checkInTime != null &&
        widget.absenData?.checkOutTime == null) {
      if (_isWithinOfficeRadius()) {
        return '⏰ Sudah check-in. Siap untuk check-out!';
      } else {
        return '📍 Sudah check-in. Dekati kantor untuk check-out.';
      }
    }

    // Pesan berdasarkan kondisi lokasi dan waktu
    if (!_isWithinOfficeRadius() && widget.currentPosition != null) {
      return '📍 Anda berada di luar radius kantor. Dekati kantor untuk melakukan absensi.';
    }

    if (!_isWithinWorkingHours()) {
      final now = DateTime.now();
      if (now.hour < ActionButtonsRow._workStartHour) {
        return '⏰ Belum waktunya masuk kerja. Jam kerja mulai ${ActionButtonsRow._workStartHour.toString().padLeft(2, '0')}:00.';
      } else {
        return '⏰ Sudah melewati jam kerja. Jam kerja sampai ${ActionButtonsRow._workEndHour.toString().padLeft(2, '0')}:00.';
      }
    }

    if (_isWithinOfficeRadius() && _isWithinWorkingHours()) {
      return '🎯 Lokasi dan waktu sesuai. Siap untuk absensi!';
    }

    return null;
  }

  // === STYLING HELPERS ===
  Color _getStatusBackgroundColor() {
    if (widget.absenData?.status == 'izin') return Colors.blue.shade50;
    if (widget.absenData?.checkInTime != null &&
        widget.absenData?.checkOutTime != null) {
      return Colors.green.shade50;
    }
    if (!_isWithinOfficeRadius()) return Colors.red.shade50;
    if (!_isWithinWorkingHours()) return Colors.orange.shade50;
    return Colors.green.shade50;
  }

  Color _getStatusBorderColor() {
    if (widget.absenData?.status == 'izin') return Colors.blue.withOpacity(0.3);
    if (widget.absenData?.checkInTime != null &&
        widget.absenData?.checkOutTime != null) {
      return Colors.green.withOpacity(0.3);
    }
    if (!_isWithinOfficeRadius()) return Colors.red.withOpacity(0.3);
    if (!_isWithinWorkingHours()) return Colors.orange.withOpacity(0.3);
    return Colors.green.withOpacity(0.3);
  }

  Color _getStatusTextColor() {
    if (widget.absenData?.status == 'izin') return Colors.blue.shade700;
    if (widget.absenData?.checkInTime != null &&
        widget.absenData?.checkOutTime != null) {
      return Colors.green.shade700;
    }
    if (!_isWithinOfficeRadius()) return Colors.red.shade700;
    if (!_isWithinWorkingHours()) return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  Color _getStatusIconColor() {
    if (widget.absenData?.status == 'izin') return Colors.blue.shade600;
    if (widget.absenData?.checkInTime != null &&
        widget.absenData?.checkOutTime != null) {
      return Colors.green.shade600;
    }
    if (!_isWithinOfficeRadius()) return Colors.red.shade600;
    if (!_isWithinWorkingHours()) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  IconData _getStatusIcon() {
    if (widget.absenData?.status == 'izin') return Icons.assignment_late;
    if (widget.absenData?.checkInTime != null &&
        widget.absenData?.checkOutTime != null) {
      return Icons.check_circle;
    }
    if (!_isWithinOfficeRadius()) return Icons.location_disabled;
    if (!_isWithinWorkingHours()) return Icons.access_time;
    return Icons.verified_user;
  }

  bool _shouldShowLocationDetails() {
    return widget.currentPosition != null &&
        (widget.absenData?.checkInTime == null ||
            widget.absenData?.checkOutTime == null);
  }
}
