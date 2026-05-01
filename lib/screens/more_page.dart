import 'package:flutter/material.dart';
import '../theme/colors.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'More Options',
            style: TextStyle(
              fontSize: 28, 
              fontWeight: FontWeight.bold, 
              color: AppColors.textPrimary
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Customize your GoReady experience.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          // --- General Settings ---
          const Text(
            'GENERAL',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(icon: Icons.settings_outlined, title: 'App Settings'),
          _buildMenuCard(icon: Icons.color_lens_outlined, title: 'Theme Preferences'),
          _buildMenuCard(icon: Icons.language, title: 'Language'),
          
          const SizedBox(height: 24),
          
          // --- About Section ---
          const Text(
            'ABOUT',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(icon: Icons.info_outline, title: 'About GoReady'),
          _buildMenuCard(icon: Icons.star_border_rounded, title: 'Rate the App'),
          _buildMenuCard(icon: Icons.description_outlined, title: 'Terms of Service'),
        ],
      ),
    );
  }

  // --- Helper Widget Buat Menu Card ---
  Widget _buildMenuCard({required IconData icon, required String title}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
        onTap: () {
          // Dummy tap
        },
      ),
    );
  }
}