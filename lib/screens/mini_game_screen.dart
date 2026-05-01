import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../theme/colors.dart';

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  int _score = 0;
  
  // Data Item Game
  final List<Map<String, dynamic>> _allItems = [
    {'name': 'Dompet', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'Kunci', 'icon': Icons.key_rounded},
    {'name': 'HP', 'icon': Icons.phone_android_rounded},
    {'name': 'Laptop', 'icon': Icons.laptop_mac_rounded},
    {'name': 'Buku', 'icon': Icons.menu_book_rounded},
    {'name': 'Charger', 'icon': Icons.power_rounded},
  ];

  late Map<String, dynamic> _targetItem;
  late Map<String, dynamic> _leftBox;
  late Map<String, dynamic> _rightBox;

  // Sensor & Cursor State
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _cursorX = 0.0; // Range: -1.0 (Kiri) sampe 1.0 (Kanan)
  
  // Selection State
  String _hoveredSide = 'none'; // 'left', 'right', 'none'
  Timer? _holdTimer;
  bool _isProcessingFeedback = false; // Biar ga dobel klik pas lagi animasi

  @override
  void initState() {
    super.initState();
    _setupNewRound();
    _initSensor();
  }

  void _initSensor() {
    // Dengerin pergerakan Accelerometer HP
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (_isProcessingFeedback) return;

      setState(() {
        // Mapping X axis. Dibagi 3.0 biar sensitivitasnya pas.
        // Dikasih minus (-) biar pas HP miring kanan, cursor ke kanan.
        _cursorX = -(event.x / 3.0).clamp(-1.0, 1.0);
      });

      _checkHoverState();
    });
  }

  void _checkHoverState() {
    String currentSide = 'none';
    
    // Tentukan zona kiri atau kanan berdasarkan posisi cursor
    if (_cursorX < -0.4) {
      currentSide = 'left';
    } else if (_cursorX > 0.4) {
      currentSide = 'right';
    }

    // Kalo cursor pindah zona, reset timer
    if (currentSide != _hoveredSide) {
      _holdTimer?.cancel();
      setState(() {
        _hoveredSide = currentSide;
      });

      // Kalo lagi di dalem kotak, mulai hitung 1 detik
      if (currentSide != 'none') {
        _holdTimer = Timer(const Duration(milliseconds: 1000), () {
          _verifySelection(currentSide);
        });
      }
    }
  }

  void _verifySelection(String selectedSide) {
    setState(() {
      _isProcessingFeedback = true;
    });

    Map<String, dynamic> selectedItem = selectedSide == 'left' ? _leftBox : _rightBox;
    bool isCorrect = selectedItem['name'] == _targetItem['name'];

    if (isCorrect) {
      // BENAR
      setState(() {
        _score++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Correct! 🎯', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 50, right: 50),
        ),
      );
    } else {
      // SALAH (Feedback Merah)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Wrong Item! ❌', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.dangerRed,
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 150, left: 50, right: 50),
        ),
      );
    }

    // Kasih jeda dikit buat ngeliat feedback, trus lanjut round
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _setupNewRound();
        setState(() {
          _isProcessingFeedback = false;
        });
      }
    });
  }

  void _setupNewRound() {
    final random = Random();
    
    // Pilih 2 item unik
    var shuffledItems = List<Map<String, dynamic>>.from(_allItems)..shuffle();
    var option1 = shuffledItems[0];
    var option2 = shuffledItems[1];

    // Tentukan mana yang jadi target
    _targetItem = random.nextBool() ? option1 : option2;

    // Randomize posisi kiri-kanan
    if (random.nextBool()) {
      _leftBox = option1;
      _rightBox = option2;
    } else {
      _leftBox = option2;
      _rightBox = option1;
    }
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Score: $_score', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // --- Pertanyaan ---
              const Text('TILT & HOLD TO SELECT:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text(
                'Pilih: ${_targetItem['name']}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 40),

              // --- Area Permainan (Boxes + Cursor) ---
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Kotak Kiri dan Kanan
                    Row(
                      children: [
                        Expanded(child: _buildItemBox(_leftBox, 'left')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildItemBox(_rightBox, 'right')),
                      ],
                    ),

                    // Cursor Penunjuk (Gerak pake Alignment)
                    Align(
                      alignment: Alignment(_cursorX, 0.2), // Y nya disetting agak ke bawah dikit
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.dangerRed.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.dangerRed.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(Icons.gps_fixed, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Instruksi Bawah
              const Text(
                'Tilt your phone left or right.\nHold the cursor over an item for 1 second.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget buat bikin kotaknya
  Widget _buildItemBox(Map<String, dynamic> item, String side) {
    bool isHovered = _hoveredSide == side;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 200,
      decoration: BoxDecoration(
        color: isHovered ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.whiteCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHovered ? AppColors.primaryBlue : Colors.grey.shade200,
          width: isHovered ? 4 : 2,
        ),
        boxShadow: isHovered
            ? [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 20, spreadRadius: 2)]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item['icon'], size: 80, color: isHovered ? AppColors.primaryBlue : AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            item['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isHovered ? AppColors.primaryBlue : AppColors.textPrimary,
            ),
          ),
          
          // Indikator loading (pura-puranya) pas lagi di-hover
          const SizedBox(height: 12),
          Opacity(
            opacity: isHovered ? 1.0 : 0.0,
            child: const SizedBox(
              width: 40,
              height: 4,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
          )
        ],
      ),
    );
  }
}