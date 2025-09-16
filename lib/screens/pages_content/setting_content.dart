import 'package:flutter/material.dart';

class SettingContent extends StatelessWidget {
  const SettingContent();

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
