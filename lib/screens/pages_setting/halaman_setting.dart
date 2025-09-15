import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- MODEL DATA UNTUK RIWAYAT ABSENSI ---
// (Ini bisa dipisah ke file model sendiri jika proyek sudah besar)
class AbsensiHistory {
  final String date;
  final String status;
  AbsensiHistory({required this.date, required this.status});
}

// === WIDGET UTAMA HALAMAN SETTING ===
class HalamanSetting extends StatelessWidget {
  const HalamanSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Stack digunakan untuk menumpuk DraggableSheet di atas konten profil
      body: Stack(
        children: [
          // --- BAGIAN 1: KONTEN DI BELAKANG SHEET (PROFIL PENGGUNA) ---
          _buildUserProfile(),

          // --- BAGIAN 2: DRAGGABLE SCROLLABLE SHEET ---
          DraggableScrollableSheet(
            initialChildSize: 0.65, // Tinggi awal sheet (65% dari layar)
            minChildSize: 0.65, // Tinggi minimum sheet
            maxChildSize: 0.9, // Tinggi maksimum saat ditarik ke atas
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFDECEC), // Warna pink muda seperti di desain
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                // ListView agar konten di dalam sheet bisa di-scroll
                child: ListView(
                  controller:
                      scrollController, // WAJIB: hubungkan scroll controller
                  children: [
                    // Handle di atas sheet
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12.0),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Panggil konten di dalam sheet
                    _buildSheetContent(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan profil pengguna di bagian atas
  Widget _buildUserProfile() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      alignment: Alignment.topCenter,
      child: const Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=12',
            ), // Ganti dengan URL gambar profil
          ),
          SizedBox(height: 8),
          Text(
            'AdenaPutri@gmail.com',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun semua konten yang ada di dalam sheet
  Widget _buildSheetContent() {
    // Data dummy untuk riwayat absensi
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
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- MENU-MENU SETTING ---
          // (Dulu ini adalah Wrap, sekarang jadi daftar List)
          _MenuItem(
            icon: FontAwesomeIcons.solidUser,
            text: 'Informasi Pribadi',
            onTap: () {},
          ),
          _MenuItem(
            icon: FontAwesomeIcons.headset,
            text: 'Hubungi Kami',
            onTap: () {},
          ),
          _MenuItem(
            icon: FontAwesomeIcons.code,
            text: 'Pengembangan Aplikasi',
            onTap: () {},
          ),
          _MenuItem(
            icon: FontAwesomeIcons.shieldHalved,
            text: 'Kebijakan Aplikasi',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // --- RIWAYAT ABSENSI ---
          const Text(
            "Riwayat Absensi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Menampilkan daftar riwayat secara dinamis
          ...historyData.map((history) {
            return _HistoryItem(date: history.date, status: history.status);
          }).toList(),
          const SizedBox(height: 24),

          // --- TOMBOL LOGOUT ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// === WIDGET KECIL UNTUK ITEM MENU ===
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: FaIcon(icon, size: 18, color: Colors.blueAccent),
      ),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

// === WIDGET KECIL UNTUK ITEM RIWAYAT ABSENSI ===
class _HistoryItem extends StatelessWidget {
  final String date;
  final String status;
  const _HistoryItem({required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isMasuk = status.toLowerCase().contains('masuk');
    final Color statusColor = isMasuk ? Colors.green : Colors.orange;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: Colors.grey[500], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(date, style: const TextStyle(fontSize: 14))),
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
      ),
    );
  }
}
