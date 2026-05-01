import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'ready_to_go_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  // Data bohongan buat nyimpen status checklist
  final Map<String, bool> _items = {
    'Wallet': true, // Dibuat true dari awal biar kelihatan versi checked-nya
    'Phone': false,
    'Charger': false,
    'Keys': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.primaryBlue,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Checklist Before You Go',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap items as you pack them to ensure nothing is left behind.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Checklist Items
              ..._items.entries
                  .map((entry) => _buildChecklistItem(entry.key, entry.value))
                  .toList(),

              const SizedBox(height: 32),

              // Smart Suggestions Section
              Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: Color(0xFFD97706),
                    size: 20,
                  ), // Warna orange/gold
                  const SizedBox(width: 8),
                  const Text(
                    'Smart Suggestions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Suggestions Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSuggestionCard(
                      title: "Don't forget your campus card",
                      subtitle: "Required for building access today.",
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSuggestionCard(
                      title: "Bring a jacket",
                      subtitle: "Temperatures expected to drop by evening.",
                      icon: Icons.cloud_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40), // Spacing buat scroll
            ],
          ),
        ),
      ),

      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(color: AppColors.background),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReadyToGoScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Confirm Ready',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Widget buat bikin kotak checklist-nya
  Widget _buildChecklistItem(String title, bool isChecked) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _items[title] = !_items[title]!; // Toggle status true/false
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          // Kalau checked warnanya ijo tipis, kalau nggak putih biasa
          color: isChecked
              ? AppColors.successGreen.withOpacity(0.1)
              : AppColors.whiteCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked
                ? AppColors.successGreen.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isChecked
                  ? AppColors.successGreen
                  : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget buat kotak Smart Suggestions
  Widget _buildSuggestionCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
