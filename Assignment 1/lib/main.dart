import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const SalaryApp());
Color onColor(Color c) => c.computeLuminance() > 0.5 ? Colors.black : Colors.white;

String money(double v) {
  final p = v.toStringAsFixed(2).split('.');
  final whole = p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return 'Rs. $whole.${p[1]}';
}

/// Tax slabs on gross monthly salary (edit if your teacher gives other rates).
double taxRateFor(double gross) {
  if (gross <= 50000) return 0;
  if (gross <= 100000) return 5;
  if (gross <= 200000) return 10;
  return 15;
}

class SalaryApp extends StatelessWidget {
  const SalaryApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Salary Calculator',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: const SalaryPage(),
  );
}

typedef SalaryCalculatorApp = SalaryApp;

class SalaryPage extends StatefulWidget {
  const SalaryPage({super.key});
  @override
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  final _formKey = GlobalKey<FormState>();
  final _basic = TextEditingController();
  final _hra = TextEditingController();
  final _medical = TextEditingController();
  final _travel = TextEditingController();

  double? _gross, _rate, _tax, _net;
  int _runs = 0; // changes every calculation so the animation replays

  @override
  void dispose() {
    for (final c in [_basic, _hra, _medical, _travel]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Value cannot be negative';
    return null;
  }

  double _val(TextEditingController c) => double.parse(c.text.trim());

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final gross = _val(_basic) + _val(_hra) + _val(_medical) + _val(_travel);
    final rate = taxRateFor(gross);
    final tax = gross * rate / 100;
    setState(() {
      _gross = gross;
      _rate = rate;
      _tax = tax;
      _net = gross - tax;
      _runs++;
    });
  }

  void _reset() {
    _formKey.currentState!.reset();
    for (final c in [_basic, _hra, _medical, _travel]) {
      c.clear();
    }
    FocusScope.of(context).unfocus();
    setState(() => _gross = _rate = _tax = _net = null);
  }

  Widget _field(String label, TextEditingController c, IconData icon, int i,
      {bool last = false}) {
    return Reveal(
      delay: i * 120,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: c,
          validator: _validate,
          textInputAction: last ? TextInputAction.done : TextInputAction.next,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            prefixText: 'Rs. ',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Calculator'),
        centerTitle: true,
        backgroundColor: scheme.primaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Reveal(
                  delay: 0,
                  child: Text('Enter your monthly salary details',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 16),
                _field('Basic Salary', _basic, Icons.payments_outlined, 1),
                _field('House Rent Allowance', _hra, Icons.home_outlined, 2),
                _field('Medical Allowance', _medical, Icons.medical_services_outlined, 3),
                _field('Travel Allowance', _travel, Icons.directions_car_outlined, 4,
                    last: true),
                const SizedBox(height: 6),
                Reveal(
                  delay: 600,
                  child: Row(children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Calculate',
                        icon: Icons.calculate,
                        colors: const [Color(0xFF00695C), Color(0xFF26A69A)],
                        onPressed: _calculate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: 'Reset',
                        icon: Icons.refresh,
                        colors: const [Color(0xFFFFE082), Color(0xFFFFCA28)],
                        onPressed: _reset,
                      ),
                    ),
                  ]),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  child: _net == null ? const SizedBox(width: double.infinity) : _results(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _results() {
    return Reveal(
      key: ValueKey(_runs),
      delay: 0,
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(children: [
          ResultCard(
            title: 'Tax Deduction',
            value: _tax!,
            subtitle: 'Tax rate: ${_rate!.toStringAsFixed(0)}%',
            color: const Color(0xFFEF5350),
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: 'Net Monthly Income',
            value: _net!,
            subtitle: 'Gross Salary ${money(_gross!)} - Tax Deduction',
            color: const Color(0xFF00897B),
          ),
        ]),
      ),
    );
  }
}

/// Fade + slide-up entrance animation.
class Reveal extends StatelessWidget {
  final Widget child;
  final int delay; // milliseconds
  const Reveal({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// Button with a gradient, a press "squash" animation and a text color
/// chosen from the background luminance.
class GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onPressed;
  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.colors,
    required this.onPressed,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final fg = onColor(widget.colors.first);
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onPressed();
      },
      child: AnimatedScale(
        scale: _down ? 0.93 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.colors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.colors.last.withValues(alpha: _down ? 0.15 : 0.45),
                blurRadius: _down ? 4 : 12,
                offset: Offset(0, _down ? 2 : 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: fg),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card whose amount counts up from 0; text color comes from luminance.
class ResultCard extends StatelessWidget {
  final String title, subtitle;
  final double value;
  final Color color;
  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = onColor(color);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        Text(title, style: TextStyle(color: fg, fontSize: 16)),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Text(money(v),
              style: TextStyle(color: fg, fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: fg.withValues(alpha: 0.85), fontSize: 12)),
      ]),
    );
  }
}
