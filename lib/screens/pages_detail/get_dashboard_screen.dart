import 'package:aplikasi_absen/api/get_api_absen.dart';
import 'package:aplikasi_absen/api/get_api_user.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart'
    as AbsenToday;
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:aplikasi_absen/screens/pages_content/location_content.dart';
import 'package:aplikasi_absen/screens/pages_content/statistic_display_content.dart';
import 'package:aplikasi_absen/screens/pages_draggble/draggable_scrollable_sheet_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GetDashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const GetDashboardScreen({super.key});

  @override
  State<GetDashboardScreen> createState() => _GetDashboardScreenState();
}

class _GetDashboardScreenState extends State<GetDashboardScreen> {
  final DateTime _tanggalAbsensi = DateTime.now();
  final GlobalKey<State<LocationCard>> _locationCardKey =
      GlobalKey<State<LocationCard>>();

  GetUser? userData;
  AbsenToday.Data? _absenData;
  bool _isLoadingProfile = true;
  bool _isFetchingAttendance = true;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await _fetchUserData();
    await _fetchTodaysAttendance();
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
    setState(() {
      _isCheckingIn = true;
    });

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
        checkInLocation: "Lokasi Check-in",
        checkInAddress: address,
      );

      if (result != null) {
        await _fetchTodaysAttendance();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil check-in pada ${result.data?.checkInTime}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Gagal melakukan check-in");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  Future<void> _handleCheckOut() async {
    setState(() {
      _isCheckingOut = true;
    });

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

      final result = await AbsenAPI.checkOut(
        checkOutLat: lat,
        checkOutLng: lng,
        checkOutLocation: "Lokasi Check-out",
        checkOutAddress: address,
      );

      if (result != null) {
        await _fetchTodaysAttendance();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Berhasil check-out pada ${result.data?.checkOutTime}",
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Gagal melakukan check-out");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCheckingOut = false;
      });
    }
  }

  // Fungsi baru untuk menangani pengajuan izin
  Future<void> _handleIzin() async {
    final String? alasan = await _showIzinDialog();
    if (alasan == null || alasan.isEmpty) {
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final result = await AbsenAPI.submitIzin(alasanIzin: alasan);

      if (result != null) {
        await _fetchTodaysAttendance();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil mengajukan izin"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception("Gagal mengajukan izin");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCheckingIn = false;
      });
    }
  }

  // Fungsi untuk menampilkan dialog alasan izin
  Future<String?> _showIzinDialog() {
    final TextEditingController alasanController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajukan Izin'),
          content: TextField(
            controller: alasanController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Masukkan alasan Anda di sini',
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('BATAL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('KIRIM'),
              onPressed: () {
                Navigator.pop(context, alasanController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAbsenHariIniCard() {
    if (_isFetchingAttendance) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Cek jika _absenData benar-benar tidak ada
    if (_absenData == null) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10.0)],
        ),
        child: const Center(
          child: Text(
            "Anda belum melakukan absensi hari ini.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Tampilan untuk status 'izin'
    if (_absenData!.status == 'izin') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10.0)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              icon: Icons.pending_actions,
              label: "Status Absensi",
              value: "IZIN",
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.info_outline,
              label: "Alasan Izin",
              // Menggunakan operator '??' untuk memberikan nilai default jika null
              value: _absenData?.alasanIzin ?? 'Tidak ada keterangan izin.',
              color: Colors.orange,
            ),
          ],
        ),
      );
    }

    // Tampilan default untuk absensi hadir
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10.0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.login,
            label: "Check-in",
            // Menggunakan operator '??'
            value: _absenData!.checkInTime ?? "Belum check-in",
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.logout,
            label: "Check-out",
            // Menggunakan operator '??'
            value: _absenData!.checkOutTime ?? "Belum check-out",
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.location_on,
            label: "Alamat Masuk",
            // Menggunakan operator '??'
            value: _absenData!.checkInAddress ?? "Tidak tersedia",
            color: Colors.blue,
          ),
          // Gunakan 'if' untuk mengecek null sebelum memanggil widget
          if (_absenData!.checkOutAddress != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.location_on,
              label: "Alamat Keluar",
              // Sudah aman karena sudah dicek di 'if' di atasnya
              value: _absenData!.checkOutAddress!,
              color: Colors.orange,
            ),
          ],
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: "Status",
            // Menggunakan operator '??'
            value: _absenData!.status ?? "Tidak diketahui",
            color: _absenData!.status == 'hadir' ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // Bagian Header
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8CD6F7),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu, color: Colors.white),
                            SizedBox(width: 50),
                            Image.asset(
                              'asset/images/foto/logo1.png',
                              height: 50,
                            ),
                            Text(
                              "Attendify",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 50),
                            Icon(Icons.notifications, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -100,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      (userData?.data?.profilePhotoUrl ?? '')
                                          .isNotEmpty
                                      ? NetworkImage(
                                          userData!.data!.profilePhotoUrl!,
                                        )
                                      : null,
                                  child:
                                      (userData?.data?.profilePhotoUrl ?? '')
                                          .isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.teal,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData?.data?.name ??
                                          "Nama tidak tersedia",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData?.data?.batchKe ??
                                              "Batch Tidak Tersedia",
                                        ),
                                        Text(
                                          userData?.data?.trainingTitle ??
                                              "Trainings Tidak di Temukan",
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            StatistikDisplay(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 110),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LocationCard(key: _locationCardKey),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: _buildAbsenHariIniCard(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed:
                        _isCheckingIn ||
                            (_absenData != null &&
                                _absenData!.checkInTime != null)
                        ? null
                        : _handleCheckIn,
                    icon: _isCheckingIn
                        ? Container(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.touch_app, color: Colors.white),
                    label: Text(
                      _isCheckingIn ? "PROSES..." : "HADIR",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed:
                        _isCheckingIn ||
                            (_absenData != null &&
                                _absenData!.checkInTime != null)
                        ? null
                        : _handleIzin,
                    icon: Icon(Icons.edit_document, color: Colors.white),
                    label: Text(
                      "IZIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _absenData != null &&
                              _absenData!.checkInTime != null &&
                              _absenData!.checkOutTime == null
                          ? Colors.green
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed:
                        (_absenData != null &&
                            _absenData!.checkInTime != null &&
                            _absenData!.checkOutTime == null &&
                            !_isCheckingOut)
                        ? _handleCheckOut
                        : null,
                    child: _isCheckingOut
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "PULANG",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Lokasi anda saat ini: Kantor",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(16.0),
                child: Column(children: []),
              ),
              SizedBox(height: 100),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.2,
            maxChildSize: 1,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 3.0),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  children: [SheetContent()],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
