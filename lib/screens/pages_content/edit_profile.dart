import 'dart:convert';
import 'dart:io';

import 'package:aplikasi_absen/api/get_edit_profile.dart';
import 'package:aplikasi_absen/models/get_user_models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/Edit';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  GetUser? _userData;
  File? _selectedImage;

  final api = EditProfileApi();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await api.getEditProfile();
      if (user != null && user.data != null) {
        setState(() {
          _userData = user;
          _nameController.text = user.data!.name ?? "";
          _emailController.text = user.data!.email ?? "";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal ambil data: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final updated = await api.updateEditProfile(
        userId: _userData?.data?.id ?? 0,
        name: _nameController.text,
        email: _emailController.text,
        jenisKelamin: _userData?.data?.jenisKelamin ?? "Laki-laki",
      );

      if (updated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(updated.message ?? "Berhasil update profil")),
        );
        _loadProfile(); // refresh data
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // upload foto profil
  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);
    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final result = await api.updateProfilePhoto(base64Image);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?.message ?? "Foto berhasil diupdate")),
      );

      _loadProfile(); // refresh data profil
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal upload foto: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: _isLoading && _userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // FOTO PROFIL
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_userData?.data?.profilePhotoUrl != null
                                      ? NetworkImage(
                                          _userData!.data!.profilePhotoUrl!,
                                        )
                                      : const AssetImage("assets/avatar.png")
                                            as ImageProvider),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _pickPhoto,
                            child: const Text("Pilih Foto"),
                          ),
                          if (_selectedImage != null)
                            ElevatedButton(
                              onPressed: _uploadPhoto,
                              child: const Text("Upload Foto"),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Nama
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Name required" : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || !val.contains('@')
                          ? "Valid email required"
                          : null,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Save Changes"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
