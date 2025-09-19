import 'package:aplikasi_absen/screens/pages_akun/get_login_screen.dart';
// import 'package:aplikasi_absen/screens/pages_category/edit_profile_screen.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:flutter/material.dart';

class SettingContent extends StatelessWidget {
  final VoidCallback? onProfileUpdated;
  const SettingContent({super.key, this.onProfileUpdated});
  Future<void> _performLogout(BuildContext context) async {
    try {
      await PreferenceHandler.clearAll();
      Navigator.pushNamedAndRemoveUntil(
        context,
        GetLoginScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Konten untuk menu Setting (contoh)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Setting Aplikasi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text("Edit Profile"),
          trailing: const Icon(Icons.chevron_right),
          // onTap: () async {
          //   // 3. Tunggu hasil dari halaman edit profile
          //   final result = await Navigator.pushNamed(context, EditProfileScreen.routeName);

          //   // 4. Jika hasilnya true, panggil callback
          //   if (result == true) {
          //     onProfileUpdated?.call();
          //   }
          // },
        ),
        const ListTile(
          leading: Icon(Icons.lock),
          title: Text("Privasi & Keamanan"),
        ),
        const ListTile(leading: Icon(Icons.language), title: Text("Bahasa")),
        ListTile(
          leading: const Icon(Icons.exit_to_app, color: Colors.red),
          title: const Text("Logout", style: TextStyle(color: Colors.red)),
          onTap: () => _performLogout(context),
        ),
      ],
    );
  }
}
