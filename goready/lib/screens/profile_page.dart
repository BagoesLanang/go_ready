import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../utils/user_session.dart';
import 'login_screen.dart';
import 'edit_profile.dart';
import 'biometric_setup.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = ' ';
  String _userUniv = ' ';
  String _userBio = ' ';

  @override
  void initState() {
    super.initState();
    _loadProfileData(); 
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String uniqueId = prefs.getString('user_id') ?? prefs.getString('user_name') ?? 'unknown_user';
    
    final String defaultName = prefs.getString('user_name') ?? 'Guest User';

    setState(() {
      _userName = prefs.getString('user_name_$uniqueId') ?? defaultName;
      _userUniv = prefs.getString('user_univ_$uniqueId') ?? '';
      _userBio = prefs.getString('user_bio_$uniqueId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logofix.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _userName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            '$_userUniv\n$_userBio',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 40),
          _buildProfileMenu(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    currentName: _userName,
                    currentUniv: _userUniv,
                    currentBio: _userBio,
                  ),
                ),
              );

              if (result != null) {
                await _loadProfileData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile UI updated! ✨'),
                      backgroundColor: AppColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
          _buildProfileMenu(
            icon: Icons.fingerprint,
            title: 'Biometric Login Setup',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BiometricSetupPage()),
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                
                await prefs.remove('user_id'); 
                await prefs.remove('user_name'); 
                
                UserSession.clear();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.dangerRed),
              label: const Text(
                'Log Out',
                style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.dangerRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileMenu({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.white,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryBlue),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}