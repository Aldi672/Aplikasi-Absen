import 'package:aplikasi_absen/api/get_api_absen.dart';
import 'package:aplikasi_absen/api/get_api_user.dart';
import 'package:aplikasi_absen/models/get_absen_today_models.dart'
    as AbsenToday;
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:aplikasi_absen/screens/pages_content/location_content.dart';
import 'package:aplikasi_absen/screens/pages_detail/get_history_screen.dart';
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
  final GlobalKey<State<LocationCard>> _locationCardKey =
      GlobalKey<State<LocationCard>>();

  GetUser? userData;
  AbsenToday.Data? _absenData;
  bool _isLoadingProfile = true;
  bool _isFetchingAttendance = true;
  bool _isCheckingIn = false; // State untuk loading saat check-in
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
      final data = await AttendanceService.getTodaysAttendance();
      if (mounted) {
        setState(() {
          _absenData = data.data;
        });
      }
    } catch (e) {
      // Tidak apa-apa jika ada error (misal: 404), artinya belum absen
      // Kita set _absenData menjadi null
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

  Future<void> _handleAttendanceAction({required String status}) async {
    setState(() {
      _isCheckingIn = true;
    });

    try {
      if (status == 'hadir') {
        // Logika untuk Absen Hadir (membutuhkan lokasi)
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

        await AttendanceService.checkIn(
          status: 'hadir',
          latitude: lat,
          longitude: lng,
          address: address,
        );
      } else if (status == 'izin') {
        // Logika untuk Izin (membutuhkan alasan dari dialog)
        final String? alasan = await _showIzinDialog();
        if (alasan == null || alasan.isEmpty) {
          // Jika pengguna membatalkan atau tidak mengisi alasan
          setState(() => _isCheckingIn = false);
          return; // Hentikan proses
        }

        await AttendanceService.checkIn(status: 'izin', alasanIzin: alasan);
      }

      // Setelah berhasil, refresh data dan tampilkan notifikasi
      await _fetchTodaysAttendance();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil mengirimkan status: $status"),
          backgroundColor: Colors.green,
        ),
      );
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

  // Method baru untuk menampilkan dialog Izin
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
                Navigator.pop(context); // Tutup dialog tanpa mengirim data
              },
            ),
            ElevatedButton(
              child: const Text('KIRIM'),
              onPressed: () {
                // Tutup dialog dan kirim teks dari controller
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

    if (_absenData == null) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10.0)],
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

    // Jika data ada, tampilkan
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10.0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Absensi Hari Ini (${DateFormat('EEEE, dd MMMM y', 'id_ID').format(_absenData!.attendanceDate)})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 20),
          _buildInfoRow(
            icon: Icons.login,
            label: "Check-in",
            value: _absenData!.checkInTime,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.logout,
            label: "Check-out",
            value: _absenData!.checkOutTime ?? "Belum check-out",
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.location_on,
            label: "Alamat Masuk",
            value: _absenData!.checkInAddress,
            color: Colors.blue,
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
                        // Row header Anda tetap sama
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

                  // Card Profil
                ],
              ),
              const SizedBox(height: 110), // Spasi agar tidak tertutup Card
              // Map Lokasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LocationCard(key: _locationCardKey),
              ),

              // Jam + Tombol
              // Widget untuk menampilkan data absen hari ini
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: _buildAbsenHariIniCard(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TOMBOL HADIR
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
                                _absenData?.checkInTime != null)
                        ? null // Disable jika sedang loading atau sudah absen
                        : () => _handleAttendanceAction(status: 'hadir'),
                    icon: const Icon(Icons.touch_app, color: Colors.white),
                    label: const Text(
                      "HADIR",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // TOMBOL IZIN BARU
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
                                _absenData?.checkInTime != null)
                        ? null // Disable jika sedang loading atau sudah absen
                        : () => _handleAttendanceAction(status: 'izin'),
                    icon: const Icon(Icons.edit_document, color: Colors.white),
                    label: const Text(
                      "IZIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {}, // Logika untuk pulang
                    child: const Text(
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

              // Beri ruang kosong di bawah agar bisa di-scroll sampai sheet tidak menutupi tombol
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AttendanceItem(
                      date: 'Kamis, 14 Desember 2022',
                      time: '15:56',
                      status: 'Pending',
                      type: 'Absen Masuk',
                    ),
                    SizedBox(height: 16),
                    AttendanceItem(
                      date: 'Kamis, 14 Desember 2022',
                      time: '15:56',
                      status: 'Pending',
                      type: 'Absen Keluar',
                    ),
                    SizedBox(height: 16),
                    AttendanceItem(
                      date: 'Kamis, 14 Desember 2022',
                      time: '15:56',
                      status: 'Pending',
                      type: 'Absen Keluar',
                    ),
                    SizedBox(height: 16),
                    AttendanceItem(
                      date: 'Kamis, 14 Desember 2022',
                      time: '15:56',
                      status: 'Pending',
                      type: 'Absen Keluar',
                    ),
                    SizedBox(height: 16),
                    AttendanceItem(
                      date: 'Kamis, 14 Desember 2022',
                      time: '15:56',
                      status: 'Pending',
                      type: 'Absen Keluar',
                    ),
                    SizedBox(height: 16),
                    AttendanceItem(
                      date: 'Kamis, 14 Desember 2022',
                      time: '15:56',
                      status: 'Pending',
                      type: 'Absen Keluar',
                    ),
                    SizedBox(height: 16),
                    AttendanceItem(
                      date: 'Kamis, 14 Desember 2022',
                      time: '15:56',
                      status: 'Pending',
                      type: 'Absen Keluar',
                    ),
                    SizedBox(height: 90),
                    AttendanceItem(
                      date: 'Kamis, 14 Desember 2022',
                      time: '15:56',
                      status: 'Pending',
                      type: 'Absen Keluar',
                    ),
                  ],
                ),
              ),
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
                  children: [
                    // Panggil konten sheet Anda dari file lain
                    SheetContent(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 🔹 Widget kecil untuk Statistik
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(label),
      ],
    );
  }
}

// 🔹 Widget Riwayat
class _HistoryItem extends StatelessWidget {
  final String date;
  final String status;

  const _HistoryItem({required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.article_outlined, color: Colors.purple),
        title: Text(date),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Pending", style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(status, style: const TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }
}
