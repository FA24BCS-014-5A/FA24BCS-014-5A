import 'package:flutter/material.dart';

void main() {
  runApp(const SalaryCalculatorApp());
}

class SalaryCalculatorApp extends StatelessWidget {
  const SalaryCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salary Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const SalaryCalculatorScreen(),
    );
  }
}

class SalaryCalculatorScreen extends StatefulWidget {
  const SalaryCalculatorScreen({super.key});

  @override
  State<SalaryCalculatorScreen> createState() =>
      _SalaryCalculatorScreenState();
}

class _SalaryCalculatorScreenState extends State<SalaryCalculatorScreen> {
  // Form key used for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for each input field
  final TextEditingController _basicController = TextEditingController();
  final TextEditingController _hraController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();
  final TextEditingController _travelController = TextEditingController();

  // Result values
  double? _grossSalary;
  double? _taxDeduction;
  double? _netIncome;
  bool _showResult = false;

  // Tax rate used to calculate tax deduction on gross salary.
  // (Change this value if your instructor specifies a different tax slab.)
  static const double _taxRate = 0.05; // 5%

  @override
  void dispose() {
    _basicController.dispose();
    _hraController.dispose();
    _medicalController.dispose();
    _travelController.dispose();
    super.dispose();
  }

  void _calculateSalary() {
    // Validate the form first
    if (_formKey.currentState!.validate()) {
      final double basic = double.parse(_basicController.text);
      final double hra = double.parse(_hraController.text);
      final double medical = double.parse(_medicalController.text);
      final double travel = double.parse(_travelController.text);

      final double gross = basic + hra + medical + travel;
      final double tax = gross * _taxRate;
      final double net = gross - tax;

      setState(() {
        _grossSalary = gross;
        _taxDeduction = tax;
        _netIncome = net;
        _showResult = true;
      });
    }
  }

  void _resetForm() {
    _basicController.clear();
    _hraController.clear();
    _medicalController.clear();
    _travelController.clear();
    setState(() {
      _grossSalary = null;
      _taxDeduction = null;
      _netIncome = null;
      _showResult = false;
    });
    _formKey.currentState!.reset();
  }

  // Reusable validator for all salary fields
  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    final double? number = double.tryParse(value);
    if (number == null) {
      return 'Enter a valid number';
    }
    if (number < 0) {
      return 'Value cannot be negative';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Calculator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter Salary Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildInputField(
                  controller: _basicController,
                  label: 'Basic Salary',
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _hraController,
                  label: 'House Rent Allowance',
                  icon: Icons.home,
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _medicalController,
                  label: 'Medical Allowance',
                  icon: Icons.medical_services,
                ),
                const SizedBox(height: 12),

                _buildInputField(
                  controller: _travelController,
                  label: 'Travel Allowance',
                  icon: Icons.directions_car,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _calculateSalary,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetForm,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (_showResult) _buildResultCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: _validateAmount,
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 3,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Result',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _resultRow('Gross Salary', _grossSalary),
            // Tax Deduction must be shown first, before Net Monthly Income
            _resultRow('Tax Deduction', _taxDeduction),
            _resultRow('Net Monthly Income', _netIncome, highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, double? value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'Rs. ${value?.toStringAsFixed(2) ?? "0.00"}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.indigo : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
