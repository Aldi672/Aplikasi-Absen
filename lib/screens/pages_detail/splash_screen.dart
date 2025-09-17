// ignore_for_file: unused_local_variable

import 'package:aplikasi_absen/screens/pages_akun/get_login_screen.dart';
import 'package:aplikasi_absen/screens/pages_detail/get_dashboard_screen.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = '/Welcome';
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Cek apakah token ada di shared preferences
      String? token = await PreferenceHandler.getToken();

      // Tunggu 3 detik untuk menampilkan splash screen
      await Future.delayed(const Duration(seconds: 6));

      if (mounted) {
        if (token != null && token.isNotEmpty) {
          // Jika token ada, navigasi ke dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GetDashboardScreen()),
          );
        } else {
          // Jika token tidak ada, navigasi ke login
          await Future.delayed(const Duration(seconds: 6));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GetLoginScreen()),
          );
        }
      }
    } catch (e) {
      // Jika terjadi error, tetap navigasi ke login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GetLoginScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C8DE0),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Lottie.asset(
                'asset/images/foto/gps.json', // Pastikan file JSON ada di folder assets
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: 'Powered by ',
              style: const TextStyle(
                color: Color.fromARGB(255, 121, 117, 117),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'Aldi Kurniawan',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          // Loading indicator
        ],
      ),
    );
  }
}
