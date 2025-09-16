import 'package:aplikasi_absen/api/get_api_batch.dart';
import 'package:aplikasi_absen/api/get_api_trainings.dart';
import 'package:aplikasi_absen/api/get_api_user.dart';
import 'package:aplikasi_absen/models/get_list_bacth_models.dart';
import 'package:aplikasi_absen/models/get_list_trainings_models.dart';
import 'package:aplikasi_absen/utils/preference/get_preference_save_token.dart';
import 'package:flutter/material.dart';

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

  // --- PERUBAHAN DIMULAI DI SINI ---
  // Variabel state untuk menampung data dari API
  List<TitleBacth> _batchOptions = [];
  List<Datum> _trainingOptions = [];
  // --- PERUBAHAN SELESAI ---

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mendapatkan data batch dan training dari API saat halaman dimuat
    _loadInitialData();
  }

  // --- PERUBAHAN DIMULAI DI SINI ---
  // Fungsi baru untuk mengambil data batch dan training dari API secara online
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true; // Tampilkan loading indicator saat fetching data
    });

    try {
      // Mengambil data batch dan training secara bersamaan
      final results = await Future.wait([
        BatchService.getBatches(),
        TrainingService.getTrainings(),
      ]);

      final batchResponse = results[0] as Bacth;
      final trainingResponse = results[1] as Trainings;

      setState(() {
        _batchOptions = batchResponse.data ?? [];
        _trainingOptions = trainingResponse.data ?? [];
      });
    } catch (e) {
      // Tampilkan pesan error jika gagal mengambil data
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
    } finally {
      setState(() {
        _isLoading = false; // Hentikan loading indicator
      });
    }
  }
  // --- PERUBAHAN SELESAI ---

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
      // --- PERUBAHAN DIMULAI DI SINI ---
      // Mengirim semua data yang diperlukan ke API, termasuk ID batch dan training
      final response = await AuthService.registerUser(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        gender: _selectedGender,
        batchId: _selectedBatchId,
        trainingId: _selectedTrainingId, // Bisa null jika tidak dipilih
      );
      // --- PERUBAHAN SELESAI ---

      // Simpan data user ke preferences
      if (response.data?.user != null) {
        await UserPreferences.saveUserData(response.data!.user!);
        await UserPreferences.saveUserEmail(_emailController.text);
      }

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
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  "Nama Lengkap",
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("Email", Icons.email_outlined),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: _inputDecoration("Jenis Kelamin", Icons.wc),
              ),
              const SizedBox(height: 20),

              // --- PERUBAHAN DIMULAI DI SINI ---
              // Dropdown untuk Batch, mengambil data dari _batchOptions
              DropdownButtonFormField<int>(
                value: _selectedBatchId,
                decoration: _inputDecoration(
                  "Pilih Batch",
                  Icons.badge_outlined,
                ),
                items: _batchOptions.map((batch) {
                  return DropdownMenuItem<int>(
                    value: batch.id,
                    child: Text(batch.batchKe ?? 'Batch tidak diketahui'),
                  );
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedBatchId = value;
                  });
                },
              ),

              // --- PERUBAHAN SELESAI ---
              const SizedBox(height: 20),

              // --- PERUBAHAN DIMULAI DI SINI ---
              // Dropdown untuk Training (opsional), mengambil data dari _trainingOptions
              DropdownButtonFormField<int>(
                value: _selectedTrainingId,
                items: [
                  // Item pertama sebagai placeholder opsional
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Pilih Training (opsional)'),
                  ),
                  // Menyebarkan daftar training dari API
                  ..._trainingOptions.map((training) {
                    return DropdownMenuItem<int>(
                      value: training.id,
                      child: Text(training.title ?? 'Training tidak diketahui'),
                    );
                  }),
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

              // --- PERUBAHAN SELESAI ---
              const SizedBox(height: 20),
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
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
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
