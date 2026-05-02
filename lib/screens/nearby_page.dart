import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Buat nembak rute ke Google Maps
import '../theme/colors.dart'; // Sesuaikan path ini

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  String _selectedCategory = 'Kampus';

  LatLng? _userLocation;
  bool _isLoading = true;
  List<Map<String, dynamic>> _placesData = []; // Data lengkap tempat
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getUserRealLocation();
  }

  // --- LOGIC 1: DAPETIN LOKASI ASLI ---
  Future<void> _getUserRealLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Tolong nyalain GPS HP lu dulu brok!');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Yah, izin lokasi ditolak.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Izin lokasi diblokir permanen.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _fetchRealNearbyPlaces(_selectedCategory);
    }
  }

  // --- LOGIC 2: NEMBAK API OVERPASS (VERSI REVISI) ---
  Future<void> _fetchRealNearbyPlaces(String category) async {
    if (_userLocation == null) return;

    setState(() {
      _isLoading = true;
      _placesData.clear();
    });

    // Pake "nwr" (Node, Way, Relation) biar gedung gede kayak kampus tetep kebaca
    // Pake "out center" biar dapet titik tengah gedungnya
    String query = '[out:json][timeout:25];';
    if (category == 'ATM') {
      query +=
          'nwr["amenity"="atm"](around:2000, ${_userLocation!.latitude}, ${_userLocation!.longitude});';
    } else if (category == 'Minimarket') {
      query +=
          'nwr["shop"~"convenience|supermarket"](around:2000, ${_userLocation!.latitude}, ${_userLocation!.longitude});';
    } else if (category == 'Kampus') {
      query +=
          'nwr["amenity"~"university|college"](around:5000, ${_userLocation!.latitude}, ${_userLocation!.longitude});';
    }
    query += 'out center;';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {
          'User-Agent': 'GoReady_Student_App/1.0',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        List<Map<String, dynamic>> newPlaces = [];

        for (var el in elements) {
          // Ambil titik koordinat (Bisa dari lat/lon langsung atau dari center)
          final lat = el['lat'] ?? el['center']['lat'];
          final lon = el['lon'] ?? el['center']['lon'];
          final name = el['tags']?['name'] ?? 'Unknown $category';

          // Ngitung jarak lokasi kita ke tempat ini (dalam meter)
          final distance = Geolocator.distanceBetween(
            _userLocation!.latitude,
            _userLocation!.longitude,
            lat,
            lon,
          );

          newPlaces.add({
            'name': name,
            'lat': lat,
            'lon': lon,
            'distance': distance,
          });
        }

        // Urutin dari yang paling deket ke paling jauh
        newPlaces.sort((a, b) => a['distance'].compareTo(b['distance']));

        if (mounted) {
          setState(() {
            _placesData = newPlaces;
            _isLoading = false;
          });

          // Kalo dapet data, geser kamera map ke area tersebut
          if (_placesData.isNotEmpty) {
            _mapController.move(_userLocation!, 13.5);
          }
        }
      } else {
        _showError('Server API lagi penuh brok, coba ganti kategori dulu.');
      }
    } catch (e) {
      _showError('Gagal nyambung, pastikan internet lancar.');
    }
  }

  // --- LOGIC 3: ARAHIN RUTE KE GOOGLE MAPS ASLI ---
  Future<void> _openGoogleMapsRoute(double destLat, double destLon) async {
    final originLat = _userLocation!.latitude;
    final originLon = _userLocation!.longitude;
    // URL ini bakal otomatis buka app Google Maps di HP lu
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLon&destination=$destLat,$destLon&travelmode=driving',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showError('Gagal buka Google Maps.');
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nearby Locations',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0056D2)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _userLocation == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0056D2)),
                  SizedBox(height: 16),
                  Text(
                    'Nyari sinyal satelit GPS...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // 1. BACKGROUND MAPS
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation!,
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.goready',
                    ),
                    MarkerLayer(
                      markers: [
                        // MARKER USER (KITA)
                        Marker(
                          point: _userLocation!,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blueAccent,
                            size: 36,
                          ),
                        ),
                        // MARKER TEMPAT DARI API
                        ..._placesData
                            .map(
                              (place) => Marker(
                                point: LatLng(place['lat'], place['lon']),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                  size: 36,
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ],
                ),

                // 2. KATEGORI FILTER DI ATAS MAP
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildFilterChip('Kampus'),
                        _buildFilterChip('Minimarket'),
                        _buildFilterChip('ATM'),
                      ],
                    ),
                  ),
                ),

                // 3. LOADING INDIKATOR DI TENGAH
                if (_isLoading)
                  const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF0056D2),
                        ),
                      ),
                    ),
                  ),

                // 4. CARDS LIST DI BAWAH (UI BARU)
                if (!_isLoading && _placesData.isNotEmpty)
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 140, // Tinggi Card
                      child: PageView.builder(
                        controller: PageController(
                          viewportFraction: 0.85,
                        ), // Biar card sebelah keliatan ngintip
                        itemCount: _placesData.length,
                        onPageChanged: (index) {
                          // Kalo card di-swipe, kamera map gerak ngikutin tempatnya
                          final place = _placesData[index];
                          _mapController.move(
                            LatLng(place['lat'], place['lon']),
                            16.0,
                          );
                        },
                        itemBuilder: (context, index) {
                          final place = _placesData[index];
                          // Convert jarak meter jadi KM
                          final distanceText = place['distance'] > 1000
                              ? '${(place['distance'] / 1000).toStringAsFixed(1)} KM'
                              : '${place['distance'].toStringAsFixed(0)} Meter';

                          return Card(
                            elevation: 6,
                            margin: const EdgeInsets.only(right: 16, bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.directions_walk,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Jarak: $distanceText',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _openGoogleMapsRoute(
                                        place['lat'],
                                        place['lon'],
                                      ),
                                      icon: const Icon(
                                        Icons.navigation,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Set Rute',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0056D2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Kalo API narik tapi kosong
                if (!_isLoading && _placesData.isEmpty)
                  Positioned(
                    bottom: 40,
                    left: 24,
                    right: 24,
                    child: Card(
                      color: Colors.redAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Ngga ada $_selectedCategory di sekitar sini brok.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
        label: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFF0056D2),
        backgroundColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (bool selected) {
          if (selected && !_isLoading) {
            setState(() {
              _selectedCategory = label;
            });
            _fetchRealNearbyPlaces(label);
          }
        },
      ),
    );
  }
}
