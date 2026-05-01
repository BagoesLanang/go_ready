import 'package:flutter/material.dart';
import '../theme/colors.dart';

class BiometricSetupPage extends StatefulWidget {
  const BiometricSetupPage({super.key});

  @override
  State<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends State<BiometricSetupPage> {
  bool _isRegistered = false;
  bool _isBiometricEnabled = false;

  // Logic buat manggil Card Pop-up Scan
  void _showScanDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Biar user ngga bisa nutup pop-up sembarangan
      builder: (BuildContext context) {
        return const ScanFingerprintDialog(); // Manggil widget pop-up di bawah
      },
    ).then((isSuccess) {
      // Kalo pop-up selesai dan bawa hasil 'true'
      if (isSuccess == true) {
        setState(() {
          _isRegistered = true;
          _isBiometricEnabled = true; // Langsung otomatis nyala
        });
      }
    });
  }

  // Logic buat Reset
  void _resetBiometrics() {
    setState(() {
      _isRegistered = false;
      _isBiometricEnabled = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometric data has been reset.'),
        backgroundColor: Colors.redAccent,
      ),
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Biometric Setup',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              color: _isRegistered
                  ? AppColors.primaryBlue
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isRegistered
                    ? AppColors.primaryBlue.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isRegistered ? 'Status: Registered' : 'Status: Not Registered',
                style: TextStyle(
                  color: _isRegistered
                      ? AppColors.primaryBlue
                      : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- TAMPILAN KALO BELUM DAFTAR ---
            if (!_isRegistered)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _showScanDialog,
                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                  label: const Text(
                    'Register Fingerprint',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            // --- TAMPILAN KALO UDAH DAFTAR ---
            if (_isRegistered) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Enable Biometric Login',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Required for quick access'),
                  activeColor: AppColors.primaryBlue,
                  value: _isBiometricEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _isBiometricEnabled = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Reset Biometrics
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _resetBiometrics,
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: const Text(
                    'Reset Biometrics',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =======================================================
// WIDGET CARD POP-UP BUAT SIMULASI SCAN
// =======================================================
class ScanFingerprintDialog extends StatefulWidget {
  const ScanFingerprintDialog({super.key});

  @override
  State<ScanFingerprintDialog> createState() => _ScanFingerprintDialogState();
}

class _ScanFingerprintDialogState extends State<ScanFingerprintDialog> {
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    // Pura-puranya loading scan selama 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = false; // Ubah state jadi success
        });

        // Nampilin Success 1 detik, abis itu pop-up nutup sendiri
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context, true); // Lempar nilai true ke halaman utama
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Biar card-nya nge-fit konten
          children: [
            if (_isScanning) ...[
              const Icon(
                Icons.fingerprint,
                size: 80,
                color: Colors.orange,
              ), // Icon lagi scan
              const SizedBox(height: 24),
              const Text(
                'Scanning...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please hold your finger on the sensor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(), // Loading muter
            ] else ...[
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ), // Icon sukses
              const SizedBox(height: 24),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fingerprint verified and registered.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
