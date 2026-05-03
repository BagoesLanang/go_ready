import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../utils/user_session.dart'; // <-- Panggil session buat tau siapa yg login

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentUniv;
  final String currentBio;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentUniv,
    required this.currentBio,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _univController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _univController = TextEditingController(text: widget.currentUniv);
    _bioController = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _univController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- FUNGSI SAVE KE MEMORI HP (DENGAN KUNCI UNIK) ---
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil ID user yang lagi login biar lacinya ngga ketuker
    final String uniqueId = prefs.getString('user_id') ?? prefs.getString('user_name') ?? 'unknown_user';

    // Simpan ketikan terbaru pake ID sebagai akhiran namanya (PENTING!)
    await prefs.setString('user_name_$uniqueId', _nameController.text);
    await prefs.setString('user_univ_$uniqueId', _univController.text);
    await prefs.setString('user_bio_$uniqueId', _bioController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile changes saved! 🚀'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, {
        'name': _nameController.text,
        'univ': _univController.text,
        'bio': _bioController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECEF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(label: 'Full Name', controller: _nameController),
            const SizedBox(height: 16),
            _buildTextField(label: 'University', controller: _univController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Bio', controller: _bioController, maxLines: 3),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}