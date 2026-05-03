import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'checklist_screen.dart';
import 'find_item_screen.dart';
import 'mini_game_screen.dart';
import 'nearby_page.dart';
import 'chatbot_screen.dart'; // 🔥 IMPORT SCREEN CHATBOT LU DI SINI

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // 🔥 BUNGKUS PAKE SCAFFOLD BIAR BISA NAMBAHIN TOMBOL MENGAPUNG (FAB)
    return Scaffold(
      backgroundColor: Colors.transparent, // Biar background asli nggak rusak
      
      // 🔥 INI TOMBOL CHATBOT-NYA BROK
      floatingActionButton: FloatingActionButton(
        heroTag: "homeChatbotBtn", // PENTING: Biar gak bentrok hero tag-nya
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: const Color(0xFFD97706), // Warna gold/orange biar elegan
        elevation: 4,
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      
      // 🔥 BODY-NYA TETEP SAMA PERSIS KAYA PUNYA LU
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GoReady',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Hello,',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),

            const Text(
              'Ready to go?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 32),

            // 🔥 BUTTON 1 (TETAP)
            _buildBigActionCard(
              title: "I'm Going Out",
              subtitle: "Start your preparation flow",
              color: AppColors.successGreen,
              icon: Icons.directions_run_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChecklistScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 🔥 BUTTON 2 
            _buildBigActionCard(
              title: "I Forgot Something",
              subtitle: "Quick search & rescue", 
              color: AppColors.primaryBlue,
              icon: Icons.search_rounded, 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FindItemScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            const Text(
              'QUICK ACCESS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSmallActionCard(
                    title: "Nearby Locations",
                    icon: Icons.near_me_outlined,
                    onTap: () {
                      if (onNavigate != null) {
                        onNavigate!(2);
                      }
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // 🔥 OPTIONAL: kalau mau balikin History tab tinggal aktifin ini
                /*
                Expanded(
                  child: _buildSmallActionCard(
                    title: "History",
                    icon: Icons.history,
                    onTap: () {
                      if (onNavigate != null) {
                        onNavigate!(1);
                      }
                    },
                  ),
                ),
                */
              ],
            ),

            const SizedBox(height: 16),

            // 🔥 MINI GAME (TETAP)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MiniGameScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3C090).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3C090),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_esports,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mini Game',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF8B5A2B),
                          ),
                        ),
                        Text(
                          'Kill time while waiting',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B5A2B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // =========================
  // HELPER (TETAP)
  // =========================

  Widget _buildBigActionCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}