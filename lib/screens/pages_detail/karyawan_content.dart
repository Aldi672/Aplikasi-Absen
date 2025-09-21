import 'package:flutter/material.dart';

class KaryawanContent extends StatelessWidget {
  const KaryawanContent({super.key});

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
