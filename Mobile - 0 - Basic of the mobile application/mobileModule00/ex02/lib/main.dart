import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController expressionController =
      TextEditingController(text: '0');
  final TextEditingController resultController =
      TextEditingController(text: '0');

  final List<String> buttons = [
    'AC', 'C', '/', '*',
    '7', '8', '9', '-',
    '4', '5', '6', '+',
    '1', '2', '3', '.',
    '0', '=',
  ];

  @override
  void dispose() {
    expressionController.dispose();
    resultController.dispose();
    super.dispose();
  }

  void onButtonPressed(String value) {
    print(value);
  }

  Widget buildButton(String value) {
    return ElevatedButton(
      onPressed: () => onButtonPressed(value),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget buildDisplayFields() {
    return Column(
      children: [
        TextField(
          controller: expressionController,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Expression',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: resultController,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Result',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              final crossAxisCount = isWide ? 6 : 4;
              final childAspectRatio = isWide ? 1.5 : 1.1;

              return Column(
                children: [
                  buildDisplayFields(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: buttons.map(buildButton).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
