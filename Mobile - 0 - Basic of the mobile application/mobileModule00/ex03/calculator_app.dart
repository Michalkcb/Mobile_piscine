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
    'AC',
    'C',
    '/',
    '*',
    '7',
    '8',
    '9',
    '-',
    '4',
    '5',
    '6',
    '+',
    '1',
    '2',
    '3',
    '.',
    '0',
    '=',
  ];

  @override
  void dispose() {
    expressionController.dispose();
    resultController.dispose();
    super.dispose();
  }

  void onButtonPressed(String value) {
    print(value);

    switch (value) {
      case 'AC':
        _reset();
        return;
      case 'C':
        _deleteLastCharacter();
        return;
      case '=':
        _evaluateExpression();
        return;
      default:
        _appendValue(value);
    }
  }

  void _reset() {
    expressionController.text = '0';
    resultController.text = '0';
  }

  void _deleteLastCharacter() {
    final current = expressionController.text;
    if (current.isEmpty || current == '0' || current == 'Error') {
      _reset();
      return;
    }
    if (current.length == 1) {
      _reset();
      return;
    }

    final updated = current.substring(0, current.length - 1);
    expressionController.text = updated.isEmpty ? '0' : updated;
    resultController.text = '0';
  }

  void _appendValue(String value) {
    final current = expressionController.text;

    if (current == 'Error') {
      expressionController.text = value == '.' ? '0.' : value;
      resultController.text = '0';
      return;
    }

    if (value == '.') {
      if (_canAppendDecimal(current)) {
        if (current == '0' || current.isEmpty) {
          expressionController.text = '0.';
        } else if (_isOperator(current.substring(current.length - 1))) {
          expressionController.text = '$current0.';
        } else {
          expressionController.text = '$current$value';
        }
      }
      resultController.text = '0';
      return;
    }

    if (_isOperator(value)) {
      if (current == '0' && value == '-') {
        expressionController.text = '-';
      } else if (current == '0') {
        expressionController.text = '0';
      } else {
        final lastChar = current.substring(current.length - 1);
        if (current == '-' || _isOperator(lastChar)) {
          if (value == '-' && lastChar != '-' && current != '-') {
            expressionController.text = '$current$value';
          } else if (value != '-' && lastChar != value) {
            expressionController.text = current.substring(0, current.length - 1) + value;
          }
        } else {
          expressionController.text = '$current$value';
        }
      }
      resultController.text = '0';
      return;
    }

    if (current == '0') {
      expressionController.text = value;
    } else {
      expressionController.text = '$current$value';
    }
    resultController.text = '0';
  }

  bool _canAppendDecimal(String expression) {
    if (expression.isEmpty || expression == '0' || expression == '-0') {
      return true;
    }

    final lastOperatorIndex = expression.lastIndexOf(RegExp(r'[+\-*/]'));
    final currentPart = lastOperatorIndex == -1
        ? expression
        : expression.substring(lastOperatorIndex + 1);
    return !currentPart.contains('.');
  }

  bool _isOperator(String value) {
    return value == '+' || value == '-' || value == '*' || value == '/';
  }

  void _evaluateExpression() {
    final expression = expressionController.text;
    if (expression.isEmpty || expression == '0' || expression == '-' || expression == 'Error') {
      resultController.text = '0';
      return;
    }

    try {
      final value = _evaluate(expression);
      resultController.text = _formatResult(value);
    } catch (_) {
      resultController.text = 'Error';
    }
  }

  double _evaluate(String expression) {
    final cleaned = expression.replaceAll(RegExp(r'\s+'), '');
    final tokens = <Object>[];
    int index = 0;

    while (index < cleaned.length) {
      final char = cleaned[index];

      if (char.contains(RegExp(r'[0-9]')) || char == '.') {
        final end = _readNumber(cleaned, index);
        tokens.add(double.parse(cleaned.substring(index, end)));
        index = end;
        continue;
      }

      if (char == '-' && (index == 0 || _isOperator(cleaned[index - 1]))) {
        tokens.add('u-');
        index++;
        continue;
      }

      if (_isOperator(char)) {
        tokens.add(char);
        index++;
        continue;
      }

      throw Exception('Invalid expression');
    }

    final values = <double>[];
    final ops = <String>[];

    for (final token in tokens) {
      if (token is double) {
        values.add(token);
      } else if (token is String) {
        if (token == 'u-') {
          ops.add(token);
        } else {
          while (ops.isNotEmpty && _shouldPop(ops.last, token)) {
            _applyOperator(values, ops.removeLast());
          }
          ops.add(token);
        }
      }
    }

    while (ops.isNotEmpty) {
      _applyOperator(values, ops.removeLast());
    }

    if (values.length != 1) {
      throw Exception('Invalid expression');
    }
    return values.single;
  }

  int _readNumber(String expression, int start) {
    int end = start + 1;
    while (end < expression.length &&
        (expression[end] == '.' || expression[end].contains(RegExp(r'[0-9]')))) {
      end++;
    }
    return end;
  }

  bool _shouldPop(String top, String current) {
    if (top == 'u-') {
      return false;
    }

    final topPrecedence = _precedence(top);
    final currentPrecedence = _precedence(current);
    return topPrecedence >= currentPrecedence;
  }

  int _precedence(String op) {
    switch (op) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
        return 2;
      case 'u-':
        return 3;
      default:
        return 0;
    }
  }

  void _applyOperator(List<double> values, String op) {
    if (op == 'u-') {
      if (values.isEmpty) {
        throw Exception('Invalid expression');
      }
      values[values.length - 1] = -values.last;
      return;
    }

    if (values.length < 2) {
      throw Exception('Invalid expression');
    }

    final right = values.removeLast();
    final left = values.removeLast();

    switch (op) {
      case '+':
        values.add(left + right);
        break;
      case '-':
        values.add(left - right);
        break;
      case '*':
        values.add(left * right);
        break;
      case '/':
        if (right == 0) {
          throw Exception('Division by zero');
        }
        values.add(left / right);
        break;
      default:
        throw Exception('Unknown operator');
    }
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(10).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  Widget buildButton(String value) {
    return ElevatedButton(
      onPressed: () => onButtonPressed(value),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
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
              final crossAxisCount = isWide ? 5 : 4;
              final childAspectRatio = isWide ? 1.25 : 1.0;

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
