import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // --- 1. Placeholder Map Background ---
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            // Bikin pattern grid simple biar kerasa kayak peta yang lagi loading
            image: DecorationImage(
              image: const NetworkImage(
                  'https://www.transparenttextures.com/patterns/graphy.png'),
              repeat: ImageRepeat.repeat,
              colorFilter: ColorFilter.mode(
                AppColors.primaryBlue.withOpacity(0.1),
                BlendMode.srcIn,
              ),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'Map View\n(Integration Coming Soon)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.withOpacity(0.6), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // --- 2. Floating Header (Search) ---
        Positioned(
          top: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.whiteCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search nearby items...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: AppColors.primaryBlue),
              ),
            ),
          ),
        ),

        // --- 3. Floating Bottom Cards ---
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildMapItemCard(
                  title: 'Laptop Bag',
                  distance: '50m away',
                  location: 'Campus Library',
                  icon: Icons.backpack_outlined,
                ),
                const SizedBox(width: 16),
                _buildMapItemCard(
                  title: 'Water Bottle',
                  distance: '120m away',
                  location: 'Coffee Shop',
                  icon: Icons.water_drop_outlined,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Widget Buat Floating Card ---
  Widget _buildMapItemCard({
    required String title,
    required String distance,
    required String location,
    required IconData icon,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            location,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.dangerRed),
              const SizedBox(width: 4),
              Text(
                distance,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.dangerRed),
              ),
            ],
          ),
        ],
      ),
    );
  }
}