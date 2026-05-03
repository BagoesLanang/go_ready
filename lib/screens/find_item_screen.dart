import 'package:flutter/material.dart';
import '../theme/colors.dart';

// 🔥 TAMBAHAN BACKEND
import '../services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class FindItemScreen extends StatefulWidget {
  const FindItemScreen({super.key});

  @override
  State<FindItemScreen> createState() => _FindItemScreenState();
}

class _FindItemScreenState extends State<FindItemScreen> {
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _foundItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    timeago.setLocaleMessages('id', timeago.IdMessages());

    loadItems(); // 🔥 ambil dari backend
  }

  // =========================
  // 🔥 FETCH BACKEND
  // =========================
  Future<void> loadItems() async {
    try {
      final data = await fetchTrip();

      print("DATA BACKEND: $data");

      // 🔥 convert backend → format UI lama
      List<Map<String, dynamic>> formatted = data.map((item) {
        return {
          'name': item['item_name'],
          'location': 'Last location unknown',
          'time': timeago.format(
            DateTime.parse(item['created_at']),
            locale: 'id',
          ),
          'icon': Icons.help_outline, // default icon
        };
      }).toList();

      setState(() {
        _allItems = formatted;
        _foundItems = formatted;
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR FETCH: $e");

      setState(() {
        _isLoading = false;
      });
    }
  }

  // =========================
  // 🔍 SEARCH (TETAP)
  // =========================
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];

    if (enteredKeyword.isEmpty) {
      results = _allItems;
    } else {
      results = _allItems
          .where((item) => item['name']
              .toString()
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEARCH BAR (TETAP)
                    TextField(
                      onChanged: (value) => _runFilter(value),
                      decoration: InputDecoration(
                        hintText: 'What are you looking for?',
                        hintStyle:
                            const TextStyle(color: AppColors.textSecondary),
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
                      ),
                    ),

                    const SizedBox(height: 32),

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
                      'View the last recorded time of your items.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔥 DATA LIST
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
                            '🎉 Semua barang sudah aman!',
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

  // =========================
  // UI CARD (TETAP)
  // =========================
  Widget _buildMissingItemCard({
    required String itemName,
    required String location,
    required String time,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}