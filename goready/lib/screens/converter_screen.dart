import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'package:intl/intl.dart';
import '../theme/colors.dart';

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Converter',
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
          bottom: const TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.currency_exchange), text: 'Currency'),
              Tab(icon: Icon(Icons.schedule), text: 'Time Zones'),
            ],
          ),
        ),
        body: const TabBarView(children: [_CurrencyTab(), _TimeTab()]),
      ),
    );
  }
}

class _CurrencyTab extends StatefulWidget {
  const _CurrencyTab();

  @override
  State<_CurrencyTab> createState() => _CurrencyTabState();
}

class _CurrencyTabState extends State<_CurrencyTab> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  double _result = 0.0;

  Map<String, double> _rates = {
    'IDR': 1.0,
    'USD': 0.0000625, 
    'JPY': 0.0095238, 
  };

  final String apiKey = 'a2ea9c585fc2d09231d5c50a';

  @override
  void initState() {
    super.initState();
    _fetchRates(); 
  }

  Future<void> _fetchRates() async {
    final url = Uri.parse(
      'https://v6.exchangerate-api.com/v6/$apiKey/latest/IDR',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conversionRates =
            data['conversion_rates'] as Map<String, dynamic>;

        if (mounted) {
          setState(() {
            _rates['IDR'] = (conversionRates['IDR'] ?? 1.0).toDouble();
            _rates['USD'] = (conversionRates['USD'] ?? 0.0000625).toDouble();
            _rates['JPY'] = (conversionRates['JPY'] ?? 0.0095238).toDouble();
            _convert(); 
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetch API: $e');
    }
  }

  void _convert() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount == 0.0) {
      setState(() => _result = 0.0);
      return;
    }

    double amountInBaseIdr = amount / _rates[_fromCurrency]!;
    double finalResult = amountInBaseIdr * _rates[_toCurrency]!;

    setState(() {
      _result = finalResult;
    });
  }

  void _swapCurrencies() {
    setState(() {
      String temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convert(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Currency Converter',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check the latest exchange rates for your trip.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (val) => _convert(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: 'Amount',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.attach_money,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: _fromCurrency,
                  onChanged: (val) {
                    setState(() {
                      _fromCurrency = val!;
                      _convert();
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.swap_horiz,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                  onPressed: _swapCurrencies,
                ),
              ),
              Expanded(
                child: _buildDropdown(
                  value: _toCurrency,
                  onChanged: (val) {
                    setState(() {
                      _toCurrency = val!;
                      _convert();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, Colors.blue.shade300],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Converted Amount',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(
                    symbol: '',
                    decimalDigits: 2,
                  ).format(_result),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _toCurrency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: ['IDR', 'USD', 'JPY'].map((String curr) {
            return DropdownMenuItem(
              value: curr,
              child: Text(
                curr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TimeTab extends StatefulWidget {
  const _TimeTab();

  @override
  State<_TimeTab> createState() => _TimeTabState();
}

class _TimeTabState extends State<_TimeTab> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now().toUtc();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'World Clocks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep track of time across different zones.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          _buildTimeCard(
            'Jakarta (WIB)',
            _currentTime.add(const Duration(hours: 7)),
            Icons.location_city,
          ),
          _buildTimeCard(
            'Bali (WITA)',
            _currentTime.add(const Duration(hours: 8)),
            Icons.beach_access,
          ),
          _buildTimeCard(
            'Papua (WIT)',
            _currentTime.add(const Duration(hours: 9)),
            Icons.landscape,
          ),
          _buildTimeCard(
            'London (UK)',
            _currentTime.add(const Duration(hours: 1)),
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String title, DateTime time, IconData icon) {
    String formattedTime = DateFormat('HH:mm:ss').format(time);
    String formattedDate = DateFormat('EEE, dd MMM yyyy').format(time);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
