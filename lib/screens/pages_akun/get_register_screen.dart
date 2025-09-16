import 'package:aplikasi_absen/api/get_api_user.dart';
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GetRegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const GetRegisterScreen({super.key});

  @override
  State<GetRegisterScreen> createState() => _GetRegisterScreenState();
}

class _GetRegisterScreenState extends State<GetRegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedGender;
  int? _selectedBatchId;
  int? _selectedTrainingId;

  // Data batch dan training yang akan diambil dari API
  List<Batch> _batchOptions = [];
  List<Training> _trainingOptions = [];
  Map<int, String> _batchMap = {}; // Map untuk menyimpan id dan nama batch
  Map<int, String> _trainingMap =
      {}; // Map untuk menyimpan id dan nama training

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mendapatkan data batch dan training
    _loadBatchAndTrainingData();
  }

  // Fungsi untuk mendapatkan data batch dan training dari API
  Future<void> _loadBatchAndTrainingData() async {
    // Dalam implementasi nyata, ini akan memanggil API untuk mendapatkan data
    // Untuk sementara kita buat data dummy sesuai dengan struktur model

    setState(() {
      // Data batch contoh
      _batchOptions = [
        Batch(
          id: 1,
          batchKe: "Batch 01",
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 12, 31),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Batch(
          id: 2,
          batchKe: "Batch 02",
          startDate: DateTime(2023, 2, 1),
          endDate: DateTime(2023, 12, 31),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Batch(
          id: 3,
          batchKe: "Batch 03",
          startDate: DateTime(2023, 3, 1),
          endDate: DateTime(2023, 12, 31),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Data training contoh
      _trainingOptions = [
        Training(
          id: 1,
          title: "Flutter Development",
          description: "Pelatihan pengembangan aplikasi Flutter",
          participantCount: 30,
          standard: "Intermediate",
          duration: 90,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Training(
          id: 2,
          title: "UI/UX Design",
          description: "Pelatihan desain antarmuka pengguna",
          participantCount: 25,
          standard: "Beginner",
          duration: 60,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Buat mapping untuk dropdown
      _batchMap = {for (var batch in _batchOptions) batch.id!: batch.batchKe!};
      _trainingMap = {
        for (var training in _trainingOptions) training.id!: training.title!,
      };
    });
  }

  Future<void> _register() async {
    // Validasi form
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedGender == null ||
        _selectedBatchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua field yang wajib diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Simpan data user ke preferences
      await UserPreferences.saveUserData(response.data!.user!);
      await UserPreferences.saveUserEmail(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil: ${response.message}')),
      );

      // Navigasi ke halaman login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registrasi gagal: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Header
              const Text(
                "Buat Akun Baru",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Isi data diri Anda untuk mulai menggunakan aplikasi",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),

              // Form Registrasi
              // Nama Lengkap
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  "Nama Lengkap",
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 20),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("Email", Icons.email_outlined),
              ),
              const SizedBox(height: 20),

              // Jenis Kelamin
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(
                    value: 'Laki-laki',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: _inputDecoration("Jenis Kelamin", Icons.wc),
              ),
              const SizedBox(height: 20),

              // Batch
              DropdownButtonFormField<int>(
                value: _selectedBatchId,
                items: _batchMap.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBatchId = value;
                  });
                },
                decoration: _inputDecoration(
                  "Pilih Batch",
                  Icons.badge_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // Training (opsional)
              DropdownButtonFormField<int>(
                value: _selectedTrainingId,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Pilih Training (opsional)'),
                  ),
                  ..._trainingMap.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTrainingId = value;
                  });
                },
                decoration: _inputDecoration(
                  "Pilih Training",
                  Icons.school_outlined,
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: _inputDecoration("Password", Icons.lock_outline)
                    .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
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
              const SizedBox(height: 40),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C8DE0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "DAFTAR SEKARANG",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Link untuk Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sudah punya akun?"),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Masuk di sini",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C8DE0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2C8DE0)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
