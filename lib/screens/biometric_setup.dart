import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import package baru
import '../theme/colors.dart';

class BiometricSetupPage extends StatefulWidget {
  const BiometricSetupPage({super.key});

  @override
  State<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends State<BiometricSetupPage> {
  bool _isRegistered = false;
  bool _isBiometricEnabled = false;

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus(); // Cek memori pas halaman dibuka
  }

  // --- LOGIC BACA MEMORI HP ---
  Future<void> _loadBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Kalo ngga ada catetan, default-nya false
      _isRegistered = prefs.getBool('biometric_enabled') ?? false;
      _isBiometricEnabled = _isRegistered;
    });
  }

  // --- LOGIC DAFTAR & SIMPEN KE MEMORI ---
  Future<void> _registerRealBiometric() async {
    bool authenticated = false;
    
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maaf, HP ini ngga support fitur biometrik.'), backgroundColor: Colors.redAccent),
        );
        return;
      }

      authenticated = await auth.authenticate(
        localizedReason: 'Tempelin jari lu buat daftarin ke GoReady',
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error hardware: ${e.message}'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      // SIMPEN STATUS KE MEMORI HP
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', true);

      setState(() {
        _isRegistered = true;
        _isBiometricEnabled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Success! Sidik jari lu udah kesimpen.'), backgroundColor: AppColors.successGreen),
      );
    }
  }

  // --- LOGIC HAPUS MEMORI ---
  Future<void> _resetBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', false); // Ubah jadi false

    setState(() {
      _isRegistered = false;
      _isBiometricEnabled = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data biometrik di-reset dari aplikasi.'), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECEF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Biometric Setup', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            Icon(
              Icons.fingerprint, 
              size: 100, 
              color: _isRegistered ? AppColors.primaryBlue : Colors.grey.shade400
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isRegistered ? AppColors.primaryBlue.withOpacity(0.1) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                _isRegistered ? 'Status: Registered' : 'Status: Not Registered',
                style: TextStyle(
                  color: _isRegistered ? AppColors.primaryBlue : Colors.grey.shade600,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            if (!_isRegistered)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _registerRealBiometric,
                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                  label: const Text('Register Fingerprint', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            if (_isRegistered) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: SwitchListTile(
                  title: const Text('Enable Biometric Login', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Required for quick access'),
                  activeColor: AppColors.primaryBlue,
                  value: _isBiometricEnabled,
                  onChanged: (bool value) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('biometric_enabled', value);
                    setState(() {
                      _isBiometricEnabled = value;
                    });
                  }, 
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _resetBiometrics,
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text('Reset Biometrics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}