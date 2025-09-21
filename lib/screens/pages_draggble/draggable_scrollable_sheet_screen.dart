// Jangan lupa tambahkan import ini di bagian atas

import 'package:aplikasi_absen/screens/pages_content/setting_content.dart';
import 'package:aplikasi_absen/screens/pages_detail/jadwal_screen.dart';
import 'package:flutter/material.dart';

// --- MODEL DATA (Tidak berubah) ---
class AbsensiHistory {
  final String date;
  final String status;
  AbsensiHistory({required this.date, required this.status});
}

// === WIDGET UTAMA KONTEN SHEET ===
// Diubah menjadi StatefulWidget agar bisa mengelola konten dinamis
class SheetContent extends StatefulWidget {
  final VoidCallback? onProfileUpdated;
  const SheetContent({super.key, this.onProfileUpdated});

  @override
  State<SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<SheetContent> {
  String _activeContent = 'Riwayat';

  // Fungsi untuk mengubah konten yang ditampilkan
  void _updateContent(String contentName) {
    setState(() {
      // Jika ikon yang sama diklik lagi, kembali ke Riwayat Absensi
      if (_activeContent == contentName) {
        _activeContent = 'Riwayat';
      } else {
        _activeContent = contentName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Handle Sheet (tidak berubah) ---
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 20),

        // --- MENU IKON INTERAKTIF ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 16,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              // onTap sekarang memanggil _updateContent untuk mengubah state
              _MenuIcon(
                icon: Icons.calendar_today,
                label: 'Jadwal',
                color: Colors.blue,
                onTap: () => _updateContent('Jadwal'),
                isActive: _activeContent == 'Jadwal',
              ),
              _MenuIcon(
                icon: Icons.settings,
                label: 'Setting',
                color: Colors.purple.shade700,
                onTap: () => _updateContent('Setting'),
                isActive: _activeContent == 'Setting',
              ),
              _MenuIcon(
                icon: Icons.people,
                label: 'Karyawan',
                color: Colors.lightBlue.shade300,
                onTap: () => _updateContent('Karyawan'),
                isActive: _activeContent == 'Karyawan',
              ),
              _MenuIcon(
                icon: Icons.timer,
                label: 'Lembur',
                color: Colors.cyan.shade600,
                onTap: () => _updateContent('Lembur'),
                isActive: _activeContent == 'Lembur',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),

        // --- KONTEN DINAMIS ---
        // Widget di sini akan berganti sesuai state _activeContent
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: _buildDynamicContent(),
        ),
      ],
    );
  }

  // FUNGSI INI ADALAH KUNCINYA
  // Ia akan memilih widget mana yang akan ditampilkan
  Widget _buildDynamicContent() {
    switch (_activeContent) {
      case 'Setting':
        return const SettingContent(); // Tampilkan konten setting
      // case 'Karyawan':
      //   return const AbsenTodayView(); // Tampilkan konten karyawan

      default:
        return const RiwayatAbsensiContent(); // Tampilan default
    }
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const _MenuIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              // Tambahkan border jika ikon sedang aktif
              border: isActive ? Border.all(color: color, width: 2) : null,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
