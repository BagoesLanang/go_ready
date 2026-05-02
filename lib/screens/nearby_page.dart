import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Buat GPS Asli
import 'package:http/http.dart' as http; // Buat Nembak API
import 'dart:convert';
import '../theme/colors.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  String _selectedCategory = 'Kampus';
  
  LatLng? _userLocation; // Lokasi asli dari GPS
  bool _isLoading = true; // State buat loading map/API
  List<Marker> _poiMarkers = []; // List marker tempat yang udah ketarik API

  @override
  void initState() {
    super.initState();
    _getUserRealLocation(); // Begitu halaman dibuka, langsung cari GPS lu
  }

  // --- LOGIC 1: DAPETIN LOKASI ASLI DARI HARDWARE GPS ---
  Future<void> _getUserRealLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah GPS HP nyala
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Tolong nyalain GPS HP lu dulu brok!');
      return;
    }

    // Cek izin (Permission)
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Yah, izin lokasi ditolak.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showError('Izin lokasi diblokir permanen dari settingan HP lu.');
      return;
    }

    // Kalo izin aman, tarik koordinat asli dari satelit
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      // Kalo lokasi udah dapet, langsung tembak API buat nyari kategori pertama
      _fetchRealNearbyPlaces(_selectedCategory);
    }
  }

  // --- LOGIC 2: NEMBAK API OVERPASS BUAT NYARI TEMPAT NYATA ---
  Future<void> _fetchRealNearbyPlaces(String category) async {
    if (_userLocation == null) return;

    setState(() {
      _isLoading = true;
      _poiMarkers.clear(); // Bersihin marker lama
    });

    // Query cerdas pake Overpass API (Gratis & No Limit Keras)
    // Radius sekitar 2000-3000 meter (2-3 KM) dari lokasi lu
    String query = '[out:json];';
    if (category == 'ATM') {
      query += 'node["amenity"="atm"](around:2000, ${_userLocation!.latitude}, ${_userLocation!.longitude});';
    } else if (category == 'Minimarket') {
      query += 'node["shop"~"convenience|supermarket"](around:2000, ${_userLocation!.latitude}, ${_userLocation!.longitude});';
    } else if (category == 'Kampus') {
      query += 'node["amenity"~"university|college"](around:3000, ${_userLocation!.latitude}, ${_userLocation!.longitude});';
    }
    query += 'out;';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        List<Marker> newMarkers = [];
        
        // Looping data asli dari API dan ubah jadi Marker UI
        for (var element in elements) {
          final lat = element['lat'];
          final lon = element['lon'];
          // Ambil nama tempat kalo ada, kalo ngga ada kasih nama Unknown
          final name = element['tags'] != null && element['tags']['name'] != null 
              ? element['tags']['name'] 
              : 'Unknown $category';

          newMarkers.add(
            Marker(
              point: LatLng(lat, lon),
              width: 40,
              height: 40,
              child: Tooltip(
                message: name,
                child: const Icon(Icons.location_on, color: AppColors.primaryBlue, size: 36),
              ),
            ),
          );
        }

        if (mounted) {
          setState(() {
            _poiMarkers = newMarkers;
            _isLoading = false;
          });
        }
      } else {
        _showError('Gagal narik data dari server Maps.');
      }
    } catch (e) {
      _showError('Error jaringan: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECEF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Nearby Locations (Real)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _userLocation == null 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryBlue),
                SizedBox(height: 16),
                Text('Lagi nyari sinyal GPS lu nih...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          )
        : Column(
            children: [
              // --- TOP FILTER CATEGORY ---
              Container(
                height: 60,
                color: Colors.white,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: [
                    _buildFilterChip('Kampus'),
                    _buildFilterChip('Minimarket'),
                    _buildFilterChip('ATM'),
                  ],
                ),
              ),

              // --- LOADING BAR PAS GANTI KATEGORI ---
              if (_isLoading)
                const LinearProgressIndicator(color: AppColors.primaryBlue, backgroundColor: Colors.transparent),
              
              // --- MAP VIEW ---
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _userLocation!, 
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.goready',
                    ),
                    MarkerLayer(
                      markers: [
                        // MARKER LOKASI USER ASLI (WARNA MERAH)
                        Marker(
                          point: _userLocation!,
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.my_location, color: Colors.red, size: 40),
                        ),
                        // MARKER HASIL TARIKAN API
                        ..._poiMarkers,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary)),
        selected: isSelected,
        selectedColor: AppColors.primaryBlue,
        backgroundColor: Colors.grey.shade200,
        onSelected: (bool selected) {
          if (selected && !_isLoading) { // Ngga bisa di-spam klik kalo lagi loading
            setState(() {
              _selectedCategory = label; 
            });
            _fetchRealNearbyPlaces(label); // Langsung tembak API buat kategori baru!
          }
        },
      ),
    );
  }
}