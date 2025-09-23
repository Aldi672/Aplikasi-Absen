// lib/pages/forgot_password_page.dart

import 'package:aplikasi_absen/api/get_forgot_password.dart';
import 'package:aplikasi_absen/models/get_forgot_password_models.dart';
import 'package:aplikasi_absen/screens/pages_content/reset_password_page.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String routeName = '/forgot';
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  // ++ FUNGSI BARU UNTUK MENAMPILKAN DIALOG ++
  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("OTP Terkirim"),
          content: Text(
            "Kode OTP telah dikirim ke email $email. Silakan lanjutkan untuk mereset password.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Reset Sekarang"),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.push(
                  // Navigasi ke halaman reset
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPasswordPage(email: email),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleForgotPassword() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final email = _emailController.text.trim();

    // Validasi
    if (email.isEmpty) {
      setState(() {
        _isLoading = false;
        _message = "Email tidak boleh kosong!";
      });
      return;
    } else if (!email.contains("@") || !email.contains(".")) {
      setState(() {
        _isLoading = false;
        _message = "Format email tidak valid!";
      });
      return;
    }

    final ForgotPassword? result = await Forgot.forgotPassword(email);

    // --- MODIFIKASI DIMULAI DI SINI ---
    setState(() {
      _isLoading = false;
      if (result != null && result.message != null) {
        // Cek jika pesan mengandung kata 'berhasil'
        if (result.message!.toLowerCase().contains('berhasil')) {
          _showSuccessDialog(email); // Panggil dialog jika sukses
        } else {
          _message = result.message; // Tampilkan pesan error dari API
        }
      } else {
        _message = "Terjadi kesalahan, coba lagi!";
      }
    });
    // --- MODIFIKASI SELESAI DI SINI ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: const Color(0xff8A2D3B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Masukkan email akun Anda untuk reset password:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8A2D3B),
                ),
                onPressed: _isLoading ? null : _handleForgotPassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Kirim OTP"),
              ),
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  fontSize: 14,
                  // Pesan sukses tidak lagi ditampilkan di sini, hanya error
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
