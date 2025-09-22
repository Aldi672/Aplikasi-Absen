// dashboard_screen.dart
import 'package:aplikasi_absen/api/get_api_absen.dart';
import 'package:aplikasi_absen/api/get_api_user.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart'
    as AbsenToday;
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:aplikasi_absen/screens/pages_content/location_content.dart';
import 'package:aplikasi_absen/screens/pages_content/statistic_display_content.dart';
import 'package:aplikasi_absen/screens/pages_detail/jadwal_screen.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/action_buttons_row.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/attendance_status_card.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/attendance_summary.dart';

import 'package:aplikasi_absen/screens/pages_detail/view_content/dashboard_utils.dart';
import 'package:aplikasi_absen/screens/pages_detail/view_content/user_profile_card.dart';
import 'package:aplikasi_absen/screens/pages_draggble/draggable_scrollable_sheet_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import widget terpisah

class GetDashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const GetDashboardScreen({super.key});

  @override
  State<GetDashboardScreen> createState() => _GetDashboardScreenState();
}

class _GetDashboardScreenState extends State<GetDashboardScreen>
    with TickerProviderStateMixin {
  final DateTime _tanggalAbsensi = DateTime.now();
  final GlobalKey<State<LocationCard>> _locationCardKey =
      GlobalKey<State<LocationCard>>();
  final GlobalKey<StatistikDisplayState> _statistikDisplayKey =
      GlobalKey<StatistikDisplayState>();
  final GlobalKey<RiwayatAbsensiContentState> _riwayatAbsensiKey =
      GlobalKey<RiwayatAbsensiContentState>();

  GetUser? userData;
  AbsenToday.Data? _absenData;
  bool _isLoadingProfile = true;
  bool _isFetchingAttendance = true;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  String? _currentAddress;
  String _errorMessage = '';

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
      if (mounted) {
        setState(() {
          userData = data;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _fetchTodaysAttendance() async {
    if (mounted) {
      setState(() {
        _isFetchingAttendance = true;
      });
    }
    try {
      final data = await AbsenAPI.getAbsenToday();
      if (mounted) {
        setState(() {
          _absenData = data?.data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _absenData = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingAttendance = false;
        });
      }
    }
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isCheckingIn = true);

    try {
      final locationState = _locationCardKey.currentState as dynamic;
      final lat = locationState.currentPosition.latitude;
      final lng = locationState.currentPosition.longitude;
      final address = locationState.currentAddress;

      if (address.contains("Tekan tombol") ||
          address.contains("Gagal mendapatkan")) {
        throw Exception(
          "Lokasi belum didapatkan. Mohon tekan tombol 'Lokasi Terkini' terlebih dahulu.",
        );
      }

      final result = await AbsenAPI.checkInUser(
        checkInLat: lat,
        checkInLng: lng,
        checkInAddress: address,
      );

      if (result != null) {
        await _fetchTodaysAttendance();
        _riwayatAbsensiKey.currentState?.fetchHistory();
        DashboardUtils.showSuccessSnackBar(
          context,
          "Berhasil check-in pada ${result.data?.checkInTime}",
        );
      } else {
        throw Exception("Gagal melakukan check-in");
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
      final locationState = _locationCardKey.currentState as dynamic;
      final lat = locationState.currentPosition.latitude;
      final lng = locationState.currentPosition.longitude;
      final address = locationState.currentAddress;

      if (address.contains("Tekan tombol") ||
          address.contains("Gagal mendapatkan")) {
        throw Exception(
          "Lokasi belum didapatkan. Mohon tekan tombol 'Lokasi Terkini' terlebih dahulu.",
        );
      }

      final now = DateTime.now();
      final attendanceDate = DateFormat("yyyy-MM-dd").format(now);
      final checkOutTime = DateFormat("HH:mm").format(now);

      final result = await AbsenAPI.checkOutUser(
        attendanceDate: attendanceDate,
        checkOut: checkOutTime,
        checkOutLat: lat,
        checkOutLng: lng,
        checkOutAddress: address,
        status: "pulang",
      );

      if (result != null) {
        await _fetchTodaysAttendance();
        _riwayatAbsensiKey.currentState?.fetchHistory();
        DashboardUtils.showSuccessSnackBar(
          context,
          "Berhasil check-out pada ${result.data?.checkOutTime ?? checkOutTime}",
        );
      } else {
        throw Exception("Gagal melakukan check-out");
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
        await _fetchTodaysAttendance();
        _riwayatAbsensiKey.currentState?.fetchHistory();
        DashboardUtils.showSuccessSnackBar(
          context,
          "Berhasil mengajukan izin: ${result.data?.alasanIzin}",
        );
      } else {
        throw Exception("Gagal mengajukan izin");
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
      body: Container(
        // Background gradien biru ke hitam
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1565C0), // Biru tua
              Color(0xFF0D47A1), // Biru lebih gelap
              Color(0xFF1A237E), // Biru ungu gelap
              Color(0xFF000000), // Hitam
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Main Content
              CustomScrollView(
                slivers: [
                  // Header dengan SliverAppBar

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 20),

                        // User Profile Card
                        UserProfileCard(
                          userData: userData,
                          statistikDisplayKey: _statistikDisplayKey,
                          isLoading: _isLoadingProfile,
                          // checkInTime: _absenData?.checkInTime,
                        ),

                        const SizedBox(height: 24),

                        // Location Card
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
                          child: LocationCard(key: _locationCardKey),
                        ),

                        const SizedBox(height: 24),

                        // Attendance Status Card
                        AttendanceStatusCard(
                          absenData: _absenData,
                          isFetching: _isFetchingAttendance,
                        ),

                        const SizedBox(height: 24),

                        // Action Buttons
                        ActionButtonsRow(
                          onCheckIn: _handleCheckIn,
                          onCheckOut: _handleCheckOut,
                          onIzin: _handleIzin,
                          isCheckingIn: _isCheckingIn,
                          isCheckingOut: _isCheckingOut,
                          absenData: _absenData,
                          currentAddress: _currentAddress ?? "-",
                        ),

                        const SizedBox(height: 24),

                        // Attendance Summary
                        AttendanceSummary(absenData: _absenData),

                        const SizedBox(height: 200),
                      ]),
                    ),
                  ),
                ],
              ),

              // Draggable Bottom Sheet
              DraggableScrollableSheet(
                initialChildSize: 0.12,
                minChildSize: 0.12,
                maxChildSize: 0.9,
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
                        // Drag Handle
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Content
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
}
