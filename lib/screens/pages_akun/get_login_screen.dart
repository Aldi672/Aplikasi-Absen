import 'package:aplikasi_absen/screens/pages_akun/get_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Tambahkan package ini di pubspec.yaml

// === WIDGET UTAMA HALAMAN LOGIN ===
class GetLoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const GetLoginScreen({super.key});

  @override
  State<GetLoginScreen> createState() => _GetLoginScreenState();
}

class _GetLoginScreenState extends State<GetLoginScreen> {
  // State untuk mengontrol visibilitas password
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk layout yang responsif
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // --- Latar Belakang & Header Melengkung ---
              _buildHeaderWave(size),

              // --- Form Login ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Spacer(flex: 4),
                    _buildLoginForm(),
                    SizedBox(height: 5),
                    _buildSignupLink(),
                    Spacer(flex: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BAGIAN-BAGIAN UI ---

  Widget _buildHeaderWave(Size size) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: size.height * 0.4, // Tinggi header 40% dari layar
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A86FF), Color(0xFF2C8DE0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ganti dengan path logo Anda
              Image.asset(
                "asset/images/foto/logo1.png",
                height: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                "Attendify",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 50,
              ), // Spasi agar tidak terlalu dekat dengan form
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Username
        TextField(
          decoration: _inputDecoration('Username', Icons.person_outline),
        ),
        const SizedBox(height: 16),
        // Password
        TextField(
          obscureText: !_isPasswordVisible,
          decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Lupa Password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text("Forgot Password?"),
          ),
        ),
        const SizedBox(height: 16),
        // Tombol Login
        ElevatedButton(
          onPressed: () {
            // Aksi login
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A86FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            shadowColor: const Color(0xFF3A86FF).withOpacity(0.4),
          ),
          child: const Text(
            "LOG IN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account? "),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GetRegisterScreen(),
                ),
              );
            },
            child: Text(
              "Sign Up",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A86FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER UNTUK STYLING ---

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A86FF), width: 2),
      ),
    );
  }
}

// === CUSTOM CLIPPER UNTUK MEMBUAT BENTUK GELOMBANG ===
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8); // Mulai dari bawah kiri

    // Kurva pertama
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.85);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Kurva kedua
    var secondControlPoint = Offset(size.width * 3 / 4, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.8);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0); // Ke kanan atas
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
