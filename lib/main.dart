import 'package:flutter/material.dart';

void main() => runApp(const BMIApp());

class BMIApp extends StatelessWidget {
  const BMIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI & Calories',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

enum Gender { male, female }

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  Gender _gender = Gender.male;
  String _activity = 'Sedentary (little/no exercise)';
  String? _result;

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  double _activityFactor(String a) {
    switch (a) {
      case 'Light (1–3 days/wk)': return 1.375;
      case 'Moderate (3–5 days/wk)': return 1.55;
      case 'Active (6–7 days/wk)': return 1.725;
      case 'Very active (twice daily)': return 1.9;
      default: return 1.2; // Sedentary
    }
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 24.9) return 'Normal';
    if (bmi < 29.9) return 'Overweight';
    return 'Obese';
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final age = int.parse(_ageCtrl.text.trim());
    final kg = double.parse(_weightCtrl.text.trim());
    final cm = double.parse(_heightCtrl.text.trim());
    final m = cm / 100;

    final bmi = kg / (m * m);
    final bmr = (_gender == Gender.male)
        ? (10 * kg) + (6.25 * cm) - (5 * age) + 5
        : (10 * kg) + (6.25 * cm) - (5 * age) - 161;
    final tdee = bmr * _activityFactor(_activity);

    setState(() {
      _result =
          'BMI: ${bmi.toStringAsFixed(1)} (${_bmiCategory(bmi)})\n'
          'BMR: ${bmr.toStringAsFixed(0)} kcal/day\n'
          'Estimated Daily Calories (TDEE): ${tdee.toStringAsFixed(0)} kcal/day';
    });
  }

  @override
  Widget build(BuildContext context) {
    const activities = [
      'Sedentary (little/no exercise)',
      'Light (1–3 days/wk)',
      'Moderate (3–5 days/wk)',
      'Active (6–7 days/wk)',
      'Very active (twice daily)',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('BMI & Calorie Calculator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age (years)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter age';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0 || n > 120) return 'Enter valid age';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Gender:'),
                    const SizedBox(width: 12),
                    Radio<Gender>(
                      value: Gender.male,
                      groupValue: _gender,
                      onChanged: (g) => setState(() => _gender = g!),
                    ),
                    const Text('Male'),
                    const SizedBox(width: 16),
                    Radio<Gender>(
                      value: Gender.female,
                      groupValue: _gender,
                      onChanged: (g) => setState(() => _gender = g!),
                    ),
                    const Text('Female'),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter weight';
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Enter valid weight';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _heightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter height';
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Enter valid height';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _activity,
                  items: activities
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => setState(() => _activity = v!),
                  decoration: const InputDecoration(
                    labelText: 'Activity level',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _calculate,
                    child: const Text('Calculate'),
                  ),
                ),
                const SizedBox(height: 20),
                if (_result != null)
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_result!, style: const TextStyle(fontSize: 16, height: 1.4)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
