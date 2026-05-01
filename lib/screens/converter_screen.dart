import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  // Data State buat Dropdown
  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  final List<String> _currencies = ['USD', 'IDR', 'EUR', 'JPY'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildCustomAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Converter', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            
            // Toggle Currency / Time
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFF0056D2), borderRadius: BorderRadius.circular(24)),
                      child: const Center(child: Text('Currency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Time converter logic coming soon!')),
                         );
                      },
                      child: const Center(child: Text('Time', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Conversion Box
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.whiteCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          _buildInteractiveInputBox('Amount to convert', '1000', _fromCurrency, const Color(0xFFF4F5F7), AppColors.textPrimary, true),
                          const SizedBox(height: 8),
                          _buildInteractiveInputBox('Converted amount', '15,243,500.00', _toCurrency, const Color(0xFFF0F5FE), const Color(0xFF0056D2), false),
                        ],
                      ),
                      // Swap Button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            String temp = _fromCurrency;
                            _fromCurrency = _toCurrency;
                            _toCurrency = temp;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF0056D2), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                          child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Reference Zones (Sesuai Request Dosen)
            Row(
              children: const [
                Icon(Icons.access_time, color: Color(0xFF0056D2), size: 20),
                SizedBox(width: 8),
                Text('Reference Zones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Grid Zones Full 4 Item (WIB, WITA, WIT, London)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
              children: [
                _buildZoneCard('Jakarta', '14:30', 'WIB', 'Local', const Color(0xFF0056D2)),
                _buildZoneCard('Bali', '15:30', 'WITA', '+1h', AppColors.successGreen),
                _buildZoneCard('Papua', '16:30', 'WIT', '+2h', AppColors.successGreen), 
                _buildZoneCard('London', '07:30', 'GMT', '-7h', AppColors.dangerRed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper Custom Widget buat Input Box yang Dropdown-nya jalan
  Widget _buildInteractiveInputBox(String label, String value, String selectedCurrency, Color bgColor, Color textColor, bool isTop) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCurrency,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                        items: _currencies.map((String currency) {
                          return DropdownMenuItem<String>(
                            value: currency,
                            child: Text(currency),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            if (isTop) {
                              _fromCurrency = newValue!;
                            } else {
                              _toCurrency = newValue!;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildZoneCard(String city, String time, String timezone, String offset, Color offsetColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(city, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timezone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0056D2))),
              Text(offset, style: TextStyle(fontSize: 12, color: offsetColor)),
            ],
          )
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue), onPressed: () => Navigator.pop(context)),
      title: const Text('GoReady', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 20)),
      centerTitle: true,
      actions: [IconButton(icon: const Icon(Icons.notifications_none_outlined, color: AppColors.primaryBlue), onPressed: () {})],
    );
  }
}