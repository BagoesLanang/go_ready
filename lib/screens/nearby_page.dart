import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/colors.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  final List<String> _categories = ['Rumah', 'Kampus', 'Minimarket', 'ATM'];
  String _selectedCategory = 'Kampus';

  // Controller buat ngegerakin peta
  final MapController _mapController = MapController();

  // Kordinat Center Default (UPN Veteran Yogyakarta - Kampus 2 Babarsari)
  LatLng _userLocation = const LatLng(-7.7795, 110.4148);

  // Data lokasi sekarang di-update ke vibes Babarsari
  final Map<String, Map<String, dynamic>> _locationData = {
    'Rumah': {
      'name': 'Kos Dira (Babarsari)',
      'distance': '0.0 km',
      'address': 'Kawasan Tambakbayan / Babarsari',
      'status': 'Current Location',
      'icon': Icons.home_rounded,
      'color': Colors.blue,
      'coords': const LatLng(-7.7810, 110.4135),
    },
    'Kampus': {
      'name': 'UPN Kampus 2 Babarsari',
      'distance': '0.5 km',
      'address': 'Jl. Babarsari No.2, Tambakbayan',
      'status': 'Open • Closes 21:00',
      'icon': Icons.school_rounded,
      'color': AppColors.primaryBlue,
      'coords': const LatLng(-7.7795, 110.4148),
    },
    'Minimarket': {
      'name': 'Indomaret Babarsari',
      'distance': '0.2 km',
      'address': 'Jl. Babarsari Raya',
      'status': 'Open 24 Hours',
      'icon': Icons.store_mall_directory_rounded,
      'color': Colors.orange,
      'coords': const LatLng(-7.7800, 110.4140),
    },
    'ATM': {
      'name': 'ATM BCA Babarsari',
      'distance': '0.4 km',
      'address': 'Samping minimarket Babarsari',
      'status': 'Available',
      'icon': Icons.local_atm_rounded,
      'color': Colors.teal,
      'coords': const LatLng(-7.7790, 110.4155),
    },
  };

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  // Fungsi mutlak LBS buat narik lokasi asli lu
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      // Update titik Rumah lu jadi titik GPS asli biar real-time
      _locationData['Rumah']!['coords'] = _userLocation;
    });

    _mapController.move(_userLocation, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _locationData[_selectedCategory]!;

    return Scaffold(
      backgroundColor: const Color(0xFFE8ECEF),
      body: Stack(
        children: [
          // --- 1. REAL OPENSTREETMAP ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentData['coords'],
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.goready.app',
              ),
              MarkerLayer(
                markers: _categories.map((category) {
                  final data = _locationData[category]!;
                  final isSelected = category == _selectedCategory;
                  return Marker(
                    point: data['coords'],
                    width: isSelected ? 60 : 40,
                    height: isSelected ? 60 : 40,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        data['icon'],
                        color: data['color'],
                        size: isSelected ? 50 : 30,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // --- 2. TOP SECTION (App Bar & Chips) ---
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Search nearby places...',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Kategori Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            // Peta otomatis geser ke titik Babarsari yang diklik
                            _mapController.move(
                              _locationData[category]!['coords'],
                              17.0,
                            );
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- 3. BOTTOM INFO CARD ---
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: Container(
                key: ValueKey(_selectedCategory),
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: currentData['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            currentData['icon'],
                            color: currentData['color'],
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentData['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentData['address'],
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.directions_walk,
                                    size: 14,
                                    color: AppColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    currentData['distance'],
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color:
                                        currentData['status'] == 'Available' ||
                                            currentData['status'].contains(
                                              'Open',
                                            ) ||
                                            currentData['status'] ==
                                                'Current Location'
                                        ? AppColors.successGreen
                                        : AppColors.dangerRed,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    currentData['status'],
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _checkLocationPermission();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Updating location via GPS...',
                              ),
                              backgroundColor: AppColors.primaryBlue,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Update My Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
