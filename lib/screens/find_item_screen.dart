import 'package:flutter/material.dart';
import '../theme/colors.dart';

class FindItemScreen extends StatefulWidget {
  const FindItemScreen({super.key});

  @override
  State<FindItemScreen> createState() => _FindItemScreenState();
}

class _FindItemScreenState extends State<FindItemScreen> {
  // Master datanya
  final List<Map<String, dynamic>> _allItems = [
    {
      'name': 'Wallet',
      'location': 'Living Room Sofa',
      'time': '2 mins ago',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'name': 'Car Keys',
      'location': 'Kitchen Table',
      'time': '1 hour ago',
      'icon': Icons.key_rounded,
    },
    {
      'name': 'Glasses',
      'location': 'Bedroom Nightstand',
      'time': '3 hours ago',
      'icon': Icons.remove_red_eye_rounded,
    },
  ];

  // Tempat nyimpen data yang lagi ditampilin
  List<Map<String, dynamic>> _foundItems = [];

  @override
  void initState() {
    super.initState();
    _foundItems = _allItems;
  }

  // Logic filter
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allItems;
    } else {
      results = _allItems
          .where(
            (item) => item['name'].toString().toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ),
          )
          .toList();
    }

    setState(() {
      _foundItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find Your Item',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Custom
              TextField(
                onChanged: (value) => _runFilter(value),
                decoration: InputDecoration(
                  hintText: 'What are you looking for?',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.whiteCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Title Section
              const Text(
                'Last Known',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'View the last recorded time of your items.', // Teks di-adjust biar lebih pas
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Render list
              if (_foundItems.isNotEmpty)
                ..._foundItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildMissingItemCard(
                      itemName: item['name'],
                      location: item['location'],
                      time: item['time'],
                      icon: item['icon'],
                    ),
                  ),
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No items found 🥲',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget ---
  Widget _buildMissingItemCard({
    required String itemName,
    required String location,
    required String time,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        // Balikin jadi print doang
        print("Tapping $itemName");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dangerRed.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.dangerRed.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.dangerRed, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last seen: $location',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.dangerRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.dangerRed,
                  size: 24,
                ), // Ganti icon radar jadi pin lokasi
              ],
            ),
          ],
        ),
      ),
    );
  }
}
