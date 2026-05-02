import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/user_session.dart';
import '../screens/login_screen.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  // 🔥 HAPUS SESSION
  await prefs.remove('user_id');

  // 🔥 RESET USER
  UserSession.userId = null;

  // 🔥 BALIK KE LOGIN
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}