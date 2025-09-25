import 'package:aplikasi_absen/api/get_api_user.dart';
import 'package:aplikasi_absen/screens/pages_akun/get_register_screen.dart';
import 'package:aplikasi_absen/screens/pages_akun/get_reset_password.dart';
import 'package:aplikasi_absen/screens/pages_detail/get_dashboard_screen.dart';
import 'package:flutter/material.dart';

// === WIDGET UTAMA HALAMAN LOGIN ===
class GetLoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const GetLoginScreen({super.key});

  @override
  State<GetLoginScreen> createState() => _GetLoginScreenState();
}

class _GetLoginScreenState extends State<GetLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // State untuk mengontrol visibilitas password
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    // Validasi input tidak kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Tampilkan loading indicator
    });

    try {
      // Panggil service API untuk login
      await AuthService.loginUser(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Jika berhasil, navigasi ke halaman utama
      // pushAndRemoveUntil akan menghapus semua halaman sebelumnya (user tidak bisa kembali ke login)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GetDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      // Tampilkan pesan error jika login gagal
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false; // Sembunyikan loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk layout yang responsif
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              _buildHeaderWave(size),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Spacer(flex: 3),
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

  Widget _buildHeaderWave(Size size) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: size.height * 0.4,
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
                "Addsi",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
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
          controller: _emailController, // Sambungkan controller
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration('Email', Icons.email_outlined),
        ),
        const SizedBox(height: 16),
        // Password
        TextField(
          controller: _passwordController, // Sambungkan controller
          keyboardType: TextInputType.visiblePassword,
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordPage(),
                ),
              );
            },
            child: const Text("Forgot Password?"),
          ),
        ),
        const SizedBox(height: 16),
        // Tombol Login
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
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
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Text(
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
