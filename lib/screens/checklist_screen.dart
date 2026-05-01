import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:convert'; // Tambahin ini buat parsing JSON
import '../theme/colors.dart';
import 'ready_to_go_screen.dart'; // Sesuaikan path-nya kalo beda folder ya

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  bool _isLoadingAi = true;

  final List<Map<String, dynamic>> _essentials = [
    {'name': 'Wallet', 'isChecked': false},
    {'name': 'Phone', 'isChecked': false},
    {'name': 'Charger', 'isChecked': false},
    {'name': 'Keys', 'isChecked': false},
  ];

  List<Map<String, dynamic>> _aiSuggestions = [];
  final TextEditingController _newItemController = TextEditingController();

  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _isWarningActive = false;

  @override
  void initState() {
    super.initState();
    _getAiSuggestion();
    _initAccelerometer();
  }

  // --- LOGIC AI YANG UDAH DI-UPGRADE ---
  Future<void> _getAiSuggestion() async {
    try {
      // PENTING: Masukin API Key lo beneran di sini ya bre!
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'ISI_API_KEY_LO_DI_SINI',
      );

      final now = DateTime.now();
      // Prompt kita ganti minta JSON biar gampang di-decode
      final prompt =
          "Jam sekarang ${now.hour}:${now.minute}. Berikan 2 saran barang esensial tambahan (jangan Wallet, Phone, Keys, Charger). Jawab HANYA menggunakan format array JSON murni tanpa markdown seperti ini: [{\"title\": \"NamaBarang\", \"desc\": \"Alasan singkat\"}]";

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        // Bersihin markdown json kalau ai-nya bandel
        String cleanJson = response.text!
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        List<dynamic> parsedData = jsonDecode(cleanJson);

        setState(() {
          _aiSuggestions = parsedData
              .map(
                (item) => {
                  'title': item['title'].toString(),
                  'desc': item['desc'].toString(),
                  'icon': Icons.auto_awesome_outlined,
                },
              )
              .toList();
          _isLoadingAi = false;
        });
      }
    } catch (e) {
      // Fallback kalo API Key belum diisi atau error
      setState(() {
        _aiSuggestions = [
          {
            'title': "API Key Belum Diisi",
            'desc': 'Ganti tulisan ISI_API_KEY di code pake key aslimu.',
            'icon': Icons.warning_amber_rounded,
          },
          {
            'title': 'Bring a jacket',
            'desc': 'Temperatures expected to drop by evening.',
            'icon': Icons.cloud_outlined,
          },
        ];
        _isLoadingAi = false;
      });
    }
  }

  // --- LOGIC CRUD BARANG ---
  void _addNewItem() {
    if (_newItemController.text.trim().isNotEmpty) {
      setState(() {
        _essentials.add({
          'name': _newItemController.text.trim(),
          'isChecked': false,
        });
        _newItemController.clear();
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _essentials.removeAt(index);
    });
  }

  void _editItem(int index) {
    _newItemController.text = _essentials[index]['name'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: TextField(
          controller: _newItemController,
          decoration: const InputDecoration(hintText: "Nama barang baru..."),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _newItemController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newItemController.text.trim().isNotEmpty) {
                setState(() {
                  _essentials[index]['name'] = _newItemController.text.trim();
                });
              }
              _newItemController.clear();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- LOGIC SENSOR ---
  void _initAccelerometer() {
    _accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (event.x.abs() > 12 || event.y.abs() > 12) {
        _checkIfReadyToGo();
      }
    });
  }

  void _checkIfReadyToGo() {
    if (_essentials.isEmpty) return;
    bool allChecked = _essentials.every((item) => item['isChecked']);

    if (!allChecked && !_isWarningActive) {
      _isWarningActive = true;
      ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text(
                'EITS! Barang belum lengkap, jangan jalan dulu! 🛑',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.dangerRed,
              duration: Duration(seconds: 2),
            ),
          )
          .closed
          .then((_) => _isWarningActive = false);
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _newItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool allChecked =
        _essentials.isNotEmpty &&
        _essentials.every((item) => item['isChecked']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GoReady',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Checklist Before You Go',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap items as you pack them to ensure nothing is left behind.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // --- LIST BARANG (Udah ada Edit & Delete) ---
                  ..._essentials.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, dynamic> item = entry.value;
                    bool isChecked = item['isChecked'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _essentials[idx]['isChecked'] = !isChecked;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? const Color(0xFFE8F5E9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isChecked
                                ? const Color(0xFFC8E6C9)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isChecked
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isChecked
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade400,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isChecked
                                      ? const Color(0xFF2E7D32)
                                      : Colors.black87,
                                  fontWeight: isChecked
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            // Tombol Edit & Delete muncul kalo belum dicentang
                            if (!isChecked) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () => _editItem(idx),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.dangerRed,
                                  size: 20,
                                ),
                                onPressed: () => _deleteItem(idx),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),

                  // --- INPUT TAMBAH BARANG ---
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newItemController,
                          decoration: InputDecoration(
                            hintText: 'Add specific item...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _addNewItem(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _addNewItem,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // --- SMART SUGGESTIONS ---
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Smart Suggestions',
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 110,
                    child: _isLoadingAi
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _aiSuggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _aiSuggestions[index];
                              return Container(
                                width: 260,
                                margin: const EdgeInsets.only(right: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        suggestion['icon'],
                                        size: 20,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            suggestion['title'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            suggestion['desc'],
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          // --- TOMBOL KONFIRMASI ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFFF8F9FA)),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: allChecked
                    ? () {
                        // Ganti Navigator.pop jadi ini:
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReadyToGoScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm Ready',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: allChecked ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
