import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../services/api_service.dart'; // 🔥 IMPORT API BACKEND LU DI SINI
import 'ready_to_go_screen.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<Map<String, dynamic>> _checklistItems = [];

  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  final FlutterLocalNotificationsPlugin _localNotifPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isCooldown = false;
  int _stepCounter = 0;
  DateTime _lastStepTime = DateTime.now(); // Pencatat waktu langkah

  @override
  void initState() {
    super.initState();
    _loadChecklistData();
    _setupNotifications();
    _startListeningToSensor();
  }

  // --- LOGIC CRUD 1: LOAD & SAVE DARI MEMORI HP ---
  Future<void> _loadChecklistData() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 FIX: Selalu reset ke default tiap kali screen dibuka atau ganti akun
    setState(() {
      _checklistItems = [
        {'id': '1', 'name': 'Wallet', 'isChecked': false},
        {'id': '2', 'name': 'Phone', 'isChecked': false},
        {'id': '3', 'name': 'Charger', 'isChecked': false},
        {'id': '4', 'name': 'Keys', 'isChecked': false},
      ];
    });

    // Timpa data lama di SharedPreferences biar bener-bener clean
    await prefs.setString('my_checklist', json.encode(_checklistItems));
  }

  Future<void> _saveChecklistData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('my_checklist', json.encode(_checklistItems));
  }

  // --- LOGIC HELPER BUAT SNACKBAR ERROR ---
  void _showDuplicateError(String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Eits, barang "$itemName" udah ada di list lu brok!'),
        backgroundColor: Colors.redAccent, // Pake merah biar keliatan error
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- LOGIC CRUD 2: POP-UP BUAT CREATE & UPDATE + VALIDASI DUPLIKAT ---
  void _showItemDialog({int? index}) {
    TextEditingController controller = TextEditingController(
      text: index != null ? _checklistItems[index]['name'] : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          index != null ? 'Edit Item' : 'Add New Item',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Misal: Kacamata, Helm, dll',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              String newItemName = controller.text.trim();

              if (newItemName.isNotEmpty) {
                // --- CEK DUPLIKAT DI SINI (Case Insensitive) ---
                bool isDuplicate = _checklistItems.any(
                  (item) =>
                      item['name'].toString().toLowerCase() ==
                      newItemName.toLowerCase(),
                );

                if (index != null) {
                  String currentName = _checklistItems[index]['name']
                      .toString()
                      .toLowerCase();
                  if (isDuplicate && newItemName.toLowerCase() != currentName) {
                    _showDuplicateError(newItemName);
                    return;
                  }
                } else {
                  if (isDuplicate) {
                    _showDuplicateError(newItemName);
                    return;
                  }
                }

                setState(() {
                  if (index != null) {
                    _checklistItems[index]['name'] = newItemName;
                  } else {
                    _checklistItems.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'name': newItemName,
                      'isChecked': false,
                    });
                  }
                });
                _saveChecklistData();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- LOGIC NOTIFIKASI & SENSOR ---
  Future<void> _setupNotifications() async {
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );
    await _localNotifPlugin.initialize(settings: initSettings);
    _localNotifPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  void _startListeningToSensor() {
    _accelerometerSubscription = userAccelerometerEventStream().listen((
      UserAccelerometerEvent event,
    ) {
      double acceleration = sqrt(
        pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2),
      );

      if (acceleration > 1.5) {
        DateTime now = DateTime.now();
        int timeDifference = now.difference(_lastStepTime).inMilliseconds;

        if (timeDifference > 3000) {
          _stepCounter = 0;
        }

        if (timeDifference > 400) {
          _stepCounter++;
          _lastStepTime = now;

          if (_stepCounter >= 7) {
            _evaluateChecklistAndNotify();
            _stepCounter = 0;
          }
        }
      }
    });
  }

  Future<void> _evaluateChecklistAndNotify() async {
    if (_isCooldown) return;
    bool hasUncheckedItems = _checklistItems.any(
      (item) => item['isChecked'] == false,
    );
    if (!hasUncheckedItems) return;

    String missingItem = _checklistItems.firstWhere(
      (item) => item['isChecked'] == false,
    )['name'];
    setState(() {
      _isCooldown = true;
    });

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'goready_channel',
          'GoReady Reminders',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifPlugin.show(
      id: 0,
      title: '🚨 Wah, kamu mau pergi?',
      body: 'Barang kamu belum lengkap, jangan lupa bawa $missingItem!',
      notificationDetails: platformDetails,
    );

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) setState(() => _isCooldown = false);
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'GoReady',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(),
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              // 🔥 LOGIC DB BACKEND LU DI SINI
              onPressed: () async {
                List<String> selectedItems = [];
                for (var item in _checklistItems) {
                  if (item['isChecked'] == true) {
                    selectedItems.add(item['name']);
                  }
                }

                await saveTrip(selectedItems);

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReadyToGoScreen(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Confirm Ready',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Checklist Before You Go',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap items as you pack them. Use the icons to edit or delete.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _checklistItems.length,
              itemBuilder: (context, index) {
                final item = _checklistItems[index];
                final isChecked = item['isChecked'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 8,
                    top: 12,
                    bottom: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppColors.successGreen.withOpacity(0.08)
                        : Colors.white,
                    border: Border.all(
                      color: isChecked
                          ? AppColors.successGreen.withOpacity(0.5)
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _checklistItems[index]['isChecked'] = !isChecked;
                            });
                            _saveChecklistData();
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isChecked
                                      ? AppColors.successGreen
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isChecked
                                        ? AppColors.successGreen
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isChecked
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                    fontWeight: isChecked
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _showItemDialog(index: index),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final deletedName =
                                  _checklistItems[index]['name'];
                              setState(() {
                                _checklistItems.removeAt(index);
                              });
                              _saveChecklistData();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$deletedName removed.'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
