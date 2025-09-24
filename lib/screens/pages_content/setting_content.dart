import 'package:aplikasi_absen/screens/pages_akun/get_login_screen.dart';
import 'package:aplikasi_absen/screens/pages_content/edit_profile.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:flutter/material.dart';

class SettingContent extends StatelessWidget {
  final VoidCallback? onProfileUpdated;
  const SettingContent({super.key, this.onProfileUpdated});

  Future<void> _performLogout(BuildContext context) async {
    // Tampilkan dialog konfirmasi sebelum logout
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    // Jika pengguna menekan "Logout"
    if (confirmLogout == true) {
      try {
        await PreferenceHandler.clearAll();
        // Pastikan widget masih terpasang sebelum navigasi
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            GetLoginScreen.routeName,
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Setting Aplikasi",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Menggunakan widget kustom _SettingItemCard
          _SettingItemCard(
            title: "Edit Profile",
            subtitle: "Ubah nama, email, dan foto profil",
            icon: Icons.person_outline,
            iconBgColor: Colors.blue.shade100,
            iconColor: Colors.blue.shade800,
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                EditProfileScreen.routeName,
              );
              // Jika ada hasil dan onProfileUpdated tidak null, panggil callback
              if (result != null && onProfileUpdated != null) {
                onProfileUpdated!();
              }
            },
          ),

          const SizedBox(height: 16),
          // Logout dibuat sedikit berbeda untuk penekanan
          _SettingItemCard(
            title: "Logout",
            subtitle: "Keluar dari sesi aplikasi Anda",
            icon: Icons.exit_to_app,
            iconBgColor: Colors.red.shade100,
            iconColor: Colors.red.shade800,
            titleColor: Colors.red.shade800, // Warna teks judul diubah
            onTap: () => _performLogout(context),
          ),
        ],
      ),
    );
  }
}

// WIDGET KUSTOM UNTUK SETIAP ITEM SETTING
class _SettingItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              // Latar belakang ikon yang bulat
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              // Kolom untuk Title dan Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleColor ?? Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Ikon panah di ujung kanan
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
