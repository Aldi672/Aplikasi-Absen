// get_dashboard_screen.dart - Updated with Conditional Location Card
import 'dart:async';

import 'package:aplikasi_absen/api/get_api_absen.dart';
import 'package:aplikasi_absen/api/get_api_user.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart'
    as AbsenToday;
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:aplikasi_absen/screens/pages_content/location_content.dart';
import 'package:aplikasi_absen/screens/pages_content/statistic_display_content.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/action_buttons_row.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/attendance_status_card.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/attendance_summary.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/dashboard_utils.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/user_profile_card.dart';
import 'package:aplikasi_absen/screens/pages_draggble/draggable_scrollable_sheet_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class GetDashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const GetDashboardScreen({super.key});

  @override
  State<GetDashboardScreen> createState() => _GetDashboardScreenState();
}

class _GetDashboardScreenState extends State<GetDashboardScreen>
    with TickerProviderStateMixin {
  // Koordinat kantor PPKD dan radius
  static const double _officeLatitude = -6.210437;
  static const double _officeLongitude = 106.813966;
  static const double _boundaryRadius = 50.0; // 50 meter radius

  final GlobalKey<StatistikDisplayState> _statistikDisplayKey =
      GlobalKey<StatistikDisplayState>();
  final GlobalKey<State> _riwayatAbsensiKey = GlobalKey<State>();

  GetUser? userData;
  AbsenToday.Data? _absenData;
  bool _isLoadingProfile = true;
  bool _isFetchingAttendance = true;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  String _errorMessage = '';
  final bool _isLocationLoading = true;

  Timer? _locationTimer;

  Position? _currentPosition;
  String _currentAddress = "";

  late AnimationController _mainAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchInitialData();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeInOut,
    );
    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    super.dispose();
  }

  void _updateLocation(Position? position, String fullAddress) {
    setState(() {
      _currentPosition = position;
      _currentAddress = fullAddress;
    });
  }

  // Helper method untuk mengecek apakah user berada dalam radius kantor
  bool _isUserWithinOfficeRadius() {
    if (_currentPosition == null) return false;

    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _officeLatitude,
      _officeLongitude,
    );

    return distance <= _boundaryRadius;
  }

  // Helper method untuk mendapatkan jarak ke kantor
  double _getDistanceToOffice() {
    if (_currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _officeLatitude,
      _officeLongitude,
    );
  }

  Future<void> _fetchInitialData() async {
    await _fetchUserData();
    await _fetchTodaysAttendance();
  }

  Future<void> _reloadData() async {
    await _fetchTodaysAttendance();
    _statistikDisplayKey.currentState?.fetchData();
  }

  Future<void> _fetchUserData() async {
    try {
      final data = await AuthService.getUserProfile();
      if (mounted) setState(() => userData = data);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _fetchTodaysAttendance() async {
    if (mounted) setState(() => _isFetchingAttendance = true);
    try {
      final data = await AbsenAPI.getAbsenToday();
      if (mounted) setState(() => _absenData = data?.data);
    } catch (e) {
      if (mounted) setState(() => _absenData = null);
    } finally {
      if (mounted) setState(() => _isFetchingAttendance = false);
    }
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isCheckingIn = true);

    try {
      // Validasi data lokasi tersedia
      if (_currentPosition == null) {
        throw Exception(
          "Data lokasi tidak tersedia.\nMohon tunggu hingga lokasi berhasil dimuat atau tekan tombol refresh lokasi.",
        );
      }

      // Validasi alamat sudah dimuat
      if (_currentAddress.isEmpty ||
          _currentAddress.contains("Mencari lokasi") ||
          _currentAddress.contains("Gagal mendapatkan")) {
        throw Exception(
          "Alamat belum berhasil dimuat.\nMohon tunggu beberapa saat atau tekan tombol refresh lokasi.",
        );
      }

      // Validasi radius - pengecekan utama
      if (!_isUserWithinOfficeRadius()) {
        final distance = _getDistanceToOffice();
        throw Exception(
          "ANDA BERADA DI LUAR AREA PPKD!\n\n"
          "📍 Jarak Anda dari kantor PPKD: ${distance.toStringAsFixed(1)} meter\n"
          "✅ Batas maksimal yang diizinkan: ${_boundaryRadius.toInt()} meter\n\n"
          "Silakan mendekat ke area kantor untuk melakukan check-in.",
        );
      }

      // Proses check-in jika semua validasi berhasil
      final result = await AbsenAPI.checkInUser(
        checkInLat: _currentPosition!.latitude,
        checkInLng: _currentPosition!.longitude,
        checkInAddress: _currentAddress,
      );

      if (result != null) {
        await _reloadData();
        final distance = _getDistanceToOffice();
        DashboardUtils.showSuccessSnackBar(
          context,
          "Berhasil check-in pada ${result.data?.checkInTime}\n"
          "Jarak dari kantor: ${distance.toStringAsFixed(1)}m",
        );
      } else {
        throw Exception("Gagal melakukan check-in. Silakan coba lagi.");
      }
    } catch (e) {
      DashboardUtils.showErrorSnackBar(context, e.toString());
    } finally {
      setState(() => _isCheckingIn = false);
    }
  }

  Future<void> _handleCheckOut() async {
    setState(() => _isCheckingOut = true);

    try {
      // Validasi data lokasi tersedia
      if (_currentPosition == null) {
        throw Exception(
          "Data lokasi tidak tersedia.\nMohon tunggu hingga lokasi berhasil dimuat atau tekan tombol refresh lokasi.",
        );
      }

      // Validasi alamat sudah dimuat
      if (_currentAddress.isEmpty ||
          _currentAddress.contains("Mencari lokasi") ||
          _currentAddress.contains("Gagal mendapatkan")) {
        throw Exception(
          "Alamat belum berhasil dimuat.\nMohon tunggu beberapa saat atau tekan tombol refresh lokasi.",
        );
      }

      // Validasi radius - pengecekan utama
      if (!_isUserWithinOfficeRadius()) {
        final distance = _getDistanceToOffice();
        throw Exception(
          "ANDA BERADA DI LUAR AREA KANTOR!\n\n"
          "📍 Jarak Anda dari kantor PPKD: ${distance.toStringAsFixed(1)} meter\n"
          "✅ Batas maksimal yang diizinkan: ${_boundaryRadius.toInt()} meter\n\n"
          "Silakan mendekat ke area kantor untuk melakukan check-out.",
        );
      }

      // Proses check-out jika semua validasi berhasil
      final now = DateTime.now();
      final attendanceDate = DateFormat("yyyy-MM-dd").format(now);
      final checkOutTime = DateFormat("HH:mm").format(now);

      final result = await AbsenAPI.checkOutUser(
        attendanceDate: attendanceDate,
        checkOut: checkOutTime,
        checkOutLat: _currentPosition!.latitude,
        checkOutLng: _currentPosition!.longitude,
        checkOutAddress: _currentAddress,
        status: "pulang",
      );

      if (result != null) {
        await _reloadData();
        final distance = _getDistanceToOffice();
        DashboardUtils.showSuccessSnackBar(
          context,
          "Berhasil check-out pada ${result.data?.checkOutTime ?? checkOutTime}\n"
          "Jarak dari kantor: ${distance.toStringAsFixed(1)}m",
        );
      } else {
        throw Exception("Gagal melakukan check-out. Silakan coba lagi.");
      }
    } catch (e) {
      DashboardUtils.showErrorSnackBar(context, e.toString());
    } finally {
      setState(() => _isCheckingOut = false);
    }
  }

  Future<void> _handleIzin() async {
    final String? alasan = await DashboardUtils.showPermissionDialog(context);
    if (alasan == null || alasan.isEmpty) return;

    setState(() => _isCheckingIn = true);
    try {
      final result = await AbsenAPI.submitIzin(alasanIzin: alasan);
      if (result != null) {
        await _reloadData();
        DashboardUtils.showSuccessSnackBar(
          context,
          "Berhasil mengajukan izin: ${result.data?.alasanIzin}",
        );
      } else {
        throw Exception("Gagal mengajukan izin. Silakan coba lagi.");
      }
    } catch (e) {
      DashboardUtils.showErrorSnackBar(context, e.toString());
    } finally {
      setState(() => _isCheckingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A86FF), Color(0xFF2C8DE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 30),
                        UserProfileCard(
                          userData: userData,
                          statistikDisplayKey: _statistikDisplayKey,
                          isLoading: _isLoadingProfile,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: LocationCard(
                            onLocationUpdate: _updateLocation,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AttendanceStatusCard(
                          absenData: _absenData,
                          isFetching: _isFetchingAttendance,
                        ),
                        const SizedBox(height: 24),

                        // Enhanced Location Status Card
                        _buildEnhancedLocationStatusCard(),

                        if (!_isUserWithinOfficeRadius())
                          const SizedBox(height: 24),
                        ActionButtonsRow(
                          onCheckIn: _handleCheckIn,
                          onCheckOut: _handleCheckOut,
                          onIzin: _handleIzin,
                          isCheckingIn: _isCheckingIn,
                          isCheckingOut: _isCheckingOut,
                          absenData: _absenData,
                          currentPosition: _currentPosition,
                          currentAddress: _currentAddress,
                        ),
                        const SizedBox(height: 24),
                        AttendanceSummary(absenData: _absenData),
                        const SizedBox(height: 200),
                      ]),
                    ),
                  ),
                ],
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.2,
                minChildSize: 0.2,
                maxChildSize: 1,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            children: [
                              SheetContent(
                                onHistoryDeleted: _reloadData,
                                riwayatAbsensiKey: _riwayatAbsensiKey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- PERUBAHAN UTAMA DI SINI ---
  Widget _buildEnhancedLocationStatusCard() {
    // Jika user berada DI DALAM radius kantor, jangan tampilkan apa-apa (widget kosong)
    if (_isUserWithinOfficeRadius()) {
      return const SizedBox.shrink();
    }

    // Jika user berada DI LUAR radius kantor, tampilkan kartu peringatan
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4), // Selalu merah
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.red.shade400, // Selalu merah
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade500, // Selalu merah
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_disabled_rounded, // Selalu ikon non-aktif
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LUAR AREA PPKD', // Selalu teks non-aktif
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.red.shade700,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentPosition != null
                          ? 'Jarak: ${_getDistanceToOffice().toStringAsFixed(1)}m dari PPKD'
                          : 'Menunggu data lokasi...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade500, // Selalu merah
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'NON-AKTIF', // Selalu teks non-aktif
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50, // Selalu merah
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.shade200, // Selalu merah
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100, // Selalu merah
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_rounded, // Selalu ikon warning
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mohon Dekati Area PPKD', // Selalu teks non-aktif
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Batas maksimal: 50 meter dari kantor',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_currentPosition != null) ...[
            const SizedBox(height: 12),
            _buildDistanceProgressBar(),
          ],
        ],
      ),
    );
  }

  // Method untuk membuat Progress Bar jarak
  Widget _buildDistanceProgressBar() {
    final distance = _getDistanceToOffice();
    final maxDistance = 100.0; // Maksimal 100 meter untuk visualisasi
    final progress =
        (maxDistance - distance.clamp(0, maxDistance)) / maxDistance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Visualisasi Jarak',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${distance.toStringAsFixed(1)}m / 50m',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700, // Selalu merah
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade400,
                          Colors.red.shade600,
                        ], // Selalu merah
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * 0.5,
                    child: Container(
                      width: 2,
                      height: 8,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 8, height: 2, color: Colors.orange.shade600),
            const SizedBox(width: 4),
            Text(
              'Batas Area (50m)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
