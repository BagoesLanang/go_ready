import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ReadyToGoScreen extends StatelessWidget {
  const ReadyToGoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(), // Dorong konten ke tengah
              
              // Efek Glowing Checkmark
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.15), // Lingkaran luar glowing
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen, // Lingkaran dalem solid
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                "You're Ready to Go!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Subtitle
              const Text(
                "Everything is set up and saved securely. You are now prepared for your journey.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5, // Biar line spacing-nya persis kayak Figma
                ),
              ),
              
              const Spacer(), // Dorong tombol ke bawah
              
              // Finish Button
              SizedBox(
                width: double.infinity, // Biar tombolnya full width
                child: ElevatedButton(
                  onPressed: () {
                    // Balik ke halaman awal (Home/MainLayout) pake popUntil
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen, // Tombolnya ngikutin warna ijo success
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Finish', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40), // Spacing bawah biar nggak nabrak layar
            ],
          ),
        ),
      ),
    );
  }
}