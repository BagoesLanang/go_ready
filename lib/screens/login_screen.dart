import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/colors.dart';
import '../config/api_config.dart';
import '../utils/user_session.dart';
import 'main_layout.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isBiometricEnabled = false;

  final LocalAuthentication auth = LocalAuthentication();

  // 🔥 TAMBAHAN (TANPA NGUBAH UI)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfBiometricSetupDone();
  }

  // =========================
  // BIOMETRIC (TETAP)
  // =========================
  Future<void> _checkIfBiometricSetupDone() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _loginWithBiometrics() async {
    if (!_isBiometricEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Lu belum aktifin sidik jari brok! Login manual dulu ya.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    bool authenticated = false;

    try {
      final bool canCheck = await auth.canCheckBiometrics;
      final bool supported = canCheck || await auth.isDeviceSupported();

      if (!supported) return;

      authenticated = await auth.authenticate(
        localizedReason: 'Scan sidik jari / Face ID buat masuk',
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error hardware: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    }
  }

  // =========================
  // 🔥 LOGIN BACKEND
  // =========================
  Future<void> loginUser() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true && data["user"] != null) {
        final user = data['user'];

        // 🔥 CLEAR SESSION LAMA
        UserSession.clear();

        // 🔥 SET USER BARU
        UserSession.userId = user['id'];

        // 🔥 SIMPAN KE LOCAL
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', user['id']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Login gagal")),
        );
      }
    } catch (e) {
      print("ERROR LOGIN: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal koneksi ke server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Image.asset(
                  'assets/images/logofix.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        size: 80, color: Colors.grey);
                  },
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'GoReady',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  "Don't forget your essentials",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 48),

              const Text('Email Address',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              TextField(
                controller: emailController, // 🔥 CONNECT
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text('Password',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              TextField(
                controller: passwordController, // 🔥 CONNECT
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '........',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 🔥 BUTTON (UI SAMA, LOGIC GANTI)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await loginUser(); // 🔥 API
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 🔥 BIOMETRIC (TETAP)
                  if (_isBiometricEnabled)
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0056D2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _loginWithBiometrics,
                        icon: const Icon(Icons.fingerprint,
                            color: Colors.white, size: 28),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to GoReady? '),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RegisterScreen(),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}