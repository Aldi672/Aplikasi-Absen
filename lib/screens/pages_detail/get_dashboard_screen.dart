import 'package:aplikasi_absen/screens/pages_content/location_content.dart';
import 'package:aplikasi_absen/screens/pages_detail/get_history_screen.dart';
import 'package:aplikasi_absen/screens/pages_draggble/draggable_scrollable_sheet_screen.dart';
import 'package:flutter/material.dart';

class GetDashboardScreen extends StatelessWidget {
  static const String routeName = '/dashboard';
  const GetDashboardScreen({super.key});

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
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -100,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      // ... isi Card Anda tetap sama
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.teal,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Adena Ayu Putrikarso",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("Manager"),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                _StatBox(
                                  label: "Hadir",
                                  value: "28",
                                  color: Colors.green,
                                ),
                                _StatBox(
                                  label: "Sakit",
                                  value: "8",
                                  color: Colors.blue,
                                ),
                                _StatBox(
                                  label: "Izin",
                                  value: "3",
                                  color: Colors.orange,
                                ),
                                _StatBox(
                                  label: "Absen",
                                  value: "50",
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 110), // Spasi agar tidak tertutup Card
              // Map Lokasi
              Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: LocationCard(),
              ),

              // Jam + Tombol
              const Text(
                "07:23 AM",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("HADIR"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text("LAMPIRAN"),
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
