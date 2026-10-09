import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regController = TextEditingController();

  String gender = 'Male';
  bool reading = false;
  bool sports = false;
  String? department;
  String selectedItem = '';
  String message = '';

  final List<String> departments = ['CS', 'IT', 'SE', 'AI'];
  final List<String> options = ['Option 1', 'Option 2', 'Option 3'];
  final List<String> items = ['Item 1', 'Item 2', 'Item 3'];

  @override
  void dispose() {
    nameController.dispose();
    regController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz 1')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Text
              const Text(
                'Student Registration Form',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 2. TextField - Name
              TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: 'Enter Student Name'),
              ),
              const SizedBox(height: 8),

              // 3. TextField - Registration Number
              TextField(
                controller: regController,
                textAlign: TextAlign.center,
                decoration:
                const InputDecoration(hintText: 'Enter Registration Number'),
              ),
              const SizedBox(height: 16),

              // 4. Radio Button - Gender
              const Text('Select Gender'),
              RadioGroup<String>(
                groupValue: gender,
                onChanged: (v) {
                  if (v != null) {
                    setState(() => gender = v);
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<String>(value: 'Male'),
                    Text('Male'),
                    Radio<String>(value: 'Female'),
                    Text('Female'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 5. Checkbox - Hobbies
              const Text('Select Hobbies'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: reading,
                    onChanged: (v) => setState(() => reading = v!),
                  ),
                  const Text('Reading'),
                  Checkbox(
                    value: sports,
                    onChanged: (v) => setState(() => sports = v!),
                  ),
                  const Text('Sports'),
                ],
              ),
              const SizedBox(height: 8),

              // 6. Option List
              const Text('Option List'),
              Column(
                children: options.map((o) => Text(o)).toList(),
              ),
              const SizedBox(height: 16),

              // 7. Selection List
              const Text('Selection List'),
              Column(
                children: items
                    .map(
                      (item) => ListTile(
                    title: Text(item, textAlign: TextAlign.center),
                    selected: selectedItem == item,
                    onTap: () => setState(() => selectedItem = item),
                  ),
                )
                    .toList(),
              ),
              const SizedBox(height: 8),

              // 8. Dropdown List - Department
              DropdownButton<String>(
                hint: const Text('Select Department'),
                value: department,
                items: departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => department = v),
              ),
              const SizedBox(height: 16),

              // 9. Button
              ElevatedButton(
                onPressed: () {
                  setState(() => message = 'Button pressed');
                },
                child: const Text('Button'),
              ),
              const SizedBox(height: 8),

              // 10. Submit Button
              ElevatedButton(
                onPressed: () {
                  final hobbies = [
                    if (reading) 'Reading',
                    if (sports) 'Sports',
                  ].join(', ');
                  setState(() {
                    message = 'Name: ${nameController.text}\n'
                        'Reg No: ${regController.text}\n'
                        'Gender: $gender\n'
                        'Hobbies: ${hobbies.isEmpty ? 'None' : hobbies}\n'
                        'Selected Item: ${selectedItem.isEmpty ? 'None' : selectedItem}\n'
                        'Department: ${department ?? 'None'}';
                  });
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 16),

              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}