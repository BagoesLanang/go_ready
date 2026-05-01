import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'checklist_screen.dart';
import 'find_item_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Nggak perlu Scaffold lagi karena udah dibungkus sama MainLayout
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Header (Logo & Bell Icon)
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
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppColors.primaryBlue,
                ),
                onPressed: () {
                  // Action notifikasi nanti di sini
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Greeting Text
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

          // Big Action Buttons
          _buildBigActionCard(
            title: "I'm Going Out",
            subtitle: "Start your preparation flow",
            color: AppColors.successGreen,
            icon: Icons.directions_run_rounded,
            onTap: () {
              // --- NAVIGASI KE CHECKLIST ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChecklistScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildBigActionCard(
            title: "I Forgot Something",
            subtitle: "Quick search & rescue",
            color: AppColors.primaryBlue,
            icon: Icons.search_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FindItemScreen()),
              );
            },
          ),
          const SizedBox(height: 32),

          // Quick Access Section
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
                  title: "History",
                  icon: Icons.history,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallActionCard(
                  title: "Nearby Locations",
                  icon: Icons.near_me_outlined,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mini Game Banner
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF3C090,
                ).withOpacity(0.4), // Warna soft orange
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
          const SizedBox(height: 24), // Spacing bawah
        ],
      ),
    );
  }

  // --- HELPER WIDGETS (Biar code di atas clean) ---

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
