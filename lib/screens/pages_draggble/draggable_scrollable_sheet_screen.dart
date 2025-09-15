// Jangan lupa tambahkan import ini di bagian atas
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- MODEL DATA (Tidak berubah) ---
class AbsensiHistory {
  final String date;
  final String status;
  AbsensiHistory({required this.date, required this.status});
}

// === WIDGET UTAMA KONTEN SHEET ===
// Diubah menjadi StatefulWidget agar bisa mengelola konten dinamis
class SheetContent extends StatefulWidget {
  const SheetContent({super.key});

  @override
  State<SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<SheetContent> {
  // --- STATE MANAGEMENT ---
  // Variabel untuk melacak konten mana yang sedang aktif.
  // 'Riwayat' adalah tampilan default.
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
              _MenuIcon(
                icon: Icons.receipt_long,
                label: 'Penggajian',
                color: Colors.teal.shade300,
                onTap: () => _updateContent('Penggajian'),
                isActive: _activeContent == 'Penggajian',
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
        return const _SettingContent(); // Tampilkan konten setting
      case 'Karyawan':
        return const _KaryawanContent(); // Tampilkan konten karyawan
      // Tambahkan case lain jika diperlukan
      // case 'Jadwal':
      //   return const _JadwalContent();
      default:
        return const _RiwayatAbsensiContent(); // Tampilan default
    }
  }
}

// === KONTEN-KONTEN DINAMIS ===
// Kita pecah setiap konten agar rapi

class _RiwayatAbsensiContent extends StatelessWidget {
  const _RiwayatAbsensiContent();

  @override
  Widget build(BuildContext context) {
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
      AbsensiHistory(date: "Jumat, 12 Sep 2025 : 07:55", status: "Absen Masuk"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Riwayat Absensi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...historyData.map((history) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _HistoryItem(date: history.date, status: history.status),
          );
        }).toList(),
      ],
    );
  }
}

class _SettingContent extends StatelessWidget {
  const _SettingContent();

  @override
  Widget build(BuildContext context) {
    // Konten untuk menu Setting (contoh)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Setting Aplikasi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ListTile(leading: Icon(Icons.notifications), title: Text("Notifikasi")),
        ListTile(leading: Icon(Icons.lock), title: Text("Privasi & Keamanan")),
        ListTile(leading: Icon(Icons.language), title: Text("Bahasa")),
      ],
    );
  }
}

class _KaryawanContent extends StatelessWidget {
  const _KaryawanContent();

  @override
  Widget build(BuildContext context) {
    // Konten untuk menu Karyawan (contoh)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Daftar Karyawan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ListTile(
          leading: CircleAvatar(child: Text("AP")),
          title: Text("Adena Putri"),
          subtitle: Text("Manager"),
        ),
        ListTile(
          leading: CircleAvatar(child: Text("BW")),
          title: Text("Budi Waseso"),
          subtitle: Text("Staff IT"),
        ),
        ListTile(
          leading: CircleAvatar(child: Text("CS")),
          title: Text("Citra Lestari"),
          subtitle: Text("Staff HRD"),
        ),
      ],
    );
  }
}

// === WIDGET KECIL UNTUK ITEM MENU IKON ===
// Diubah agar bisa diklik dan menunjukkan state aktif
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

// Widget _HistoryItem tidak perlu diubah
// ... (tambahkan widget _HistoryItem dari kode sebelumnya)
class _HistoryItem extends StatelessWidget {
  final String date;
  final String status;
  // ... (kode sama seperti sebelumnya)

  const _HistoryItem({required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isMasuk = status.toLowerCase().contains('masuk');
    final Color statusColor = isMasuk ? Colors.green : Colors.orange;

    return Row(
      children: [
        Icon(Icons.access_time_filled, color: Colors.grey[400], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            date,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
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
    );
  }
}
