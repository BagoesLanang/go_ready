import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/user_session.dart';
import 'login_screen.dart';
import 'main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // biar keliatan splash

    final prefs = await SharedPreferences.getInstance();
    
    // 🔥 BAGIAN YANG DIGANTI: Panggilnya pake getString
    final String? userIdRaw = prefs.getString('user_id');

    if (userIdRaw != null) {
      // 🔥 BAGIAN YANG DIGANTI: Convert teks jadi angka
      UserSession.userId = int.tryParse(userIdRaw);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 420,
        ),
      ),
    );
  }
}