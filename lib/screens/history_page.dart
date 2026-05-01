import 'package:flutter/material.dart';
import '../theme/colors.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preparation History',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: AppColors.textPrimary
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your past activities and forgotten items.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          
          // --- Dummy Data List History ---
          _buildHistoryCard(
            date: 'Today, 08:00 AM',
            title: 'Cryptography Exam',
            status: 'All clear',
            isSuccess: true,
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            date: 'Yesterday, 04:30 PM',
            title: 'Campus Event (Band Gig)',
            status: 'Forgot: Audio Cable',
            isSuccess: false,
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            date: 'May 28, 03:00 PM',
            title: 'Skatepark Session',
            status: 'All clear',
            isSuccess: true,
          ),
          const SizedBox(height: 16),
          _buildHistoryCard(
            date: 'May 25, 10:00 AM',
            title: 'Djarum Scholarship Interview',
            status: 'All clear',
            isSuccess: true,
          ),
          const SizedBox(height: 32), // Spacing bawah biar enak di-scroll
        ],
      ),
    );
  }

  // --- Helper Widget Buat Kartu History ---
  Widget _buildHistoryCard({
    required String date, 
    required String title, 
    required String status, 
    required bool isSuccess
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Status Bulat
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSuccess 
                  ? AppColors.successGreen.withOpacity(0.1) 
                  : AppColors.dangerRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: isSuccess ? AppColors.successGreen : AppColors.dangerRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Detail Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16, 
                    color: AppColors.textPrimary
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  date, 
                  style: const TextStyle(
                    fontSize: 12, 
                    color: AppColors.textSecondary
                  )
                ),
              ],
            ),
          ),
          
          // Status Text Kanan
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSuccess ? AppColors.successGreen : AppColors.dangerRed,
            ),
          ),
        ],
      ),
    );
  }
}