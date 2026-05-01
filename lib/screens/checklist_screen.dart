import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import '../theme/colors.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  // --- 1. State Variables ---
  bool _isLoadingAi = true;
  String _aiSuggestion = "Thinking...";
  
  // Daftar barang bawaan (Sesuai Konsep Lo)
  final List<Map<String, dynamic>> _essentials = [
    {'name': 'Dompet', 'isChecked': false},
    {'name': 'Handphone', 'isChecked': false},
    {'name': 'Kunci Motor/Kost', 'isChecked': false},
    {'name': 'Charger', 'isChecked': false},
  ];

  // Sensor State
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _isWarningActive = false;

  @override
  void initState() {
    super.initState();
    _getAiSuggestion(); // Panggil AI pas buka halaman
    _initAccelerometer(); // Aktifin sensor penjaga
  }

  // --- 2. Logic AI (Gemini) ---
  Future<void> _getAiSuggestion() async {
    try {
      // API Key lo masukin sini bre
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'ISI_API_KEY_LO_DI_SINI');
      
      // Data LBS & Waktu (Simulation)
      final now = DateTime.now();
      final location = "Mertoyudan, Magelang"; // Dummy LBS
      
      final prompt = "User mau keluar jam ${now.hour}:${now.minute} di lokasi $location. Berikan saran 1-2 barang esensial tambahan yang unik selain Dompet, HP, Kunci. Jawab sangat singkat (max 10 kata).";
      
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _aiSuggestion = response.text ?? "Jangan lupa bawa semangat!";
        _isLoadingAi = false;
      });
    } catch (e) {
      setState(() {
        _aiSuggestion = "Cek lagi perlengkapan musim ini ya!";
        _isLoadingAi = false;
      });
    }
  }

  // --- 3. Logic Sensor (Accelerometer) ---
  void _initAccelerometer() {
    _accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
      // Kalo HP gerak kenceng (Z axis atau X/Y kenceng)
      if (event.x.abs() > 12 || event.y.abs() > 12) {
        _checkIfReadyToGo();
      }
    });
  }

  void _checkIfReadyToGo() {
    bool allChecked = _essentials.every((item) => item['isChecked']);
    
    // Kalo belum lengkap tapi udah gerak, kasih warning!
    if (!allChecked && !_isWarningActive) {
      _isWarningActive = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('EITS! Barang belum lengkap, jangan jalan dulu! 🛑', 
            textAlign: TextAlign.center, 
            style: TextStyle(fontWeight: FontWeight.bold)
          ),
          backgroundColor: AppColors.dangerRed,
          duration: Duration(seconds: 2),
        ),
      ).closed.then((_) => _isWarningActive = false);
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool allChecked = _essentials.every((item) => item['isChecked']);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prevention Mode', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // --- AI Suggestion Card ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primaryBlue, Colors.blue.shade300]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text('AI SMART SUGGESTION', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                _isLoadingAi 
                  ? const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24)
                  : Text(_aiSuggestion, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // --- Checklist Section ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _essentials.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: CheckboxListTile(
                    title: Text(_essentials[index]['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                    value: _essentials[index]['isChecked'],
                    activeColor: AppColors.primaryBlue,
                    checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    onChanged: (val) {
                      setState(() {
                        _essentials[index]['isChecked'] = val!;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // --- Confirm Button ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: allChecked ? () {
                  // Logika nyatet ke history
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selamat jalan! Semua aman dibawa. ✅'), backgroundColor: AppColors.successGreen),
                  );
                } : null, // Disable kalo belum lengkap
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text('Confirm & Go', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}